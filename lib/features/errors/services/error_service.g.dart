// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'error_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$hasErrorsHash() => r'189ffaecc34f583d817777610ac3c53b4a3a1daa';

/// Provider for whether there are any active errors
///
/// Copied from [hasErrors].
@ProviderFor(hasErrors)
final hasErrorsProvider = AutoDisposeProvider<bool>.internal(
  hasErrors,
  name: r'hasErrorsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$hasErrorsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HasErrorsRef = AutoDisposeProviderRef<bool>;
String _$errorCountHash() => r'4dd6f40770ba4403b34cf374d5d3d7d3cfa347fe';

/// Provider for error count
///
/// Copied from [errorCount].
@ProviderFor(errorCount)
final errorCountProvider = AutoDisposeProvider<int>.internal(
  errorCount,
  name: r'errorCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$errorCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ErrorCountRef = AutoDisposeProviderRef<int>;
String _$errorServiceHash() => r'c423ae8b0f0285c7debf9b175b151311ac2a00a7';

/// Service to track and manage application errors.
/// Errors are kept in memory only (not persisted across restarts).
/// The log file preserves error history.
///
/// Copied from [ErrorService].
@ProviderFor(ErrorService)
final errorServiceProvider =
    NotifierProvider<ErrorService, List<AppError>>.internal(
      ErrorService.new,
      name: r'errorServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$errorServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ErrorService = Notifier<List<AppError>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
