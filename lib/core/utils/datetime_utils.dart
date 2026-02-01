/// Utility functions for datetime handling in Kaya filenames.
///
/// Kaya uses the format `YYYY-MM-DDTHHMMSS` for timestamps in filenames.
/// In case of collisions, nanoseconds are appended: `YYYY-MM-DDTHHMMSS_SSSSSSSSS`
class DateTimeUtils {
  DateTimeUtils._();

  /// Generates a timestamp string for use in filenames.
  /// Format: `2026-01-27T171207`
  static String generateTimestamp([DateTime? dateTime]) {
    final dt = dateTime ?? DateTime.now().toUtc();
    return '${dt.year.toString().padLeft(4, '0')}-'
        '${dt.month.toString().padLeft(2, '0')}-'
        '${dt.day.toString().padLeft(2, '0')}T'
        '${dt.hour.toString().padLeft(2, '0')}'
        '${dt.minute.toString().padLeft(2, '0')}'
        '${dt.second.toString().padLeft(2, '0')}';
  }

  /// Generates a timestamp with nanoseconds for collision resolution.
  /// Format: `2026-01-27T171207_354000000`
  static String generateTimestampWithNanos([DateTime? dateTime]) {
    final dt = dateTime ?? DateTime.now().toUtc();
    final base = generateTimestamp(dt);
    final nanos = (dt.microsecond * 1000).toString().padLeft(9, '0');
    return '${base}_$nanos';
  }

  /// Parses a timestamp from a Kaya filename.
  /// Handles both standard and nanosecond formats.
  static DateTime? parseTimestamp(String filename) {
    // Match patterns like: 2026-01-27T171207 or 2026-01-27T171207_354000000
    final standardPattern = RegExp(r'^(\d{4})-(\d{2})-(\d{2})T(\d{2})(\d{2})(\d{2})');
    final nanosPattern = RegExp(r'^(\d{4})-(\d{2})-(\d{2})T(\d{2})(\d{2})(\d{2})_(\d{9})');

    Match? match = nanosPattern.firstMatch(filename);
    if (match != null) {
      final nanos = int.parse(match.group(7)!);
      final millis = nanos ~/ 1000000;
      final micros = (nanos % 1000000) ~/ 1000;
      return DateTime.utc(
        int.parse(match.group(1)!),
        int.parse(match.group(2)!),
        int.parse(match.group(3)!),
        int.parse(match.group(4)!),
        int.parse(match.group(5)!),
        int.parse(match.group(6)!),
        millis,
        micros,
      );
    }

    match = standardPattern.firstMatch(filename);
    if (match != null) {
      return DateTime.utc(
        int.parse(match.group(1)!),
        int.parse(match.group(2)!),
        int.parse(match.group(3)!),
        int.parse(match.group(4)!),
        int.parse(match.group(5)!),
        int.parse(match.group(6)!),
      );
    }

    return null;
  }

  /// Extracts the timestamp prefix from a filename.
  /// Returns the timestamp portion including any nanoseconds.
  static String? extractTimestampPrefix(String filename) {
    final nanosPattern = RegExp(r'^(\d{4}-\d{2}-\d{2}T\d{6}_\d{9})');
    final standardPattern = RegExp(r'^(\d{4}-\d{2}-\d{2}T\d{6})');

    var match = nanosPattern.firstMatch(filename);
    if (match != null) return match.group(1);

    match = standardPattern.firstMatch(filename);
    if (match != null) return match.group(1);

    return null;
  }
}
