import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kaya/core/utils/datetime_utils.dart';
import 'package:toml/toml.dart';

part 'anga_meta.freezed.dart';

/// Represents metadata for an anga (tags and notes).
///
/// Metadata files follow the format: `YYYY-MM-DDTHHMMSS-{descriptor}.toml`
/// Multiple metadata files can reference the same anga.
@freezed
class AngaMeta with _$AngaMeta {
  const AngaMeta._();

  const factory AngaMeta({
    /// The metadata filename (not the full path)
    required String metaFilename,

    /// The full path to the metadata file
    required String path,

    /// The anga filename this metadata references
    required String angaFilename,

    /// Tags associated with the anga
    required List<String> tags,

    /// User's note about the anga
    String? note,

    /// When this metadata was created (parsed from filename)
    required DateTime createdAt,
  }) = _AngaMeta;

  /// Parses an AngaMeta from TOML content.
  factory AngaMeta.fromToml(String path, String content) {
    final filename = path.split('/').last;
    final createdAt = DateTimeUtils.parseTimestamp(filename) ?? DateTime.now();

    try {
      final doc = TomlDocument.parse(content);
      final tomlMap = doc.toMap();

      final angaSection = tomlMap['anga'] as Map<String, dynamic>?;
      final metaSection = tomlMap['meta'] as Map<String, dynamic>?;

      final angaFilename = angaSection?['filename'] as String? ?? '';
      final tags = (metaSection?['tags'] as List<dynamic>?)
              ?.map((t) => t.toString())
              .toList() ??
          [];
      final note = metaSection?['note'] as String?;

      return AngaMeta(
        metaFilename: filename,
        path: path,
        angaFilename: angaFilename,
        tags: tags,
        note: note,
        createdAt: createdAt,
      );
    } catch (e) {
      // Return empty metadata if parsing fails
      return AngaMeta(
        metaFilename: filename,
        path: path,
        angaFilename: '',
        tags: [],
        note: null,
        createdAt: createdAt,
      );
    }
  }

  /// Converts this metadata to TOML format.
  String toToml() {
    final buffer = StringBuffer();
    buffer.writeln('[anga]');
    buffer.writeln('filename = "$angaFilename"');
    buffer.writeln();
    buffer.writeln('[meta]');

    // Format tags as TOML array
    if (tags.isNotEmpty) {
      final tagsStr = tags.map((t) => '"$t"').join(', ');
      buffer.writeln('tags = [$tagsStr]');
    } else {
      buffer.writeln('tags = []');
    }

    // Format note with triple single quotes for multiline
    if (note != null && note!.isNotEmpty) {
      if (note!.contains('\n')) {
        buffer.writeln("note = '''$note'''");
      } else {
        buffer.writeln('note = "$note"');
      }
    }

    return buffer.toString();
  }
}

/// Generates a metadata filename.
String generateMetaFilename(String descriptor, [DateTime? timestamp]) {
  final ts = DateTimeUtils.generateTimestamp(timestamp);
  return '$ts-$descriptor.toml';
}
