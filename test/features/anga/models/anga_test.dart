import 'package:flutter_test/flutter_test.dart';
import 'package:kaya/features/anga/models/anga.dart';
import 'package:kaya/features/anga/models/anga_type.dart';

void main() {
  group('Anga', () {
    group('fromPath', () {
      test('creates bookmark anga from .url file', () {
        const content = '[InternetShortcut]\nURL=https://example.com/\n';
        final anga = Anga.fromPath(
          '/kaya/anga/2026-01-27T171207-example-com.url',
          content: content,
        );

        expect(anga.type, equals(AngaType.bookmark));
        expect(anga.url, equals('https://example.com/'));
        expect(anga.filename, equals('2026-01-27T171207-example-com.url'));
      });

      test('creates note anga from -note.md file', () {
        const content = 'This is my note';
        final anga = Anga.fromPath(
          '/kaya/anga/2026-01-27T171207-note.md',
          content: content,
        );

        expect(anga.type, equals(AngaType.note));
        expect(anga.content, equals(content));
      });

      test('creates file anga for other extensions', () {
        final anga = Anga.fromPath('/kaya/anga/2026-01-27T171207-image.png');

        expect(anga.type, equals(AngaType.file));
        expect(anga.extension, equals('png'));
        expect(anga.isImage, isTrue);
      });
    });

    group('displayTitle', () {
      test('returns domain for bookmarks', () {
        const content = '[InternetShortcut]\nURL=https://www.example.com/path\n';
        final anga = Anga.fromPath(
          '/kaya/anga/2026-01-27T171207-www-example-com.url',
          content: content,
        );

        expect(anga.displayTitle, equals('www.example.com'));
      });

      test('returns first line for notes', () {
        const content = 'First line\nSecond line';
        final anga = Anga.fromPath(
          '/kaya/anga/2026-01-27T171207-note.md',
          content: content,
        );

        expect(anga.displayTitle, equals('First line'));
      });

      test('truncates long titles', () {
        final longContent = 'A' * 100;
        final anga = Anga.fromPath(
          '/kaya/anga/2026-01-27T171207-note.md',
          content: longContent,
        );

        expect(anga.displayTitle.length, lessThanOrEqualTo(50));
        expect(anga.displayTitle, endsWith('...'));
      });
    });

    group('file type detection', () {
      test('detects image files', () {
        final anga = Anga.fromPath('/kaya/anga/2026-01-27T171207-photo.jpg');
        expect(anga.isImage, isTrue);
        expect(anga.isVideo, isFalse);
        expect(anga.isPdf, isFalse);
      });

      test('detects video files', () {
        final anga = Anga.fromPath('/kaya/anga/2026-01-27T171207-video.mp4');
        expect(anga.isVideo, isTrue);
        expect(anga.isImage, isFalse);
      });

      test('detects PDF files', () {
        final anga = Anga.fromPath('/kaya/anga/2026-01-27T171207-document.pdf');
        expect(anga.isPdf, isTrue);
      });
    });
  });

  group('filename generation', () {
    test('generateBookmarkFilename creates correct format', () {
      final ts = DateTime.utc(2026, 1, 27, 17, 12, 7);
      final filename = generateBookmarkFilename('https://www.example.com/path?q=1', ts);

      expect(filename, equals('2026-01-27T171207-www-example-com.url'));
    });

    test('generateBookmarkFilename handles complex domains', () {
      final ts = DateTime.utc(2026, 1, 27, 17, 12, 7);
      final filename = generateBookmarkFilename('https://sub.domain.example.co.uk/', ts);

      expect(filename, equals('2026-01-27T171207-sub-domain-example-co-uk.url'));
    });

    test('generateNoteFilename creates correct format', () {
      final ts = DateTime.utc(2026, 1, 27, 17, 12, 7);
      final filename = generateNoteFilename(ts);

      expect(filename, equals('2026-01-27T171207-note.md'));
    });

    test('generateFileFilename preserves extension', () {
      final ts = DateTime.utc(2026, 1, 27, 17, 12, 7);
      final filename = generateFileFilename('my-photo.jpg', ts);

      expect(filename, equals('2026-01-27T171207-my-photo.jpg'));
    });
  });

  group('createBookmarkContent', () {
    test('creates Windows .url format', () {
      final content = createBookmarkContent('https://example.com/');

      expect(content, contains('[InternetShortcut]'));
      expect(content, contains('URL=https://example.com/'));
    });
  });
}
