/// The type of anga (content) stored in Kaya.
enum AngaType {
  /// A bookmark stored as a .url file
  bookmark,

  /// A text note stored as a .md file (notes, quotes, snippets, etc.)
  note,

  /// Any other file type (images, PDFs, videos, etc.)
  file,
}

extension AngaTypeExtension on AngaType {
  String get displayName {
    switch (this) {
      case AngaType.bookmark:
        return 'Bookmark';
      case AngaType.note:
        return 'Note';
      case AngaType.file:
        return 'File';
    }
  }
}

/// Determines the AngaType from a filename.
AngaType angaTypeFromFilename(String filename) {
  final lower = filename.toLowerCase();

  if (lower.endsWith('.url')) {
    return AngaType.bookmark;
  }

  // Treat all markdown files as notes (includes -note.md, -quote.md, etc.)
  if (lower.endsWith('.md')) {
    return AngaType.note;
  }

  return AngaType.file;
}
