import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaya/core/services/logger_service.dart';

import 'package:kaya/features/anga/services/anga_repository.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'share_receiver_service.g.dart';

/// Service for handling content shared to Kaya from other apps.
class ShareReceiverService {
  final LoggerService? _logger;
  final Ref _ref;
  StreamSubscription<List<SharedMediaFile>>? _mediaSubscription;
  final Set<String> _processedMediaIds = {};
  bool _isProcessing = false;

  ShareReceiverService(this._logger, this._ref);

  /// Initializes the share handler and processes any initial shared content.
  Future<void> init() async {
    // Listen for incoming media/text while app is running
    _mediaSubscription = ReceiveSharingIntent.instance.getMediaStream().listen(
      (List<SharedMediaFile> files) async {
        await _processSharedMedia(files);
      },
    );

    // Check for initial shared content (cold start)
    final initialMedia = await ReceiveSharingIntent.instance.getInitialMedia();
    if (initialMedia.isNotEmpty) {
      await _processSharedMedia(initialMedia);
    }

    // Reset the intent after processing
    ReceiveSharingIntent.instance.reset();
  }

  /// Generates a unique ID for shared media to detect duplicates.
  String _getMediaId(List<SharedMediaFile> files) {
    return files.map((f) => '${f.type.name}:${f.path}').join('|');
  }

  /// Processes shared media files (includes text and URLs via SharedMediaType).
  Future<void> _processSharedMedia(List<SharedMediaFile> files) async {
    if (files.isEmpty) return;

    // Deduplicate
    final mediaId = _getMediaId(files);
    if (_processedMediaIds.contains(mediaId)) {
      _logger?.i('Skipping duplicate shared content (already processed)');
      return;
    }

    // Prevent concurrent processing
    if (_isProcessing) {
      _logger?.i('Skipping shared content (already processing)');
      return;
    }
    _isProcessing = true;
    _processedMediaIds.add(mediaId);

    _logger?.i('Received shared media: ${files.length} item(s)');

    final repo = _ref.read(angaRepositoryProvider.notifier);
    final processedPaths = <String>{};

    for (final file in files) {
      final path = file.path;

      // Skip if we've already processed this path in this batch
      if (processedPaths.contains(path)) {
        _logger?.i('Skipping duplicate item: $path');
        continue;
      }
      processedPaths.add(path);

      await _processSharedItem(file, repo);
    }

    _isProcessing = false;
  }

  /// Processes a single shared item based on its type.
  Future<void> _processSharedItem(SharedMediaFile file, AngaRepository repo) async {
    final path = file.path;
    final type = file.type;

    _logger?.i('Processing shared item: type=${type.name}, path=$path');

    switch (type) {
      case SharedMediaType.url:
        // URL shared directly - path contains the URL
        _logger?.i('Processing shared URL: $path');
        await repo.addBookmark(path);

      case SharedMediaType.text:
        // Text shared - path contains the text content
        final text = path.trim();
        if (_isUrl(text)) {
          _logger?.i('Processing text as URL: $text');
          await repo.addBookmark(text);
        } else {
          _logger?.i('Processing text as note');
          await repo.addNote(text);
        }

      case SharedMediaType.image:
      case SharedMediaType.video:
      case SharedMediaType.file:
        // File shared - path is the file path
        await _processFile(path, repo);
    }
  }

  /// Determines if text is a URL.
  bool _isUrl(String text) {
    if (text.startsWith('http://') || text.startsWith('https://')) {
      try {
        final uri = Uri.parse(text);
        return uri.hasScheme && uri.host.isNotEmpty;
      } catch (_) {
        return false;
      }
    }

    if (text.startsWith('www.')) {
      return true;
    }

    return false;
  }

  /// Processes a file.
  Future<void> _processFile(String path, AngaRepository repo) async {
    final file = File(path);
    if (!await file.exists()) {
      _logger?.w('Shared file does not exist: $path');
      return;
    }

    final originalFilename = path.split('/').last;
    _logger?.i('Processing shared file: $originalFilename');

    // Check if it's a text file that might contain a URL
    if (originalFilename.endsWith('.txt')) {
      final content = await file.readAsString();
      final trimmed = content.trim();
      if (_isUrl(trimmed)) {
        await repo.addBookmark(trimmed);
        return;
      }
    }

    // Save as file
    await repo.addFile(path, originalFilename);
  }

  void dispose() {
    _mediaSubscription?.cancel();
  }
}

@Riverpod(keepAlive: true)
ShareReceiverService shareReceiverService(Ref ref) {
  final logger = ref.watch(loggerProvider);
  final service = ShareReceiverService(logger, ref);
  service.init();
  ref.onDispose(() => service.dispose());
  return service;
}
