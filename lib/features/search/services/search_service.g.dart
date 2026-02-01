// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$searchServiceHash() => r'fe2accd0776c02dfe0047c5027ea64b279a32bd0';

/// See also [searchService].
@ProviderFor(searchService)
final searchServiceProvider = FutureProvider<SearchService>.internal(
  searchService,
  name: r'searchServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$searchServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SearchServiceRef = FutureProviderRef<SearchService>;
String _$searchResultsHash() => r'43553ff7d969ecd2dcec5d6ffa18ca527bc946ea';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Provider for search results.
///
/// Copied from [searchResults].
@ProviderFor(searchResults)
const searchResultsProvider = SearchResultsFamily();

/// Provider for search results.
///
/// Copied from [searchResults].
class SearchResultsFamily extends Family<AsyncValue<List<SearchResult>>> {
  /// Provider for search results.
  ///
  /// Copied from [searchResults].
  const SearchResultsFamily();

  /// Provider for search results.
  ///
  /// Copied from [searchResults].
  SearchResultsProvider call(String query) {
    return SearchResultsProvider(query);
  }

  @override
  SearchResultsProvider getProviderOverride(
    covariant SearchResultsProvider provider,
  ) {
    return call(provider.query);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'searchResultsProvider';
}

/// Provider for search results.
///
/// Copied from [searchResults].
class SearchResultsProvider
    extends AutoDisposeFutureProvider<List<SearchResult>> {
  /// Provider for search results.
  ///
  /// Copied from [searchResults].
  SearchResultsProvider(String query)
    : this._internal(
        (ref) => searchResults(ref as SearchResultsRef, query),
        from: searchResultsProvider,
        name: r'searchResultsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$searchResultsHash,
        dependencies: SearchResultsFamily._dependencies,
        allTransitiveDependencies:
            SearchResultsFamily._allTransitiveDependencies,
        query: query,
      );

  SearchResultsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.query,
  }) : super.internal();

  final String query;

  @override
  Override overrideWith(
    FutureOr<List<SearchResult>> Function(SearchResultsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SearchResultsProvider._internal(
        (ref) => create(ref as SearchResultsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        query: query,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<SearchResult>> createElement() {
    return _SearchResultsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SearchResultsProvider && other.query == query;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, query.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SearchResultsRef on AutoDisposeFutureProviderRef<List<SearchResult>> {
  /// The parameter `query` of this provider.
  String get query;
}

class _SearchResultsProviderElement
    extends AutoDisposeFutureProviderElement<List<SearchResult>>
    with SearchResultsRef {
  _SearchResultsProviderElement(super.provider);

  @override
  String get query => (origin as SearchResultsProvider).query;
}

String _$filteredAngasHash() => r'05ba4684480b36bf90027704f2b11e33733deb81';

/// Provider for filtered angas based on search query.
///
/// Copied from [filteredAngas].
@ProviderFor(filteredAngas)
const filteredAngasProvider = FilteredAngasFamily();

/// Provider for filtered angas based on search query.
///
/// Copied from [filteredAngas].
class FilteredAngasFamily extends Family<AsyncValue<List<Anga>>> {
  /// Provider for filtered angas based on search query.
  ///
  /// Copied from [filteredAngas].
  const FilteredAngasFamily();

  /// Provider for filtered angas based on search query.
  ///
  /// Copied from [filteredAngas].
  FilteredAngasProvider call(String query) {
    return FilteredAngasProvider(query);
  }

  @override
  FilteredAngasProvider getProviderOverride(
    covariant FilteredAngasProvider provider,
  ) {
    return call(provider.query);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'filteredAngasProvider';
}

/// Provider for filtered angas based on search query.
///
/// Copied from [filteredAngas].
class FilteredAngasProvider extends AutoDisposeFutureProvider<List<Anga>> {
  /// Provider for filtered angas based on search query.
  ///
  /// Copied from [filteredAngas].
  FilteredAngasProvider(String query)
    : this._internal(
        (ref) => filteredAngas(ref as FilteredAngasRef, query),
        from: filteredAngasProvider,
        name: r'filteredAngasProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$filteredAngasHash,
        dependencies: FilteredAngasFamily._dependencies,
        allTransitiveDependencies:
            FilteredAngasFamily._allTransitiveDependencies,
        query: query,
      );

  FilteredAngasProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.query,
  }) : super.internal();

  final String query;

  @override
  Override overrideWith(
    FutureOr<List<Anga>> Function(FilteredAngasRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FilteredAngasProvider._internal(
        (ref) => create(ref as FilteredAngasRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        query: query,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Anga>> createElement() {
    return _FilteredAngasProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FilteredAngasProvider && other.query == query;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, query.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FilteredAngasRef on AutoDisposeFutureProviderRef<List<Anga>> {
  /// The parameter `query` of this provider.
  String get query;
}

class _FilteredAngasProviderElement
    extends AutoDisposeFutureProviderElement<List<Anga>>
    with FilteredAngasRef {
  _FilteredAngasProviderElement(super.provider);

  @override
  String get query => (origin as FilteredAngasProvider).query;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
