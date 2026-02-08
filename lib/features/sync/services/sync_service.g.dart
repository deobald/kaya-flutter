// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$syncServiceHash() => r'0a9449856f5ca254f0560c89e64f8503a4cc2430';

/// See also [syncService].
@ProviderFor(syncService)
final syncServiceProvider = FutureProvider<SyncService>.internal(
  syncService,
  name: r'syncServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$syncServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SyncServiceRef = FutureProviderRef<SyncService>;
String _$syncConnectionStatusHash() =>
    r'14aaf5d31ca73e2393ff127efa5b0c2dc7d94d03';

/// Convenience provider for reading connection status.
///
/// Copied from [syncConnectionStatus].
@ProviderFor(syncConnectionStatus)
final syncConnectionStatusProvider =
    AutoDisposeProvider<SyncConnectionStatus>.internal(
      syncConnectionStatus,
      name: r'syncConnectionStatusProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$syncConnectionStatusHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SyncConnectionStatusRef = AutoDisposeProviderRef<SyncConnectionStatus>;
String _$syncConnectionStatusNotifierHash() =>
    r'8f5d90fa5c6f4d06f60ea868e969b097cc52f801';

/// Provider for tracking connection status separately from sync status.
///
/// Copied from [SyncConnectionStatusNotifier].
@ProviderFor(SyncConnectionStatusNotifier)
final syncConnectionStatusNotifierProvider =
    NotifierProvider<
      SyncConnectionStatusNotifier,
      SyncConnectionStatus
    >.internal(
      SyncConnectionStatusNotifier.new,
      name: r'syncConnectionStatusNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$syncConnectionStatusNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SyncConnectionStatusNotifier = Notifier<SyncConnectionStatus>;
String _$syncControllerHash() => r'caf945e470e88215966caab74d136fa71edd8655';

/// Notifier for managing sync state and scheduling.
///
/// Copied from [SyncController].
@ProviderFor(SyncController)
final syncControllerProvider =
    NotifierProvider<SyncController, SyncStatus>.internal(
      SyncController.new,
      name: r'syncControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$syncControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SyncController = Notifier<SyncStatus>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
