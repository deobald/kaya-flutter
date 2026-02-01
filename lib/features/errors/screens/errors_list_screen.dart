import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaya/features/errors/models/app_error.dart';
import 'package:kaya/features/errors/services/error_service.dart';

/// Screen showing the list of errors and warnings.
class ErrorsListScreen extends ConsumerWidget {
  static const routePath = '/errors';
  static const routeName = 'errors';

  const ErrorsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final errors = ref.watch(errorServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Errors & Warnings'),
        actions: [
          if (errors.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () {
                ref.read(errorServiceProvider.notifier).clearAll();
              },
              tooltip: 'Clear all',
            ),
        ],
      ),
      body: errors.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              itemCount: errors.length,
              itemBuilder: (context, index) {
                final error = errors[errors.length - 1 - index]; // Newest first
                return _buildErrorTile(context, ref, error);
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'No errors or warnings',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Everything is working smoothly',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorTile(BuildContext context, WidgetRef ref, AppError error) {
    final isError = error.severity == ErrorSeverity.error;

    return Dismissible(
      key: Key(error.id),
      onDismissed: (_) {
        ref.read(errorServiceProvider.notifier).removeError(error.id);
      },
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      child: ListTile(
        leading: Icon(
          isError ? Icons.error : Icons.warning,
          color: isError ? Colors.red : Colors.orange,
          semanticLabel: isError ? 'Error' : 'Warning',
        ),
        title: Text(error.message),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (error.details != null)
              Text(
                error.details!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            Text(
              _formatTimestamp(error.timestamp),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
        isThreeLine: error.details != null,
        onTap: error.details != null
            ? () => _showDetails(context, error)
            : null,
      ),
    );
  }

  void _showDetails(BuildContext context, AppError error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(error.severity == ErrorSeverity.error ? 'Error' : 'Warning'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                error.message,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              if (error.details != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: SelectableText(
                    error.details!,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Text(
                _formatTimestamp(error.timestamp),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes} minute${diff.inMinutes == 1 ? '' : 's'} ago';
    } else if (diff.inDays < 1) {
      return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
    } else {
      return '${timestamp.month}/${timestamp.day} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}
