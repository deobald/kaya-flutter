import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaya/core/services/logger_service.dart';
import 'package:kaya/core/widgets/kaya_icon.dart';
import 'package:kaya/features/anga/services/file_storage_service.dart';
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
            icon: Icon(KayaIcon.refresh),
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
            KayaIcon.descriptionOutlined,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text('No logs yet', style: Theme.of(context).textTheme.titleMedium),
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
          style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildActions() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _dumpWordsDebug,
                    icon: Icon(KayaIcon.bugReport),
                    label: const Text('Dump Words'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _clearLogs,
                    icon: Icon(KayaIcon.deleteOutline),
                    label: const Text('Clear Logs'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _sendToDeveloper,
                    icon: Icon(KayaIcon.email),
                    label: const Text('Send To Developer'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _dumpWordsDebug() async {
    final logger = await ref.read(loggerServiceProvider.future);
    final storage = await ref.read(fileStorageServiceProvider.future);

    logger.i('=== DEBUG: Words Directory Dump ===');
    logger.i('Words path: ${storage.wordsPath}');

    final wordsDir = Directory(storage.wordsPath);
    if (!await wordsDir.exists()) {
      logger.i('Words directory does not exist!');
      await _loadLogs();
      return;
    }

    final angaDirs = await wordsDir.list().toList();
    logger.i('Found ${angaDirs.length} anga directories in words/');

    for (final entry in angaDirs) {
      if (entry is Directory) {
        final dirName = entry.path.split('/').last;
        logger.i('  [$dirName]');

        final files = await entry.list().toList();
        for (final file in files) {
          if (file is File) {
            final fileName = file.path.split('/').last;
            final content = await file.readAsString();
            logger.i('    - $fileName (${content.length} chars)');
            // Log first 500 chars of content
            final preview = content.length > 500
                ? '${content.substring(0, 500)}...'
                : content;
            logger.i('      Content: $preview');
            // Check for specific words
            if (content.toLowerCase().contains('collectively')) {
              logger.i('      *** CONTAINS "collectively" ***');
            }
            if (content.toLowerCase().contains('notwithstanding')) {
              logger.i('      *** CONTAINS "notwithstanding" ***');
            }
          }
        }
      }
    }

    // Also dump anga files that are PDFs
    logger.i('=== DEBUG: PDF Angas ===');
    final angaFiles = await storage.listAngaFiles();
    for (final filename in angaFiles) {
      if (filename.endsWith('.pdf')) {
        logger.i('  PDF: $filename');
        // Check if words exist for this PDF
        final wordsText = await storage.getWordsText(filename);
        if (wordsText != null) {
          logger.i('    Words found: ${wordsText.length} chars');
        } else {
          logger.i('    NO WORDS FOUND');
        }
      }
    }

    logger.i('=== END DEBUG ===');

    await _loadLogs();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debug info dumped to logs')),
      );
    }
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Logs cleared')));
      }
    }
  }

  Future<void> _sendToDeveloper() async {
    final logger = await ref.read(loggerServiceProvider.future);
    final logFile = await logger.getLogFile();

    if (logFile == null || !await logFile.exists()) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No log file available')));
      }
      return;
    }

    // Try to send via email
    final emailUri = Uri(
      scheme: 'mailto',
      path: 'steven+kaya@deobald.ca',
      queryParameters: {
        'subject': 'Save Button App Logs',
        'body':
            'Please find the attached log file.\n\n'
            'Device: ${Platform.operatingSystem}\n'
            'OS Version: ${Platform.operatingSystemVersion}\n',
      },
    );

    if (await canLaunchUrl(emailUri)) {
      // First share the file, then open email
      await Share.shareXFiles(
        [XFile(logFile.path)],
        subject: 'Save Button App Logs',
        text: 'Log file for Save Button app troubleshooting',
      );
    } else {
      // Fallback to just sharing the file
      await Share.shareXFiles([
        XFile(logFile.path),
      ], subject: 'Save Button App Logs - Send to steven+kaya@deobald.ca');
    }
  }
}
