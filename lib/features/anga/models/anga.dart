import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kaya/core/utils/datetime_utils.dart';
import 'package:kaya/features/anga/models/anga_type.dart';

part 'anga.freezed.dart';

/// Represents a piece of content (bookmark, note, or file) stored in Kaya.
///
/// Anga filenames follow the format: `YYYY-MM-DDTHHMMSS-{descriptor}.{ext}`
/// For example: `2026-01-27T171207-www-deobald-ca.url`
@freezed
class Anga with _$Anga {
  const Anga._();

  const factory Anga({
    /// The filename (not the full path)
    required String filename,

    /// The full path to the file
    required String path,

    /// The type of anga
    required AngaType type,

    /// When this anga was created (parsed from filename)
    required DateTime createdAt,

    /// Cached content for display (optional)
    String? content,

    /// For bookmarks: the URL
    String? url,

    /// File size in bytes (optional)
    int? fileSize,
  }) = _Anga;

  /// Creates an Anga from a file path.
  factory Anga.fromPath(String path, {String? content, int? fileSize}) {
    final filename = path.split('/').last;
    final type = angaTypeFromFilename(filename);
    final createdAt = DateTimeUtils.parseTimestamp(filename) ?? DateTime.now();

    String? url;
    if (type == AngaType.bookmark && content != null) {
      url = _extractUrlFromBookmark(content);
    }

    return Anga(
      filename: filename,
      path: path,
      type: type,
      createdAt: createdAt,
      content: content,
      url: url,
      fileSize: fileSize,
    );
  }

  /// Gets the display title for this anga.
  String get displayTitle {
    switch (type) {
      case AngaType.bookmark:
        if (url != null) {
          // Extract domain from URL
          try {
            final uri = Uri.parse(url!);
            return uri.host;
          } catch (_) {
            return _extractDescriptor();
          }
        }
        return _extractDescriptor();

      case AngaType.note:
        // Return first line or first 50 chars of content
        if (content != null && content!.isNotEmpty) {
          final firstLine = content!.split('\n').first;
          if (firstLine.length > 50) {
            return '${firstLine.substring(0, 47)}...';
          }
          return firstLine;
        }
        return 'Note';

      case AngaType.file:
        return _extractDescriptor();
    }
  }

  /// Extracts the descriptor portion from the filename for display.
  /// URL-decodes the result since filenames are stored URL-encoded on disk.
  /// Keeps the file extension intact.
  String _extractDescriptor() {
    // Remove timestamp prefix (YYYY-MM-DDTHHMMSS- or YYYY-MM-DDTHHMMSS_SSSSSSSSS-)
    final timestampPattern = RegExp(r'^\d{4}-\d{2}-\d{2}T\d{6}(_\d{9})?-');
    final descriptor = filename.replaceFirst(timestampPattern, '');
    // URL-decode for display (filenames are stored URL-encoded on disk)
    return Uri.decodeComponent(descriptor);
  }

  /// Gets the file extension.
  String get extension {
    if (!filename.contains('.')) return '';
    return filename.substring(filename.lastIndexOf('.') + 1).toLowerCase();
  }

  /// Whether this is an image file.
  bool get isImage {
    final ext = extension;
    return ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'svg'].contains(ext);
  }

  /// Whether this is a video file.
  bool get isVideo {
    final ext = extension;
    return ['mp4', 'mov', 'avi', 'mkv', 'webm', 'm4v'].contains(ext);
  }

  /// Whether this is a PDF file.
  bool get isPdf => extension == 'pdf';
}

/// Extracts the URL from a Windows-style .url file content.
String? _extractUrlFromBookmark(String content) {
  final lines = content.split('\n');
  for (final line in lines) {
    if (line.startsWith('URL=')) {
      return line.substring(4).trim();
    }
  }
  return null;
}

/// Generates a bookmark filename from a URL.
String generateBookmarkFilename(String urlString, [DateTime? timestamp]) {
  final ts = DateTimeUtils.generateTimestamp(timestamp);
  final sanitizedDomain = _sanitizeDomain(urlString);
  return '$ts-$sanitizedDomain.url';
}

/// Generates a note filename.
String generateNoteFilename([DateTime? timestamp]) {
  final ts = DateTimeUtils.generateTimestamp(timestamp);
  return '$ts-note.md';
}

/// Generates a file filename from an original filename.
/// URL-encodes the filename to ensure no URL-illegal characters are stored on disk.
String generateFileFilename(String originalFilename, [DateTime? timestamp]) {
  final ts = DateTimeUtils.generateTimestamp(timestamp);
  final encoded = _urlEncodeFilename(originalFilename);
  return '$ts-$encoded';
}

/// Sanitizes a domain for use in a filename.
/// Replaces dots and special characters with hyphens.
String _sanitizeDomain(String urlString) {
  try {
    final uri = Uri.parse(urlString);
    // Get just the host (domain)
    var domain = uri.host;
    // Replace dots and special characters with hyphens
    domain = domain.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '-');
    // Remove multiple consecutive hyphens
    domain = domain.replaceAll(RegExp(r'-+'), '-');
    // Remove leading/trailing hyphens
    domain = domain.replaceAll(RegExp(r'^-+|-+$'), '');
    return domain.isNotEmpty ? domain : 'bookmark';
  } catch (_) {
    return 'bookmark';
  }
}

/// URL-encodes a filename for storage on disk.
/// This ensures perfect symmetry with the server's filesystem layout.
/// Only encodes characters that are not safe in URLs/filenames.
String _urlEncodeFilename(String filename) {
  // Uri.encodeComponent encodes everything except A-Z a-z 0-9 - _ . ~
  // But we want to keep the dot for file extensions, which encodeComponent already does
  return Uri.encodeComponent(filename);
}

/// Creates the content for a .url bookmark file.
String createBookmarkContent(String url) {
  return '[InternetShortcut]\nURL=$url\n';
}
