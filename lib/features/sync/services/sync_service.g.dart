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
String _$syncControllerHash() => r'74e9fabd4ebf1a58e54e4756cf32cbb1076e7619';

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
