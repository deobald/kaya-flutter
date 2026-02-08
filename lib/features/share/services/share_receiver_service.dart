import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaya/core/services/logger_service.dart';

import 'package:kaya/features/anga/services/anga_repository.dart';
import 'package:share_handler/share_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'share_receiver_service.g.dart';

/// Service for handling content shared to Kaya from other apps.
class ShareReceiverService {
  final LoggerService? _logger;
  final Ref _ref;
  StreamSubscription<SharedMedia>? _mediaSubscription;
  bool _isProcessing = false;

  ShareReceiverService(this._logger, this._ref);

  /// Initializes the share handler and processes any initial shared content.
  Future<void> init() async {
    final handler = ShareHandlerPlatform.instance;

    // Listen for incoming media/text while app is running
    _mediaSubscription = handler.sharedMediaStream.listen((
      SharedMedia media,
    ) async {
      await _processSharedMedia(media);
    });

    // Check for initial shared content (cold start)
    final initialMedia = await handler.getInitialSharedMedia();
    if (initialMedia != null) {
      await _processSharedMedia(initialMedia);
    }
  }

  /// Processes shared media (includes text, URLs, and file attachments).
  Future<void> _processSharedMedia(SharedMedia media) async {
    // Prevent concurrent processing
    if (_isProcessing) {
      _logger?.i('Skipping shared content (already processing)');
      return;
    }
    _isProcessing = true;

    _logger?.i(
      'Received shared media: content=${media.content}, attachments=${media.attachments?.length ?? 0}',
    );

    final repo = _ref.read(angaRepositoryProvider.notifier);

    try {
      // Handle shared text/URL content
      if (media.content != null && media.content!.isNotEmpty) {
        final content = media.content!;
        if (_isUrl(content)) {
          _logger?.i('Processing shared URL: $content');
          await repo.addBookmark(content);
        } else {
          _logger?.i('Processing shared text as note');
          await repo.addNote(content);
        }
      }

      // Handle shared file attachments
      if (media.attachments != null) {
        for (final attachment in media.attachments!) {
          if (attachment != null) {
            await _processAttachment(attachment, repo);
          }
        }
      }
    } finally {
      _isProcessing = false;
    }
  }

  /// Processes a single shared attachment.
  Future<void> _processAttachment(
    SharedAttachment attachment,
    AngaRepository repo,
  ) async {
    final path = attachment.path;
    _logger?.i(
      'Processing shared attachment: type=${attachment.type}, path=$path',
    );

    final file = File(path);
    if (!await file.exists()) {
      _logger?.w('Shared file does not exist: $path');
      return;
    }

    final originalFilename = path.split('/').last;

    // Check if it's a text file that might contain a URL
    if (originalFilename.endsWith('.txt')) {
      final content = await file.readAsString();
      final trimmed = content.trim();
      if (_isUrl(trimmed)) {
        await repo.addBookmark(trimmed);
        return;
      }
    }

    // Save as file
    await repo.addFile(path, originalFilename);
  }

  /// Determines if text is a URL.
  bool _isUrl(String text) {
    if (text.startsWith('http://') || text.startsWith('https://')) {
      try {
        final uri = Uri.parse(text);
        return uri.hasScheme && uri.host.isNotEmpty;
      } catch (_) {
        return false;
      }
    }

    if (text.startsWith('www.')) {
      return true;
    }

    return false;
  }

  void dispose() {
    _mediaSubscription?.cancel();
  }
}

@Riverpod(keepAlive: true)
ShareReceiverService shareReceiverService(Ref ref) {
  final logger = ref.watch(loggerProvider);
  final service = ShareReceiverService(logger, ref);
  service.init();
  ref.onDispose(() => service.dispose());
  return service;
}
