import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kaya/features/anga/models/anga.dart';
import 'package:kaya/features/anga/models/anga_type.dart';
import 'package:kaya/features/anga/services/file_storage_service.dart';

/// A tile widget for displaying an anga in the grid.
class AngaTile extends ConsumerWidget {
  final Anga anga;
  final VoidCallback onTap;

  const AngaTile({
    super.key,
    required this.anga,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _buildContent(context, ref),
            ),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref) {
    switch (anga.type) {
      case AngaType.bookmark:
        return _buildBookmarkContent(context, ref);
      case AngaType.note:
        return _buildNoteContent(context);
      case AngaType.file:
        return _buildFileContent(context);
    }
  }

  Widget _buildBookmarkContent(BuildContext context, WidgetRef ref) {
    return FutureBuilder<String?>(
      future: _getFaviconPath(ref),
      builder: (context, snapshot) {
        return Container(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (snapshot.hasData && snapshot.data != null)
                  Image.file(
                    File(snapshot.data!),
                    width: 48,
                    height: 48,
                    errorBuilder: (ctx, err, stack) => _defaultBookmarkIcon(context),
                  )
                else
                  _defaultBookmarkIcon(context),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    anga.displayTitle,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<String?> _getFaviconPath(WidgetRef ref) async {
    final storage = await ref.read(fileStorageServiceProvider.future);
    return await storage.getCachedFaviconPath(anga.filename);
  }

  Widget _defaultBookmarkIcon(BuildContext context) {
    return Icon(
      Icons.bookmark,
      size: 48,
      color: Theme.of(context).colorScheme.primary,
      semanticLabel: 'Bookmark',
    );
  }

  Widget _buildNoteContent(BuildContext context) {
    final content = anga.content ?? '';
    final isShort = content.length < 100;

    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.all(12),
      child: Text(
        content,
        maxLines: isShort ? 4 : 6,
        overflow: TextOverflow.fade,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: isShort ? 16 : 12,
            ),
      ),
    );
  }

  Widget _buildFileContent(BuildContext context) {
    // Handle SVG files separately
    if (anga.extension == 'svg') {
      return Container(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        padding: const EdgeInsets.all(8),
        child: SvgPicture.file(
          File(anga.path),
          fit: BoxFit.contain,
          placeholderBuilder: (context) => _buildFileIcon(context),
        ),
      );
    }

    // Handle raster images (PNG, JPG, etc.)
    if (anga.isImage) {
      return Image.file(
        File(anga.path),
        fit: BoxFit.cover,
        errorBuilder: (ctx, err, stack) => _buildFileIcon(context),
      );
    }

    // Handle video files with play icon overlay
    if (anga.isVideo) {
      return Stack(
        alignment: Alignment.center,
        children: [
          Container(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          Icon(
            Icons.play_circle_outline,
            size: 48,
            color: Theme.of(context).colorScheme.primary,
            semanticLabel: 'Video file',
          ),
        ],
      );
    }

    return _buildFileIcon(context);
  }

  Widget _buildFileIcon(BuildContext context) {
    IconData icon;
    if (anga.isPdf) {
      icon = Icons.picture_as_pdf;
    } else if (anga.isVideo) {
      icon = Icons.video_file;
    } else if (anga.isImage) {
      icon = Icons.image;
    } else {
      icon = Icons.insert_drive_file;
    }

    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
              semanticLabel: '${anga.extension.toUpperCase()} file',
            ),
            const SizedBox(height: 8),
            Text(
              '.${anga.extension}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Text(
        anga.displayTitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }
}
