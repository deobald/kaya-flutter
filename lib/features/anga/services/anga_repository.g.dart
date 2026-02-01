// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'anga_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$angaByFilenameHash() => r'b0fdc4822007166efcb7396c5a12e8ed4144554e';

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

/// Provider for a single anga by filename.
///
/// Copied from [angaByFilename].
@ProviderFor(angaByFilename)
const angaByFilenameProvider = AngaByFilenameFamily();

/// Provider for a single anga by filename.
///
/// Copied from [angaByFilename].
class AngaByFilenameFamily extends Family<AsyncValue<Anga?>> {
  /// Provider for a single anga by filename.
  ///
  /// Copied from [angaByFilename].
  const AngaByFilenameFamily();

  /// Provider for a single anga by filename.
  ///
  /// Copied from [angaByFilename].
  AngaByFilenameProvider call(String filename) {
    return AngaByFilenameProvider(filename);
  }

  @override
  AngaByFilenameProvider getProviderOverride(
    covariant AngaByFilenameProvider provider,
  ) {
    return call(provider.filename);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'angaByFilenameProvider';
}

/// Provider for a single anga by filename.
///
/// Copied from [angaByFilename].
class AngaByFilenameProvider extends AutoDisposeFutureProvider<Anga?> {
  /// Provider for a single anga by filename.
  ///
  /// Copied from [angaByFilename].
  AngaByFilenameProvider(String filename)
    : this._internal(
        (ref) => angaByFilename(ref as AngaByFilenameRef, filename),
        from: angaByFilenameProvider,
        name: r'angaByFilenameProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$angaByFilenameHash,
        dependencies: AngaByFilenameFamily._dependencies,
        allTransitiveDependencies:
            AngaByFilenameFamily._allTransitiveDependencies,
        filename: filename,
      );

  AngaByFilenameProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.filename,
  }) : super.internal();

  final String filename;

  @override
  Override overrideWith(
    FutureOr<Anga?> Function(AngaByFilenameRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AngaByFilenameProvider._internal(
        (ref) => create(ref as AngaByFilenameRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        filename: filename,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Anga?> createElement() {
    return _AngaByFilenameProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AngaByFilenameProvider && other.filename == filename;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, filename.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AngaByFilenameRef on AutoDisposeFutureProviderRef<Anga?> {
  /// The parameter `filename` of this provider.
  String get filename;
}

class _AngaByFilenameProviderElement
    extends AutoDisposeFutureProviderElement<Anga?>
    with AngaByFilenameRef {
  _AngaByFilenameProviderElement(super.provider);

  @override
  String get filename => (origin as AngaByFilenameProvider).filename;
}

String _$metaForAngaHash() => r'ab9e9dc5f2ca299dc362075e1b2fc53cb91d5d79';

/// Provider for metadata of a specific anga.
///
/// Copied from [metaForAnga].
@ProviderFor(metaForAnga)
const metaForAngaProvider = MetaForAngaFamily();

/// Provider for metadata of a specific anga.
///
/// Copied from [metaForAnga].
class MetaForAngaFamily extends Family<AsyncValue<AngaMeta?>> {
  /// Provider for metadata of a specific anga.
  ///
  /// Copied from [metaForAnga].
  const MetaForAngaFamily();

  /// Provider for metadata of a specific anga.
  ///
  /// Copied from [metaForAnga].
  MetaForAngaProvider call(String angaFilename) {
    return MetaForAngaProvider(angaFilename);
  }

  @override
  MetaForAngaProvider getProviderOverride(
    covariant MetaForAngaProvider provider,
  ) {
    return call(provider.angaFilename);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'metaForAngaProvider';
}

/// Provider for metadata of a specific anga.
///
/// Copied from [metaForAnga].
class MetaForAngaProvider extends AutoDisposeFutureProvider<AngaMeta?> {
  /// Provider for metadata of a specific anga.
  ///
  /// Copied from [metaForAnga].
  MetaForAngaProvider(String angaFilename)
    : this._internal(
        (ref) => metaForAnga(ref as MetaForAngaRef, angaFilename),
        from: metaForAngaProvider,
        name: r'metaForAngaProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$metaForAngaHash,
        dependencies: MetaForAngaFamily._dependencies,
        allTransitiveDependencies: MetaForAngaFamily._allTransitiveDependencies,
        angaFilename: angaFilename,
      );

  MetaForAngaProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.angaFilename,
  }) : super.internal();

  final String angaFilename;

  @override
  Override overrideWith(
    FutureOr<AngaMeta?> Function(MetaForAngaRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MetaForAngaProvider._internal(
        (ref) => create(ref as MetaForAngaRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        angaFilename: angaFilename,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<AngaMeta?> createElement() {
    return _MetaForAngaProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MetaForAngaProvider && other.angaFilename == angaFilename;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, angaFilename.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MetaForAngaRef on AutoDisposeFutureProviderRef<AngaMeta?> {
  /// The parameter `angaFilename` of this provider.
  String get angaFilename;
}

class _MetaForAngaProviderElement
    extends AutoDisposeFutureProviderElement<AngaMeta?>
    with MetaForAngaRef {
  _MetaForAngaProviderElement(super.provider);

  @override
  String get angaFilename => (origin as MetaForAngaProvider).angaFilename;
}

String _$angaRepositoryHash() => r'8f19e515f0ace797d8ac6490e45a94bd75339564';

/// Notifier for managing the list of angas.
///
/// Copied from [AngaRepository].
@ProviderFor(AngaRepository)
final angaRepositoryProvider =
    AsyncNotifierProvider<AngaRepository, List<Anga>>.internal(
      AngaRepository.new,
      name: r'angaRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$angaRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AngaRepository = AsyncNotifier<List<Anga>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
