import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kaya/features/anga/services/file_storage_service.dart';

void main() {
  group('FileStorageService', () {
    late Directory tempDir;
    late FileStorageService service;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('kaya_test_');
      service = FileStorageService(tempDir.path, null);
      await service.ensureDirectories();
    });

    tearDown(() async {
      await tempDir.delete(recursive: true);
    });

    group('getWordsText', () {
      test(
        'returns words for bookmark with .url extension in directory name',
        () async {
          // This tests the bug fix: words directories use the FULL anga filename
          // including extension, not the filename with extension stripped.
          //
          // Server stores: /kaya/words/2026-01-19T012724-bookmark.url/
          // Anga filename: 2026-01-19T012724-bookmark.url
          // getWordsText should find it by using the full filename as directory name

          const angaFilename = '2026-01-19T012724-bookmark.url';
          const wordsContent =
              'This page contains notwithstanding and collectively';

          // Create words directory with FULL filename (including .url extension)
          final wordsDir = Directory('${service.wordsPath}/$angaFilename');
          await wordsDir.create(recursive: true);
          await File('${wordsDir.path}/content.md').writeAsString(wordsContent);

          // getWordsText should find it
          final result = await service.getWordsText(angaFilename);

          expect(result, isNotNull);
          expect(result, contains('notwithstanding'));
          expect(result, contains('collectively'));
        },
      );

      test(
        'returns words for PDF with .pdf extension in directory name',
        () async {
          // Same test but for PDF files
          const angaFilename = '2025-01-01T120000-GNOME Regento NDA.pdf';
          const wordsContent =
              'AGREEMENT collectively the Parties notwithstanding any other provision';

          // Create words directory with FULL filename (including .pdf extension)
          final wordsDir = Directory('${service.wordsPath}/$angaFilename');
          await wordsDir.create(recursive: true);
          await File(
            '${wordsDir.path}/extracted.txt',
          ).writeAsString(wordsContent);

          // getWordsText should find it
          final result = await service.getWordsText(angaFilename);

          expect(result, isNotNull);
          expect(result, contains('collectively'));
          expect(result, contains('notwithstanding'));
          expect(result, contains('AGREEMENT'));
        },
      );

      test('returns null when no words directory exists', () async {
        const angaFilename = '2026-01-27T171207-nonexistent.url';

        final result = await service.getWordsText(angaFilename);

        expect(result, isNull);
      });

      test('returns null when words directory is empty', () async {
        const angaFilename = '2026-01-27T171207-empty.url';

        // Create empty words directory
        final wordsDir = Directory('${service.wordsPath}/$angaFilename');
        await wordsDir.create(recursive: true);

        final result = await service.getWordsText(angaFilename);

        expect(result, isNull);
      });

      test('concatenates multiple words files', () async {
        const angaFilename = '2026-01-27T171207-multi.url';

        // Create words directory with multiple files
        final wordsDir = Directory('${service.wordsPath}/$angaFilename');
        await wordsDir.create(recursive: true);
        await File('${wordsDir.path}/part1.txt').writeAsString('first part');
        await File('${wordsDir.path}/part2.txt').writeAsString('second part');

        final result = await service.getWordsText(angaFilename);

        expect(result, isNotNull);
        expect(result, contains('first part'));
        expect(result, contains('second part'));
      });

      test(
        'regression: does NOT strip extension when looking up words directory',
        () async {
          // This is the specific regression test for the bug.
          // OLD (broken) behavior: _wordsAngaName('file.url') => 'file'
          // NEW (correct) behavior: _wordsAngaName('file.url') => 'file.url'
          //
          // If we create a directory WITHOUT extension, getWordsText should NOT find it
          // (because the server uses full filenames with extensions)

          const angaFilename = '2026-01-27T171207-test.url';
          const wordsContent = 'should not be found';

          // Create words directory WITHOUT extension (the OLD broken behavior would look here)
          final wrongDir = Directory(
            '${service.wordsPath}/2026-01-27T171207-test',
          );
          await wrongDir.create(recursive: true);
          await File(
            '${wrongDir.path}/content.txt',
          ).writeAsString(wordsContent);

          // getWordsText should NOT find it because it uses full filename
          final result = await service.getWordsText(angaFilename);

          expect(
            result,
            isNull,
            reason: 'Should not find words in directory without extension',
          );

          // Now create the correct directory WITH extension
          final correctDir = Directory('${service.wordsPath}/$angaFilename');
          await correctDir.create(recursive: true);
          await File(
            '${correctDir.path}/content.txt',
          ).writeAsString('correct content');

          final correctResult = await service.getWordsText(angaFilename);

          expect(correctResult, isNotNull);
          expect(correctResult, equals('correct content'));
        },
      );
    });

    group('saveWordsFile and listWordsAngas', () {
      test('saveWordsFile creates directory with full anga name', () async {
        const angaName = '2026-01-27T171207-bookmark.url';
        const filename = 'content.md';
        final content = 'test content'.codeUnits;

        await service.saveWordsFile(angaName, filename, content);

        final angas = await service.listWordsAngas();
        expect(angas, contains(angaName));

        final files = await service.listWordsFiles(angaName);
        expect(files, contains(filename));
      });
    });
  });
}
