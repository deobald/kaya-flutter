import 'package:flutter_test/flutter_test.dart';
import 'package:kaya/core/utils/datetime_utils.dart';

void main() {
  group('DateTimeUtils', () {
    group('generateTimestamp', () {
      test('generates correct format', () {
        final dt = DateTime.utc(2026, 1, 27, 17, 12, 7);
        final timestamp = DateTimeUtils.generateTimestamp(dt);
        expect(timestamp, equals('2026-01-27T171207'));
      });

      test('pads single digit values', () {
        final dt = DateTime.utc(2026, 1, 5, 3, 8, 9);
        final timestamp = DateTimeUtils.generateTimestamp(dt);
        expect(timestamp, equals('2026-01-05T030809'));
      });
    });

    group('generateTimestampWithNanos', () {
      test('includes nanoseconds', () {
        final dt = DateTime.utc(2026, 1, 27, 17, 12, 7, 0, 354);
        final timestamp = DateTimeUtils.generateTimestampWithNanos(dt);
        expect(timestamp, startsWith('2026-01-27T171207_'));
        // Format: YYYY-MM-DDTHHMMSS_SSSSSSSSS = 17 + 1 + 9 = 27 chars
        expect(timestamp.length, equals(27));
      });
    });

    group('parseTimestamp', () {
      test('parses standard format', () {
        final dt = DateTimeUtils.parseTimestamp('2026-01-27T171207-bookmark.url');
        expect(dt, isNotNull);
        expect(dt!.year, equals(2026));
        expect(dt.month, equals(1));
        expect(dt.day, equals(27));
        expect(dt.hour, equals(17));
        expect(dt.minute, equals(12));
        expect(dt.second, equals(7));
      });

      test('parses nanosecond format', () {
        final dt = DateTimeUtils.parseTimestamp('2026-01-27T171207_354000000-note.md');
        expect(dt, isNotNull);
        expect(dt!.year, equals(2026));
        expect(dt.month, equals(1));
        expect(dt.day, equals(27));
        expect(dt.hour, equals(17));
        expect(dt.minute, equals(12));
        expect(dt.second, equals(7));
        // 354000000 nanoseconds = 354 milliseconds + 0 microseconds
        expect(dt.millisecond, equals(354));
        expect(dt.microsecond, equals(0));
      });

      test('returns null for invalid format', () {
        final dt = DateTimeUtils.parseTimestamp('invalid-filename.txt');
        expect(dt, isNull);
      });
    });

    group('extractTimestampPrefix', () {
      test('extracts standard timestamp', () {
        final prefix = DateTimeUtils.extractTimestampPrefix('2026-01-27T171207-bookmark.url');
        expect(prefix, equals('2026-01-27T171207'));
      });

      test('extracts nanosecond timestamp', () {
        final prefix = DateTimeUtils.extractTimestampPrefix('2026-01-27T171207_354000000-note.md');
        expect(prefix, equals('2026-01-27T171207_354000000'));
      });

      test('returns null for invalid format', () {
        final prefix = DateTimeUtils.extractTimestampPrefix('invalid-filename.txt');
        expect(prefix, isNull);
      });
    });
  });
}
