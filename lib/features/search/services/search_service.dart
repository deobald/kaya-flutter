import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuzzy_bolt/fuzzy_bolt.dart';
import 'package:kaya/features/anga/models/anga.dart';
import 'package:kaya/features/anga/models/anga_type.dart';
import 'package:kaya/features/anga/services/anga_repository.dart';
import 'package:kaya/features/anga/services/file_storage_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'search_service.g.dart';

/// Represents a search result with score.
class SearchResult {
  final Anga anga;
  final double score;

  SearchResult({required this.anga, required this.score});
}

final _fuzzyBolt = FuzzyBolt();

/// Service for searching angas using fuzzy matching.
class SearchService {
  final FileStorageService _storage;

  // Cached search corpus - maps anga filename to searchable text
  final Map<String, String> _searchCorpus = {};

  SearchService(this._storage);

  /// Builds or updates the search index.
  Future<void> buildIndex(List<Anga> angas) async {
    _searchCorpus.clear();

    for (final anga in angas) {
      final searchText = await _buildSearchText(anga);
      _searchCorpus[anga.filename] = searchText;
    }
  }

  /// Builds searchable text for an anga.
  Future<String> _buildSearchText(Anga anga) async {
    final parts = <String>[];

    // Add filename
    parts.add(anga.filename);

    // Add display title
    parts.add(anga.displayTitle);

    // Add content for text-based angas
    if (anga.content != null) {
      parts.add(anga.content!);
    }

    // Add URL for bookmarks
    if (anga.url != null) {
      parts.add(anga.url!);
    }

    // Add cached content for bookmarks
    if (anga.type == AngaType.bookmark) {
      final cachedHtml = await _storage.getCachedHtml(anga.filename);
      if (cachedHtml != null) {
        // Strip HTML tags for searching
        final strippedText = _stripHtml(cachedHtml);
        parts.add(strippedText);
      }
    }

    // Add metadata tags and notes
    final allMeta = await _storage.loadAllMetaForAnga(anga.filename);
    for (final meta in allMeta) {
      parts.addAll(meta.tags);
      if (meta.note != null) {
        parts.add(meta.note!);
      }
    }

    // TODO: Add PDF text extraction when syncfusion_flutter_pdf is properly configured
    // For now, PDFs are searchable by filename only

    return parts.join(' ').toLowerCase();
  }

  /// Strips HTML tags from content.
  String _stripHtml(String html) {
    return html
        .replaceAll(RegExp(r'<script[^>]*>[\s\S]*?</script>'), '')
        .replaceAll(RegExp(r'<style[^>]*>[\s\S]*?</style>'), '')
        .replaceAll(RegExp(r'<[^>]+>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Searches for angas matching the query.
  Future<List<SearchResult>> search(String query, List<Anga> angas) async {
    if (query.isEmpty) {
      return angas.map((a) => SearchResult(anga: a, score: 1.0)).toList();
    }

    final results = <SearchResult>[];
    final queryLower = query.toLowerCase();

    // Create a list of items to search
    final searchItems = <_SearchItem>[];
    for (final anga in angas) {
      final searchText = _searchCorpus[anga.filename] ?? anga.filename;
      searchItems.add(_SearchItem(anga: anga, searchText: searchText));
    }

    // First, do a simple substring match for exact containment
    // This handles cases like searching "town" in "https://kaya.town"
    for (final item in searchItems) {
      if (item.searchText.contains(queryLower)) {
        results.add(SearchResult(
          anga: item.anga,
          score: 1.0, // Exact substring match gets highest score
        ));
      }
    }

    // If we found exact matches, return them
    if (results.isNotEmpty) {
      return results;
    }

    // Fall back to fuzzy search for typo tolerance
    final fuzzyResults = await _fuzzyBolt.searchWithRanks(
      dataset: searchItems.map((i) => i.searchText).toList(),
      query: queryLower,
    );

    // Map results back to angas
    for (final result in fuzzyResults) {
      final matchedText = result['result'] as String?;
      final rank = (result['rank'] as num?)?.toDouble() ?? 0.0;

      if (matchedText == null) continue;

      // Find the matching anga by comparing lowercased search text
      final matchIndex = searchItems.indexWhere((item) =>
        item.searchText == matchedText);

      if (matchIndex >= 0) {
        results.add(SearchResult(
          anga: searchItems[matchIndex].anga,
          score: rank,
        ));
      }
    }

    // Sort by score (highest first)
    results.sort((a, b) => b.score.compareTo(a.score));

    return results;
  }

  /// Updates the index for a single anga.
  Future<void> updateIndex(Anga anga) async {
    final searchText = await _buildSearchText(anga);
    _searchCorpus[anga.filename] = searchText;
  }

  /// Removes an anga from the index.
  void removeFromIndex(String filename) {
    _searchCorpus.remove(filename);
  }
}

class _SearchItem {
  final Anga anga;
  final String searchText;

  _SearchItem({required this.anga, required this.searchText});
}

@Riverpod(keepAlive: true)
Future<SearchService> searchService(Ref ref) async {
  final storage = await ref.watch(fileStorageServiceProvider.future);
  final service = SearchService(storage);

  // Build initial index when angas are loaded
  final angas = await ref.watch(angaRepositoryProvider.future);
  await service.buildIndex(angas);

  return service;
}

/// Provider for search results.
@riverpod
Future<List<SearchResult>> searchResults(Ref ref, String query) async {
  final service = await ref.watch(searchServiceProvider.future);
  final angas = await ref.watch(angaRepositoryProvider.future);
  return await service.search(query, angas);
}

/// Provider for filtered angas based on search query.
@riverpod
Future<List<Anga>> filteredAngas(Ref ref, String query) async {
  if (query.isEmpty) {
    return await ref.watch(angaRepositoryProvider.future);
  }

  final results = await ref.watch(searchResultsProvider(query).future);
  return results.map((r) => r.anga).toList();
}
