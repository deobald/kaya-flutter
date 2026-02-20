import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaya/features/anga/models/anga.dart';
import 'package:kaya/features/anga/models/anga_type.dart';
import 'package:kaya/features/anga/services/anga_repository.dart';
import 'package:kaya/features/anga/services/file_storage_service.dart';
import 'package:kaya/features/meta/models/anga_meta.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

/// Screen for previewing an anga's content.
class PreviewScreen extends ConsumerStatefulWidget {
  static const routePath = '/preview/:filename';
  static const routeName = 'preview';

  static String routePathFor(String filename) =>
      '/preview/${Uri.encodeComponent(filename)}';

  final String filename;

  const PreviewScreen({super.key, required this.filename});

  @override
  ConsumerState<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends ConsumerState<PreviewScreen> {
  final _tagsController = TextEditingController();
  final _noteController = TextEditingController();
  bool _metadataChanged = false;
  bool _metadataInitialized = false;
  VideoPlayerController? _videoController;
  Future<String?>? _wordsTextFuture;

  @override
  void dispose() {
    _tagsController.dispose();
    _noteController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final angaAsync = ref.watch(angaByFilenameProvider(widget.filename));
    final metaAsync = ref.watch(metaForAngaProvider(widget.filename));

    return angaAsync.when(
      data: (anga) {
        if (anga == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Not Found')),
            body: const Center(child: Text('Anga not found')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(anga.displayTitle),
            actions: [
              IconButton(
                icon: Icon(Platform.isIOS
                    ? CupertinoIcons.share_up
                    : Icons.share),
                onPressed: () => _shareAnga(anga),
                tooltip: 'Share',
              ),
              IconButton(
                icon: Icon(Platform.isIOS
                    ? CupertinoIcons.cloud_download
                    : Icons.download),
                onPressed: () => _downloadAnga(anga),
                tooltip: 'Download',
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildContent(anga),
                if (anga.type == AngaType.bookmark) _buildBookmarkInfo(anga),
                _buildMetadataSection(anga, metaAsync),
              ],
            ),
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: CircularProgressIndicator(semanticsLabel: 'Loading preview'),
        ),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildContent(Anga anga) {
    switch (anga.type) {
      case AngaType.bookmark:
        return _buildBookmarkContent(anga);
      case AngaType.note:
        return _buildNoteContent(anga);
      case AngaType.file:
        return _buildFileContent(anga);
    }
  }

  Widget _buildBookmarkContent(Anga anga) {
    _wordsTextFuture ??= _getWordsText(anga);
    return FutureBuilder<String?>(
      future: _wordsTextFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 300,
            child: Center(
              child: CircularProgressIndicator(
                semanticsLabel: 'Loading content',
              ),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          return Container(
            height: 300,
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: SingleChildScrollView(
              child: Text(
                snapshot.data!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          );
        }

        // No words available
        return Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.web,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 8),
                const Text('Extracted text not available'),
                const SizedBox(height: 4),
                Text(
                  'Sync with server to get searchable text',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<String?> _getWordsText(Anga anga) async {
    final storage = await ref.read(fileStorageServiceProvider.future);
    return await storage.getWordsText(anga.filename);
  }

  Widget _buildNoteContent(Anga anga) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SelectableText(
        anga.content ?? '',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }

  Widget _buildFileContent(Anga anga) {
    if (anga.isImage) {
      return Image.file(
        File(anga.path),
        fit: BoxFit.contain,
        errorBuilder: (ctx, err, stack) => _buildFileError(),
      );
    }

    if (anga.isPdf) {
      return SizedBox(
        height: 500,
        child: PDFView(
          filePath: anga.path,
          enableSwipe: true,
          swipeHorizontal: false,
          autoSpacing: true,
          pageFling: false,
        ),
      );
    }

    if (anga.isVideo) {
      return _buildVideoPlayer(anga);
    }

    // Generic file
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.insert_drive_file,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              anga.filename,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (anga.fileSize != null) ...[
              const SizedBox(height: 8),
              Text(
                _formatFileSize(anga.fileSize!),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayer(Anga anga) {
    _videoController ??= VideoPlayerController.file(File(anga.path))
      ..initialize().then((_) {
        setState(() {});
      });

    if (_videoController == null || !_videoController!.value.isInitialized) {
      return const SizedBox(
        height: 300,
        child: Center(
          child: CircularProgressIndicator(semanticsLabel: 'Loading video'),
        ),
      );
    }

    return Column(
      children: [
        AspectRatio(
          aspectRatio: _videoController!.value.aspectRatio,
          child: VideoPlayer(_videoController!),
        ),
        VideoProgressIndicator(_videoController!, allowScrubbing: true),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(
                _videoController!.value.isPlaying
                    ? Icons.pause
                    : Icons.play_arrow,
              ),
              onPressed: () {
                setState(() {
                  if (_videoController!.value.isPlaying) {
                    _videoController!.pause();
                  } else {
                    _videoController!.play();
                  }
                });
              },
              tooltip: _videoController!.value.isPlaying ? 'Pause' : 'Play',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFileError() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      child: const Center(child: Text('Error loading file')),
    );
  }

  Widget _buildBookmarkInfo(Anga anga) {
    if (anga.url == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            anga.url!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () => _openUrl(anga.url!),
            icon: const Icon(Icons.open_in_browser),
            label: const Text('Visit Original Page'),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataSection(Anga anga, AsyncValue<AngaMeta?> metaAsync) {
    return metaAsync.when(
      data: (meta) {
        // Initialize controllers once from loaded metadata
        if (!_metadataInitialized) {
          _tagsController.text = meta?.tags.join(', ') ?? '';
          _noteController.text = meta?.note ?? '';
          _metadataInitialized = true;
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Divider(),
              const SizedBox(height: 16),
              Text('Metadata', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              TextField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  labelText: 'Tags',
                  hintText: 'Enter tags separated by commas',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() => _metadataChanged = true),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Note',
                  hintText: 'Add a note about this item',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                onChanged: (_) => setState(() => _metadataChanged = true),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _metadataChanged ? () => _saveMetadata(anga) : null,
                child: const Text('Save Metadata'),
              ),
            ],
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: CircularProgressIndicator(semanticsLabel: 'Loading metadata'),
        ),
      ),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }

  Future<void> _saveMetadata(Anga anga) async {
    final tags = _tagsController.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();
    final note = _noteController.text.isEmpty ? null : _noteController.text;

    await ref
        .read(angaRepositoryProvider.notifier)
        .saveMeta(anga.filename, tags: tags, note: note);

    setState(() {
      _metadataChanged = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Metadata saved')));
    }
  }

  Future<void> _shareAnga(Anga anga) async {
    if (anga.type == AngaType.bookmark && anga.url != null) {
      await Share.share(anga.url!);
    } else {
      await Share.shareXFiles([XFile(anga.path)]);
    }
  }

  Future<void> _downloadAnga(Anga anga) async {
    // TODO: Implement platform-specific download
    // Android: Save to Downloads directory
    // iOS: Use Files app integration
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Download not yet implemented')),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
