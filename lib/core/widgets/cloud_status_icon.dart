import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaya/features/sync/services/sync_service.dart';

/// Shows cloud connection status icon in the app bar.
/// - Cloud Done: Last sync was successful
/// - Cloud Off: Last sync failed due to connection error
/// - Cloud Sync: Currently syncing
class CloudStatusIcon extends ConsumerWidget {
  const CloudStatusIcon({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncStatus = ref.watch(syncControllerProvider);
    final connectionStatus = ref.watch(syncConnectionStatusProvider);

    IconData icon;
    Color? color;
    String tooltip;

    if (syncStatus == SyncStatus.syncing) {
      icon = Icons.cloud_sync;
      color = Theme.of(context).colorScheme.primary;
      tooltip = 'Syncing...';
    } else if (connectionStatus == SyncConnectionStatus.connected) {
      icon = Icons.cloud_done;
      color = Theme.of(context).colorScheme.primary;
      tooltip = 'Connected to server';
    } else if (connectionStatus == SyncConnectionStatus.disconnected) {
      icon = Icons.cloud_off;
      color = Theme.of(context).colorScheme.outline;
      tooltip = 'Server unreachable';
    } else {
      // No credentials configured - don't show icon
      return const SizedBox.shrink();
    }

    return IconButton(
      icon: Icon(icon, color: color),
      onPressed: null, // Just a status indicator
      tooltip: tooltip,
    );
  }
}
