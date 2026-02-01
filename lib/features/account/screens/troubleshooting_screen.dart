import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaya/core/services/logger_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Screen for viewing logs and troubleshooting.
class TroubleshootingScreen extends ConsumerStatefulWidget {
  static const routePath = '/troubleshooting';
  static const routeName = 'troubleshooting';

  const TroubleshootingScreen({super.key});

  @override
  ConsumerState<TroubleshootingScreen> createState() =>
      _TroubleshootingScreenState();
}

class _TroubleshootingScreenState extends ConsumerState<TroubleshootingScreen> {
  String _logs = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() {
      _loading = true;
    });

    try {
      final logger = await ref.read(loggerServiceProvider.future);
      final logs = await logger.readLogs();
      setState(() {
        _logs = logs;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _logs = 'Error loading logs: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Troubleshooting'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLogs,
            tooltip: 'Refresh logs',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                      semanticsLabel: 'Loading logs',
                    ),
                  )
                : _logs.isEmpty
                    ? _buildEmptyState()
                    : _buildLogViewer(),
          ),
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'No logs yet',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Logs will appear here as you use the app',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogViewer() {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: SelectableText(
          _logs,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildActions() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _clearLogs,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Clear Logs'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _sendToDeveloper,
                icon: const Icon(Icons.email),
                label: const Text('Send To Developer'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _clearLogs() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Logs'),
        content: const Text('Are you sure you want to clear all logs?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final logger = await ref.read(loggerServiceProvider.future);
      await logger.clearLogs();
      await _loadLogs();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logs cleared')),
        );
      }
    }
  }

  Future<void> _sendToDeveloper() async {
    final logger = await ref.read(loggerServiceProvider.future);
    final logFile = await logger.getLogFile();

    if (logFile == null || !await logFile.exists()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No log file available')),
        );
      }
      return;
    }

    // Try to send via email
    final emailUri = Uri(
      scheme: 'mailto',
      path: 'steven+kaya@deobald.ca',
      queryParameters: {
        'subject': 'Kaya App Logs',
        'body': 'Please find the attached log file.\n\n'
            'Device: ${Platform.operatingSystem}\n'
            'OS Version: ${Platform.operatingSystemVersion}\n',
      },
    );

    if (await canLaunchUrl(emailUri)) {
      // First share the file, then open email
      await Share.shareXFiles(
        [XFile(logFile.path)],
        subject: 'Kaya App Logs',
        text: 'Log file for Kaya app troubleshooting',
      );
    } else {
      // Fallback to just sharing the file
      await Share.shareXFiles(
        [XFile(logFile.path)],
        subject: 'Kaya App Logs - Send to steven+kaya@deobald.ca',
      );
    }
  }
}
