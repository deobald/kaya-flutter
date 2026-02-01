import 'package:flutter_test/flutter_test.dart';
import 'package:kaya/features/meta/models/anga_meta.dart';

void main() {
  group('AngaMeta', () {
    group('fromToml', () {
      test('parses valid TOML', () {
        const toml = '''
[anga]
filename = "2026-01-28T205208-bookmark.url"

[meta]
tags = ["podcast", "democracy", "cooperatives"]
note = "This is a test note"
''';

        final meta = AngaMeta.fromToml(
          '/kaya/meta/2026-01-28T210000-meta.toml',
          toml,
        );

        expect(meta.angaFilename, equals('2026-01-28T205208-bookmark.url'));
        expect(meta.tags, containsAll(['podcast', 'democracy', 'cooperatives']));
        expect(meta.note, equals('This is a test note'));
      });

      test('handles missing note', () {
        const toml = '''
[anga]
filename = "2026-01-28T205208-bookmark.url"

[meta]
tags = ["test"]
''';

        final meta = AngaMeta.fromToml(
          '/kaya/meta/2026-01-28T210000-meta.toml',
          toml,
        );

        expect(meta.note, isNull);
      });

      test('handles empty tags', () {
        const toml = '''
[anga]
filename = "2026-01-28T205208-bookmark.url"

[meta]
tags = []
''';

        final meta = AngaMeta.fromToml(
          '/kaya/meta/2026-01-28T210000-meta.toml',
          toml,
        );

        expect(meta.tags, isEmpty);
      });

      test('handles multiline notes', () {
        const toml = """
[anga]
filename = "2026-01-28T205208-bookmark.url"

[meta]
tags = []
note = '''This is a longer note.

It has multiple lines.'''
""";

        final meta = AngaMeta.fromToml(
          '/kaya/meta/2026-01-28T210000-meta.toml',
          toml,
        );

        expect(meta.note, contains('multiple lines'));
      });

      test('returns empty metadata for invalid TOML', () {
        const toml = 'invalid toml content {{{';

        final meta = AngaMeta.fromToml(
          '/kaya/meta/2026-01-28T210000-meta.toml',
          toml,
        );

        expect(meta.angaFilename, isEmpty);
        expect(meta.tags, isEmpty);
      });
    });

    group('toToml', () {
      test('generates valid TOML', () {
        final meta = AngaMeta(
          metaFilename: '2026-01-28T210000-meta.toml',
          path: '/kaya/meta/2026-01-28T210000-meta.toml',
          angaFilename: '2026-01-28T205208-bookmark.url',
          tags: ['tag1', 'tag2'],
          note: 'Test note',
          createdAt: DateTime.utc(2026, 1, 28, 21, 0, 0),
        );

        final toml = meta.toToml();

        expect(toml, contains('[anga]'));
        expect(toml, contains('filename = "2026-01-28T205208-bookmark.url"'));
        expect(toml, contains('[meta]'));
        expect(toml, contains('tags = ["tag1", "tag2"]'));
        expect(toml, contains('note = "Test note"'));
      });

      test('handles empty tags', () {
        final meta = AngaMeta(
          metaFilename: '2026-01-28T210000-meta.toml',
          path: '/kaya/meta/2026-01-28T210000-meta.toml',
          angaFilename: '2026-01-28T205208-bookmark.url',
          tags: [],
          createdAt: DateTime.utc(2026, 1, 28, 21, 0, 0),
        );

        final toml = meta.toToml();

        expect(toml, contains('tags = []'));
      });
    });
  });

  group('generateMetaFilename', () {
    test('generates correct format', () {
      final ts = DateTime.utc(2026, 1, 28, 21, 0, 0);
      final filename = generateMetaFilename('meta', ts);

      expect(filename, equals('2026-01-28T210000-meta.toml'));
    });
  });
}
