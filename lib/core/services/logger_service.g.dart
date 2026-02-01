// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'logger_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$loggerServiceHash() => r'f50bc6fe0254d228ab2404c7a1c5396ff5f4d61a';

/// See also [loggerService].
@ProviderFor(loggerService)
final loggerServiceProvider = FutureProvider<LoggerService>.internal(
  loggerService,
  name: r'loggerServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$loggerServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LoggerServiceRef = FutureProviderRef<LoggerService>;
String _$loggerHash() => r'473192abe54af0304e6dfe00b9b15c7e51255d98';

/// Convenience provider for synchronous logger access after initialization
///
/// Copied from [logger].
@ProviderFor(logger)
final loggerProvider = Provider<LoggerService?>.internal(
  logger,
  name: r'loggerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$loggerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LoggerRef = ProviderRef<LoggerService?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
