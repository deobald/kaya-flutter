import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:kaya/core/services/connectivity_service.dart';
import 'package:kaya/core/services/logger_service.dart';
import 'package:kaya/features/account/services/account_repository.dart';
import 'package:kaya/features/anga/services/anga_repository.dart';
import 'package:kaya/features/anga/services/file_storage_service.dart';
import 'package:kaya/features/errors/services/error_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sync_service.g.dart';

/// Result of a sync operation.
class SyncResult {
  final int angaDownloaded;
  final int angaUploaded;
  final int metaDownloaded;
  final int metaUploaded;
  final int cacheDownloaded;
  final List<String> errors;
  final bool isConnectionError;

  SyncResult({
    this.angaDownloaded = 0,
    this.angaUploaded = 0,
    this.metaDownloaded = 0,
    this.metaUploaded = 0,
    this.cacheDownloaded = 0,
    this.errors = const [],
    this.isConnectionError = false,
  });

  bool get hasChanges =>
      angaDownloaded > 0 ||
      angaUploaded > 0 ||
      metaDownloaded > 0 ||
      metaUploaded > 0 ||
      cacheDownloaded > 0;

  bool get hasErrors => errors.isNotEmpty;
}

/// Service for syncing local files with the Kaya server.
class SyncService {
  final FileStorageService _storage;
  final AccountRepository _accountRepo;
  final LoggerService? _logger;
  final ErrorService _errorService;

  SyncService(
    this._storage,
    this._accountRepo,
    this._logger,
    this._errorService,
  );

  /// Performs a full sync with the server.
  /// Connection errors are tracked separately and don't get added to the error service.
  Future<SyncResult> sync() async {
    final settings = await _accountRepo.loadSettings();
    if (!settings.canSync) {
      return SyncResult(errors: ['No credentials configured']);
    }

    final email = settings.email!;
    final password = await _accountRepo.getPassword();
    if (password == null) {
      return SyncResult(errors: ['Password not set']);
    }

    final baseUrl = settings.serverUrl;
    final errors = <String>[];
    var isConnectionError = false;

    var angaDownloaded = 0;
    var angaUploaded = 0;
    var metaDownloaded = 0;
    var metaUploaded = 0;
    var cacheDownloaded = 0;

    try {
      // Sync anga files
      final angaResult = await _syncAngas(baseUrl, email, password);
      angaDownloaded = angaResult.downloaded;
      angaUploaded = angaResult.uploaded;
      errors.addAll(angaResult.errors);
      if (angaResult.isConnectionError) {
        isConnectionError = true;
        _logger?.w('Sync connection error during anga sync');
      }

      // Sync meta files (skip if already got connection error)
      if (!isConnectionError) {
        final metaResult = await _syncMeta(baseUrl, email, password);
        metaDownloaded = metaResult.downloaded;
        metaUploaded = metaResult.uploaded;
        errors.addAll(metaResult.errors);
        if (metaResult.isConnectionError) {
          isConnectionError = true;
          _logger?.w('Sync connection error during meta sync');
        }
      }

      // Sync cache (download only, skip if already got connection error)
      if (!isConnectionError) {
        final cacheResult = await _syncCache(baseUrl, email, password);
        cacheDownloaded = cacheResult.downloaded;
        errors.addAll(cacheResult.errors);
        if (cacheResult.isConnectionError) {
          isConnectionError = true;
          _logger?.w('Sync connection error during cache sync');
        }
      }
    } on SocketException catch (e) {
      // Connection error - server unreachable
      isConnectionError = true;
      _logger?.w('Sync connection error: $e');
    } on http.ClientException catch (e) {
      // HTTP client error - likely connection issue
      isConnectionError = true;
      _logger?.w('Sync connection error: $e');
    } catch (e) {
      errors.add('Sync failed: $e');
      _logger?.e('Sync failed', e);
    }

    final result = SyncResult(
      angaDownloaded: angaDownloaded,
      angaUploaded: angaUploaded,
      metaDownloaded: metaDownloaded,
      metaUploaded: metaUploaded,
      cacheDownloaded: cacheDownloaded,
      errors: errors,
      isConnectionError: isConnectionError,
    );

    // Log only if there were changes or errors
    if (result.hasChanges) {
      _logger?.i(
        'Sync complete: ${angaDownloaded + metaDownloaded + cacheDownloaded} downloaded, '
        '${angaUploaded + metaUploaded} uploaded',
      );
    }

    // Only add non-connection errors to the error service
    // Connection errors are shown passively via the cloud icon
    if (result.hasErrors && !result.isConnectionError) {
      for (final error in errors) {
        _errorService.addError(error);
      }
    }

    return result;
  }

  /// Tests the connection to the server.
  Future<bool> testConnection() async {
    final settings = await _accountRepo.loadSettings();
    if (!settings.canSync) return false;

    final email = settings.email!;
    final password = await _accountRepo.getPassword();
    if (password == null) return false;

    try {
      final response = await _makeRequest(
        'GET',
        '${settings.serverUrl}/api/v1/${Uri.encodeComponent(email)}/anga',
        email,
        password,
      );
      return response.statusCode == 200;
    } catch (e) {
      _logger?.e('Connection test failed', e);
      return false;
    }
  }

  Future<_SyncDirResult> _syncAngas(
    String baseUrl,
    String email,
    String password,
  ) async {
    final result = _SyncDirResult();

    try {
      // Get server file list
      final serverFiles = await _fetchFileList(
        '$baseUrl/api/v1/${Uri.encodeComponent(email)}/anga',
        email,
        password,
      );

      // Get local file list
      final localFiles = await _storage.listAngaFiles();

      // Determine what to download and upload
      final toDownload = serverFiles.where((f) => !localFiles.contains(f));
      final toUpload = localFiles.where((f) => !serverFiles.contains(f));

      // Download missing files
      for (final filename in toDownload) {
        try {
          final response = await _makeRequest(
            'GET',
            '$baseUrl/api/v1/${Uri.encodeComponent(email)}/anga/${Uri.encodeComponent(filename)}',
            email,
            password,
          );
          if (response.statusCode == 200) {
            final path = '${_storage.angaPath}/$filename';
            await File(path).writeAsBytes(response.bodyBytes);
            result.downloaded++;
            _logger?.i('[ANGA DOWNLOAD] $filename');
          }
        } catch (e) {
          if (_isConnectionError(e)) {
            result.isConnectionError = true;
            return result;
          }
          result.errors.add('Failed to download $filename: $e');
        }
      }

      // Upload missing files
      for (final filename in toUpload) {
        try {
          final path = '${_storage.angaPath}/$filename';
          final file = File(path);
          final bytes = await file.readAsBytes();
          final contentType = _mimeTypeFor(filename);

          final response = await _uploadFile(
            '$baseUrl/api/v1/${Uri.encodeComponent(email)}/anga/${Uri.encodeComponent(filename)}',
            email,
            password,
            filename,
            bytes,
            contentType,
          );

          if (response.statusCode == 201 || response.statusCode == 200) {
            result.uploaded++;
            _logger?.i('[ANGA UPLOAD] $filename');
          } else if (response.statusCode == 409) {
            // Conflict - file already exists
            _logger?.w('[ANGA SKIP] $filename (already exists on server)');
          } else {
            result.errors.add(
              'Failed to upload $filename: ${response.statusCode}',
            );
          }
        } catch (e) {
          if (_isConnectionError(e)) {
            result.isConnectionError = true;
            return result;
          }
          result.errors.add('Failed to upload $filename: $e');
        }
      }
    } catch (e) {
      if (_isConnectionError(e)) {
        result.isConnectionError = true;
        return result;
      }
      result.errors.add('Anga sync failed: $e');
    }

    return result;
  }

  Future<_SyncDirResult> _syncMeta(
    String baseUrl,
    String email,
    String password,
  ) async {
    final result = _SyncDirResult();

    try {
      // Get server file list
      final serverFiles = await _fetchFileList(
        '$baseUrl/api/v1/${Uri.encodeComponent(email)}/meta',
        email,
        password,
      );

      // Get local file list
      final localFiles = await _storage.listMetaFiles();

      // Determine what to download and upload
      final toDownload = serverFiles.where((f) => !localFiles.contains(f));
      final toUpload = localFiles.where((f) => !serverFiles.contains(f));

      // Download missing files
      for (final filename in toDownload) {
        try {
          final response = await _makeRequest(
            'GET',
            '$baseUrl/api/v1/${Uri.encodeComponent(email)}/meta/${Uri.encodeComponent(filename)}',
            email,
            password,
          );
          if (response.statusCode == 200) {
            final path = '${_storage.metaPath}/$filename';
            await File(path).writeAsBytes(response.bodyBytes);
            result.downloaded++;
            _logger?.i('[META DOWNLOAD] $filename');
          }
        } catch (e) {
          if (_isConnectionError(e)) {
            result.isConnectionError = true;
            return result;
          }
          result.errors.add('Failed to download meta $filename: $e');
        }
      }

      // Upload missing files
      for (final filename in toUpload) {
        try {
          final path = '${_storage.metaPath}/$filename';
          final file = File(path);
          final bytes = await file.readAsBytes();

          final response = await _uploadFile(
            '$baseUrl/api/v1/${Uri.encodeComponent(email)}/meta/${Uri.encodeComponent(filename)}',
            email,
            password,
            filename,
            bytes,
            'application/toml',
          );

          if (response.statusCode == 201 || response.statusCode == 200) {
            result.uploaded++;
            _logger?.i('[META UPLOAD] $filename');
          } else if (response.statusCode == 409) {
            _logger?.w('[META SKIP] $filename (already exists on server)');
          } else {
            result.errors.add(
              'Failed to upload meta $filename: ${response.statusCode}',
            );
          }
        } catch (e) {
          if (_isConnectionError(e)) {
            result.isConnectionError = true;
            return result;
          }
          result.errors.add('Failed to upload meta $filename: $e');
        }
      }
    } catch (e) {
      if (_isConnectionError(e)) {
        result.isConnectionError = true;
        return result;
      }
      result.errors.add('Meta sync failed: $e');
    }

    return result;
  }

  Future<_SyncDirResult> _syncCache(
    String baseUrl,
    String email,
    String password,
  ) async {
    final result = _SyncDirResult();

    try {
      // Get server cache bookmark list
      final serverBookmarks = await _fetchFileList(
        '$baseUrl/api/v1/${Uri.encodeComponent(email)}/cache',
        email,
        password,
      );

      // Get local cache bookmark list
      final localBookmarks = await _storage.listCachedBookmarks();

      // Download missing bookmark caches
      for (final bookmark in serverBookmarks) {
        if (!localBookmarks.contains(bookmark)) {
          // Download all files for this bookmark
          final files = await _fetchFileList(
            '$baseUrl/api/v1/${Uri.encodeComponent(email)}/cache/${Uri.encodeComponent(bookmark)}',
            email,
            password,
          );

          for (final filename in files) {
            try {
              final response = await _makeRequest(
                'GET',
                '$baseUrl/api/v1/${Uri.encodeComponent(email)}/cache/${Uri.encodeComponent(bookmark)}/${Uri.encodeComponent(filename)}',
                email,
                password,
              );
              if (response.statusCode == 200) {
                await _storage.saveCacheFile(
                  bookmark,
                  filename,
                  response.bodyBytes,
                );
                result.downloaded++;
                _logger?.i('[CACHE DOWNLOAD] $bookmark/$filename');
              }
            } catch (e) {
              if (_isConnectionError(e)) {
                result.isConnectionError = true;
                return result;
              }
              result.errors.add(
                'Failed to download cache $bookmark/$filename: $e',
              );
            }
          }
        } else {
          // Sync any missing files for existing bookmark cache
          final serverFiles = await _fetchFileList(
            '$baseUrl/api/v1/${Uri.encodeComponent(email)}/cache/${Uri.encodeComponent(bookmark)}',
            email,
            password,
          );
          final localFiles = await _storage.listCacheFiles(bookmark);
          final toDownload = serverFiles.where((f) => !localFiles.contains(f));

          for (final filename in toDownload) {
            try {
              final response = await _makeRequest(
                'GET',
                '$baseUrl/api/v1/${Uri.encodeComponent(email)}/cache/${Uri.encodeComponent(bookmark)}/${Uri.encodeComponent(filename)}',
                email,
                password,
              );
              if (response.statusCode == 200) {
                await _storage.saveCacheFile(
                  bookmark,
                  filename,
                  response.bodyBytes,
                );
                result.downloaded++;
                _logger?.i('[CACHE DOWNLOAD] $bookmark/$filename');
              }
            } catch (e) {
              if (_isConnectionError(e)) {
                result.isConnectionError = true;
                return result;
              }
              result.errors.add(
                'Failed to download cache $bookmark/$filename: $e',
              );
            }
          }
        }
      }
    } catch (e) {
      if (_isConnectionError(e)) {
        result.isConnectionError = true;
        return result;
      }
      result.errors.add('Cache sync failed: $e');
    }

    return result;
  }

  Future<List<String>> _fetchFileList(
    String url,
    String email,
    String password,
  ) async {
    final response = await _makeRequest('GET', url, email, password);
    if (response.statusCode == 200) {
      return response.body
          .split('\n')
          .map((f) => Uri.decodeComponent(f.trim()))
          .where((f) => f.isNotEmpty)
          .toList();
    }
    return [];
  }

  Future<http.Response> _makeRequest(
    String method,
    String url,
    String email,
    String password,
  ) async {
    final uri = Uri.parse(url);
    final request = http.Request(method, uri);
    request.headers['Authorization'] =
        'Basic ${base64Encode(utf8.encode('$email:$password'))}';

    final client = http.Client();
    try {
      final streamedResponse = await client.send(request);
      return await http.Response.fromStream(streamedResponse);
    } finally {
      client.close();
    }
  }

  Future<http.Response> _uploadFile(
    String url,
    String email,
    String password,
    String filename,
    List<int> bytes,
    String contentType,
  ) async {
    final uri = Uri.parse(url);
    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] =
        'Basic ${base64Encode(utf8.encode('$email:$password'))}';
    request.files.add(
      http.MultipartFile.fromBytes('file', bytes, filename: filename),
    );

    final streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }

  String _mimeTypeFor(String filename) {
    final ext = filename.split('.').last.toLowerCase();
    switch (ext) {
      case 'md':
        return 'text/markdown';
      case 'url':
      case 'txt':
        return 'text/plain';
      case 'json':
        return 'application/json';
      case 'toml':
        return 'application/toml';
      case 'pdf':
        return 'application/pdf';
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'svg':
        return 'image/svg+xml';
      case 'html':
      case 'htm':
        return 'text/html';
      default:
        return 'application/octet-stream';
    }
  }
}

class _SyncDirResult {
  int downloaded = 0;
  int uploaded = 0;
  final List<String> errors = [];
  bool isConnectionError = false;
}

/// Checks if an exception is a connection-related error.
bool _isConnectionError(Object e) {
  if (e is SocketException) return true;
  if (e is http.ClientException) {
    // ClientException wrapping a SocketException
    return e.toString().contains('SocketException');
  }
  return false;
}

@Riverpod(keepAlive: true)
Future<SyncService> syncService(Ref ref) async {
  final storage = await ref.watch(fileStorageServiceProvider.future);
  final accountRepo = await ref.watch(accountRepositoryProvider.future);
  final logger = ref.watch(loggerProvider);
  final errorService = ref.watch(errorServiceProvider.notifier);
  return SyncService(storage, accountRepo, logger, errorService);
}

/// State for sync status
enum SyncStatus { idle, syncing, error }

/// State for server connection status
enum SyncConnectionStatus {
  /// No credentials configured
  notConfigured,

  /// Last sync connected successfully
  connected,

  /// Last sync failed due to connection error
  disconnected,
}

/// Provider for tracking connection status separately from sync status.
@Riverpod(keepAlive: true)
class SyncConnectionStatusNotifier extends _$SyncConnectionStatusNotifier {
  @override
  SyncConnectionStatus build() => SyncConnectionStatus.notConfigured;

  void setConnected() {
    state = SyncConnectionStatus.connected;
  }

  void setDisconnected() {
    state = SyncConnectionStatus.disconnected;
  }

  void setNotConfigured() {
    state = SyncConnectionStatus.notConfigured;
  }
}

/// Convenience provider for reading connection status.
@riverpod
SyncConnectionStatus syncConnectionStatus(Ref ref) {
  return ref.watch(syncConnectionStatusNotifierProvider);
}

/// Notifier for managing sync state and scheduling.
@Riverpod(keepAlive: true)
class SyncController extends _$SyncController {
  Timer? _syncTimer;
  static const _syncInterval = Duration(seconds: 60);

  @override
  SyncStatus build() {
    ref.onDispose(() {
      _syncTimer?.cancel();
    });

    // Start the sync timer
    _startSyncTimer();

    // Listen for connectivity changes to trigger sync
    ref.listen(connectivityStreamProvider, (_, next) {
      next.whenData((isOnline) {
        if (isOnline) {
          _triggerSync();
        }
      });
    });

    return SyncStatus.idle;
  }

  void _startSyncTimer() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(_syncInterval, (_) {
      _triggerSync();
    });
  }

  Future<void> _triggerSync() async {
    final connectivity = ref.read(connectivityServiceProvider);
    if (!connectivity.isOnline) return;

    final settings = await ref.read(accountSettingsNotifierProvider.future);
    if (!settings.canSync) {
      ref
          .read(syncConnectionStatusNotifierProvider.notifier)
          .setNotConfigured();
      return;
    }

    await sync();
  }

  /// Performs a sync and updates state.
  Future<SyncResult> sync() async {
    state = SyncStatus.syncing;

    final connectionNotifier = ref.read(
      syncConnectionStatusNotifierProvider.notifier,
    );

    try {
      final service = await ref.read(syncServiceProvider.future);
      final result = await service.sync();

      // Update connection status
      if (result.isConnectionError) {
        connectionNotifier.setDisconnected();
        state = SyncStatus.idle; // Don't show error state for connection issues
      } else {
        connectionNotifier.setConnected();
        if (result.hasErrors) {
          state = SyncStatus.error;
        } else {
          state = SyncStatus.idle;
        }
      }

      // Refresh angas if anything was downloaded
      if (result.angaDownloaded > 0 || result.metaDownloaded > 0) {
        ref.read(angaRepositoryProvider.notifier).refresh();
      }

      return result;
    } catch (e) {
      // Unexpected error - likely connection issue
      connectionNotifier.setDisconnected();
      state = SyncStatus.idle;
      return SyncResult(isConnectionError: true);
    }
  }

  /// Tests the connection to the server.
  Future<bool> testConnection() async {
    final service = await ref.read(syncServiceProvider.future);
    return await service.testConnection();
  }

  /// Forces a sync immediately.
  Future<SyncResult> forceSync() async {
    return await sync();
  }
}
