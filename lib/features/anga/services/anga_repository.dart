import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaya/features/anga/models/anga.dart';
import 'package:kaya/features/anga/services/file_storage_service.dart';
import 'package:kaya/features/meta/models/anga_meta.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'anga_repository.g.dart';

/// Notifier for managing the list of angas.
@Riverpod(keepAlive: true)
class AngaRepository extends _$AngaRepository {
  @override
  Future<List<Anga>> build() async {
    final storage = await ref.watch(fileStorageServiceProvider.future);
    return await storage.loadAllAngas();
  }

  /// Refreshes the list of angas from storage.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final storage = await ref.read(fileStorageServiceProvider.future);
      return await storage.loadAllAngas();
    });
  }

  /// Adds a bookmark.
  Future<Anga> addBookmark(String url) async {
    final storage = await ref.read(fileStorageServiceProvider.future);
    final anga = await storage.saveBookmark(url);
    await refresh();
    return anga;
  }

  /// Adds a note.
  Future<Anga> addNote(String text) async {
    final storage = await ref.read(fileStorageServiceProvider.future);
    final anga = await storage.saveNote(text);
    await refresh();
    return anga;
  }

  /// Adds a file from a path.
  Future<Anga> addFile(String sourcePath, String originalFilename) async {
    final storage = await ref.read(fileStorageServiceProvider.future);
    final anga = await storage.saveFile(sourcePath, originalFilename);
    await refresh();
    return anga;
  }

  /// Adds a file from bytes.
  Future<Anga> addFileBytes(List<int> bytes, String originalFilename) async {
    final storage = await ref.read(fileStorageServiceProvider.future);
    final anga = await storage.saveFileBytes(bytes, originalFilename);
    await refresh();
    return anga;
  }

  /// Gets an anga by filename.
  Future<Anga?> getAnga(String filename) async {
    final storage = await ref.read(fileStorageServiceProvider.future);
    return await storage.loadAnga(filename);
  }

  /// Gets the metadata for an anga.
  Future<AngaMeta?> getMetaForAnga(String angaFilename) async {
    final storage = await ref.read(fileStorageServiceProvider.future);
    return await storage.loadMetaForAnga(angaFilename);
  }

  /// Saves metadata for an anga.
  Future<AngaMeta> saveMeta(
    String angaFilename, {
    required List<String> tags,
    String? note,
  }) async {
    final storage = await ref.read(fileStorageServiceProvider.future);
    return await storage.saveMeta(angaFilename, tags: tags, note: note);
  }

  /// Deletes an anga.
  Future<void> deleteAnga(String filename) async {
    final storage = await ref.read(fileStorageServiceProvider.future);
    await storage.deleteAnga(filename);
    await refresh();
  }
}

/// Provider for a single anga by filename.
@riverpod
Future<Anga?> angaByFilename(Ref ref, String filename) async {
  final storage = await ref.watch(fileStorageServiceProvider.future);
  return await storage.loadAnga(filename);
}

/// Provider for metadata of a specific anga.
@riverpod
Future<AngaMeta?> metaForAnga(Ref ref, String angaFilename) async {
  final storage = await ref.watch(fileStorageServiceProvider.future);
  return await storage.loadMetaForAnga(angaFilename);
}
