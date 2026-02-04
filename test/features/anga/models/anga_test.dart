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
        const content =
            '[InternetShortcut]\nURL=https://www.example.com/path\n';
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
      final filename = generateBookmarkFilename(
        'https://www.example.com/path?q=1',
        ts,
      );

      expect(filename, equals('2026-01-27T171207-www-example-com.url'));
    });

    test('generateBookmarkFilename handles complex domains', () {
      final ts = DateTime.utc(2026, 1, 27, 17, 12, 7);
      final filename = generateBookmarkFilename(
        'https://sub.domain.example.co.uk/',
        ts,
      );

      expect(
        filename,
        equals('2026-01-27T171207-sub-domain-example-co-uk.url'),
      );
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

    test('generateFileFilename URL-encodes spaces and special characters', () {
      final ts = DateTime.utc(2026, 1, 27, 17, 12, 7);
      final filename = generateFileFilename('GNOME Regento NDA.pdf', ts);

      // Spaces should be encoded as %20
      expect(filename, equals('2026-01-27T171207-GNOME%20Regento%20NDA.pdf'));
      expect(filename, isNot(contains(' ')));
    });

    test('generateFileFilename URL-encodes unicode characters', () {
      final ts = DateTime.utc(2026, 1, 27, 17, 12, 7);
      final filename = generateFileFilename('документ.pdf', ts);

      // Cyrillic characters should be URL-encoded
      expect(filename, startsWith('2026-01-27T171207-'));
      expect(filename, endsWith('.pdf'));
      expect(filename, isNot(contains('д'))); // Should be encoded
    });
  });

  group('displayTitle URL decoding', () {
    test('decodes URL-encoded filename for display', () {
      final anga = Anga.fromPath(
        '/kaya/anga/2026-01-27T171207-GNOME%20Regento%20NDA.pdf',
      );

      // displayTitle should show decoded name with spaces, including extension
      expect(anga.displayTitle, equals('GNOME Regento NDA.pdf'));
    });

    test('decodes complex URL-encoded filename for display', () {
      final anga = Anga.fromPath(
        '/kaya/anga/2026-01-27T171207-My%20File%20%2B%20Notes.txt',
      );

      // %2B is URL-encoded +, extension is preserved
      expect(anga.displayTitle, equals('My File + Notes.txt'));
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
