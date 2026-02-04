import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaya/core/services/logger_service.dart';
import 'package:kaya/core/utils/datetime_utils.dart';
import 'package:kaya/features/anga/models/anga.dart';
import 'package:kaya/features/meta/models/anga_meta.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'file_storage_service.g.dart';

/// Service for managing file storage in the Kaya directories.
///
/// Directory structure:
/// - /kaya/anga/  - bookmarks, notes, and files
/// - /kaya/meta/  - metadata TOML files
/// - /kaya/cache/ - cached favicons (download-only from server)
/// - /kaya/words/ - extracted plaintext for search (download-only from server)
class FileStorageService {
  final String _rootPath;
  final LoggerService? _logger;

  FileStorageService(this._rootPath, this._logger);

  String get angaPath => '$_rootPath/anga';
  String get metaPath => '$_rootPath/meta';
  String get cachePath => '$_rootPath/cache';
  String get wordsPath => '$_rootPath/words';

  /// Ensures all required directories exist.
  Future<void> ensureDirectories() async {
    await Directory(angaPath).create(recursive: true);
    await Directory(metaPath).create(recursive: true);
    await Directory(cachePath).create(recursive: true);
    await Directory(wordsPath).create(recursive: true);
  }

  // ============================================================================
  // Anga Operations
  // ============================================================================

  /// Lists all anga files.
  Future<List<String>> listAngaFiles() async {
    final dir = Directory(angaPath);
    if (!await dir.exists()) return [];

    final files = await dir.list().toList();
    return files
        .whereType<File>()
        .map((f) => f.path.split('/').last)
        .where((name) => !name.startsWith('.'))
        .toList();
  }

  /// Loads all angas.
  Future<List<Anga>> loadAllAngas() async {
    final files = await listAngaFiles();
    final angas = <Anga>[];

    for (final filename in files) {
      final anga = await loadAnga(filename);
      if (anga != null) {
        angas.add(anga);
      }
    }

    // Sort by creation date, newest first
    angas.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return angas;
  }

  /// Loads a single anga by filename.
  Future<Anga?> loadAnga(String filename) async {
    final path = '$angaPath/$filename';
    final file = File(path);

    if (!await file.exists()) return null;

    try {
      final stat = await file.stat();
      String? content;

      // Load text content for bookmarks and notes
      if (filename.endsWith('.url') ||
          filename.endsWith('.md') ||
          filename.endsWith('.txt')) {
        content = await file.readAsString();
      }

      return Anga.fromPath(path, content: content, fileSize: stat.size);
    } catch (e) {
      _logger?.e('Error loading anga $filename', e);
      return null;
    }
  }

  /// Saves a bookmark.
  Future<Anga> saveBookmark(String url) async {
    await ensureDirectories();

    final filename = _uniqueFilename(generateBookmarkFilename(url));
    final path = '$angaPath/$filename';
    final content = createBookmarkContent(url);

    await File(path).writeAsString(content);
    _logger?.i('Saved bookmark: $filename');

    return Anga.fromPath(path, content: content);
  }

  /// Saves a note.
  Future<Anga> saveNote(String text) async {
    await ensureDirectories();

    final filename = _uniqueFilename(generateNoteFilename());
    final path = '$angaPath/$filename';

    await File(path).writeAsString(text);
    _logger?.i('Saved note: $filename');

    return Anga.fromPath(path, content: text);
  }

  /// Saves a file.
  Future<Anga> saveFile(String sourcePath, String originalFilename) async {
    await ensureDirectories();

    final filename = _uniqueFilename(generateFileFilename(originalFilename));
    final destPath = '$angaPath/$filename';

    await File(sourcePath).copy(destPath);
    _logger?.i('Saved file: $filename');

    return Anga.fromPath(destPath);
  }

  /// Saves raw bytes as a file.
  Future<Anga> saveFileBytes(List<int> bytes, String originalFilename) async {
    await ensureDirectories();

    final filename = _uniqueFilename(generateFileFilename(originalFilename));
    final path = '$angaPath/$filename';

    await File(path).writeAsBytes(bytes);
    _logger?.i('Saved file: $filename');

    return Anga.fromPath(path);
  }

  /// Checks if a filename exists and generates a unique one if needed.
  String _uniqueFilename(String filename) {
    final file = File('$angaPath/$filename');
    if (!file.existsSync()) return filename;

    // Use nanosecond timestamp for uniqueness
    final parts = filename.split('-');
    if (parts.length >= 2) {
      final timestamp = DateTimeUtils.generateTimestampWithNanos();
      final rest = parts.sublist(1).join('-');
      return '$timestamp-$rest';
    }

    return filename;
  }

  /// Reads file content.
  Future<String?> readFileContent(String path) async {
    final file = File(path);
    if (!await file.exists()) return null;
    return await file.readAsString();
  }

  /// Reads file bytes.
  Future<List<int>?> readFileBytes(String path) async {
    final file = File(path);
    if (!await file.exists()) return null;
    return await file.readAsBytes();
  }

  /// Deletes an anga file.
  Future<void> deleteAnga(String filename) async {
    final file = File('$angaPath/$filename');
    if (await file.exists()) {
      await file.delete();
      _logger?.i('Deleted anga: $filename');
    }
  }

  // ============================================================================
  // Meta Operations
  // ============================================================================

  /// Lists all meta files.
  Future<List<String>> listMetaFiles() async {
    final dir = Directory(metaPath);
    if (!await dir.exists()) return [];

    final files = await dir.list().toList();
    return files
        .whereType<File>()
        .map((f) => f.path.split('/').last)
        .where((name) => name.endsWith('.toml') && !name.startsWith('.'))
        .toList();
  }

  /// Loads all metadata.
  Future<List<AngaMeta>> loadAllMeta() async {
    final files = await listMetaFiles();
    final metas = <AngaMeta>[];

    for (final filename in files) {
      final meta = await loadMeta(filename);
      if (meta != null) {
        metas.add(meta);
      }
    }

    return metas;
  }

  /// Loads metadata for a specific anga filename.
  /// Returns the most recent metadata file for that anga.
  Future<AngaMeta?> loadMetaForAnga(String angaFilename) async {
    final allMeta = await loadAllMeta();
    final matching = allMeta
        .where((m) => m.angaFilename == angaFilename)
        .toList();

    if (matching.isEmpty) return null;

    // Sort by creation date and return most recent
    matching.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return matching.first;
  }

  /// Loads all metadata files for a specific anga (for search indexing).
  Future<List<AngaMeta>> loadAllMetaForAnga(String angaFilename) async {
    final allMeta = await loadAllMeta();
    return allMeta.where((m) => m.angaFilename == angaFilename).toList();
  }

  /// Loads a single meta file.
  Future<AngaMeta?> loadMeta(String filename) async {
    final path = '$metaPath/$filename';
    final file = File(path);

    if (!await file.exists()) return null;

    try {
      final content = await file.readAsString();
      return AngaMeta.fromToml(path, content);
    } catch (e) {
      _logger?.e('Error loading meta $filename', e);
      return null;
    }
  }

  /// Saves metadata for an anga.
  Future<AngaMeta> saveMeta(
    String angaFilename, {
    required List<String> tags,
    String? note,
  }) async {
    await ensureDirectories();

    final filename = generateMetaFilename('meta');
    final path = '$metaPath/$filename';

    final meta = AngaMeta(
      metaFilename: filename,
      path: path,
      angaFilename: angaFilename,
      tags: tags,
      note: note,
      createdAt: DateTime.now().toUtc(),
    );

    await File(path).writeAsString(meta.toToml());
    _logger?.i('Saved meta: $filename for $angaFilename');

    return meta;
  }

  // ============================================================================
  // Cache Operations (download-only)
  // ============================================================================

  /// Lists all cached bookmark directories.
  Future<List<String>> listCachedBookmarks() async {
    final dir = Directory(cachePath);
    if (!await dir.exists()) return [];

    final dirs = await dir.list().toList();
    return dirs
        .whereType<Directory>()
        .map((d) => d.path.split('/').last)
        .where((name) => !name.startsWith('.'))
        .toList();
  }

  /// Lists files in a cached bookmark directory.
  Future<List<String>> listCacheFiles(String bookmarkName) async {
    final dir = Directory('$cachePath/$bookmarkName');
    if (!await dir.exists()) return [];

    final files = await dir.list().toList();
    return files
        .whereType<File>()
        .map((f) => f.path.split('/').last)
        .where((name) => !name.startsWith('.'))
        .toList();
  }

  /// Gets the path to a cached file.
  String getCacheFilePath(String bookmarkName, String filename) {
    return '$cachePath/$bookmarkName/$filename';
  }

  /// Checks if cache exists for a bookmark.
  Future<bool> hasCacheForBookmark(String bookmarkFilename) async {
    // Remove .url extension to get the cache directory name
    final cacheDirName = bookmarkFilename.replaceAll('.url', '');
    final dir = Directory('$cachePath/$cacheDirName');
    return await dir.exists();
  }

  /// Gets HTML content from cache for a bookmark.
  Future<String?> getCachedHtml(String bookmarkFilename) async {
    final cacheDirName = bookmarkFilename.replaceAll('.url', '');
    final files = await listCacheFiles(cacheDirName);

    // Look for index.html or similar
    for (final filename in files) {
      if (filename.endsWith('.html') || filename.endsWith('.htm')) {
        final content = await readFileContent(
          '$cachePath/$cacheDirName/$filename',
        );
        if (content != null) return content;
      }
    }

    return null;
  }

  /// Saves a cache file (used during sync download).
  Future<void> saveCacheFile(
    String bookmarkName,
    String filename,
    List<int> bytes,
  ) async {
    final dir = Directory('$cachePath/$bookmarkName');
    await dir.create(recursive: true);

    final path = '${dir.path}/$filename';
    await File(path).writeAsBytes(bytes);
  }

  /// Gets the favicon path for a bookmark, if cached.
  Future<String?> getCachedFaviconPath(String bookmarkFilename) async {
    final cacheDirName = bookmarkFilename.replaceAll('.url', '');
    final files = await listCacheFiles(cacheDirName);

    // Look for favicon
    for (final filename in files) {
      if (filename.contains('favicon') ||
          filename == 'icon.png' ||
          filename == 'icon.ico') {
        return '$cachePath/$cacheDirName/$filename';
      }
    }

    return null;
  }

  /// Checks if a bookmark already has a favicon or a `.nofavicon` marker,
  /// meaning we don't need to query the server for it again.
  Future<bool> hasFaviconOrMarker(String bookmarkName) async {
    final dir = Directory('$cachePath/$bookmarkName');
    if (!await dir.exists()) return false;

    final files = await dir.list().toList();
    for (final entity in files.whereType<File>()) {
      final name = entity.path.split('/').last;
      if (name == '.nofavicon' ||
          name.contains('favicon') ||
          name == 'icon.png' ||
          name == 'icon.ico') {
        return true;
      }
    }

    return false;
  }

  /// Creates a `.nofavicon` marker file to indicate that the server's cache
  /// for this bookmark has no favicon, so we don't re-check on future syncs.
  Future<void> createNoFaviconMarker(String bookmarkName) async {
    final dir = Directory('$cachePath/$bookmarkName');
    await dir.create(recursive: true);
    await File('${dir.path}/.nofavicon').writeAsString('');
  }

  // ============================================================================
  // Words Operations (download-only, extracted plaintext for search)
  // ============================================================================

  /// Derives the words directory name from an anga filename.
  /// The server stores words directories with the full anga filename (including extension).
  String _wordsAngaName(String angaFilename) {
    return angaFilename;
  }

  /// Lists all anga directories under /kaya/words/.
  Future<List<String>> listWordsAngas() async {
    final dir = Directory(wordsPath);
    if (!await dir.exists()) return [];

    final dirs = await dir.list().toList();
    return dirs
        .whereType<Directory>()
        .map((d) => d.path.split('/').last)
        .where((name) => !name.startsWith('.'))
        .toList();
  }

  /// Lists files in a words anga directory.
  Future<List<String>> listWordsFiles(String angaName) async {
    final dir = Directory('$wordsPath/$angaName');
    if (!await dir.exists()) return [];

    final files = await dir.list().toList();
    return files
        .whereType<File>()
        .map((f) => f.path.split('/').last)
        .where((name) => !name.startsWith('.'))
        .toList();
  }

  /// Saves a words file (used during sync download).
  Future<void> saveWordsFile(
    String angaName,
    String filename,
    List<int> bytes,
  ) async {
    final dir = Directory('$wordsPath/$angaName');
    await dir.create(recursive: true);

    final path = '${dir.path}/$filename';
    await File(path).writeAsBytes(bytes);
  }

  /// Gets the concatenated plaintext from words files for an anga.
  /// Returns null if no words exist for this anga.
  Future<String?> getWordsText(String angaFilename) async {
    final angaName = _wordsAngaName(angaFilename);
    final files = await listWordsFiles(angaName);

    if (files.isEmpty) return null;

    final parts = <String>[];
    for (final filename in files) {
      final content = await readFileContent('$wordsPath/$angaName/$filename');
      if (content != null && content.isNotEmpty) {
        parts.add(content);
      }
    }

    if (parts.isEmpty) return null;
    return parts.join(' ');
  }
}

@Riverpod(keepAlive: true)
Future<String> kayaRootPath(Ref ref) async {
  final appDir = await getApplicationSupportDirectory();
  return '${appDir.path}/kaya';
}

@Riverpod(keepAlive: true)
Future<FileStorageService> fileStorageService(Ref ref) async {
  final rootPath = await ref.watch(kayaRootPathProvider.future);
  final logger = ref.watch(loggerProvider);
  final service = FileStorageService(rootPath, logger);
  await service.ensureDirectories();
  return service;
}
