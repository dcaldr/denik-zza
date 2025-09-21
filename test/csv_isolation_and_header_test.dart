import 'dart:io';

import 'package:denik_zza/csv/csv_reader.dart';
import 'package:denik_zza/input/input_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CsvReader.getHeader reads from file contents', () {
    test('returns first line as header with autodetected delimiter', () async {
      final tmp = await Directory.systemTemp.createTemp('csv_header_');
      try {
        final file = File('${tmp.path}/data.csv');
        await file.writeAsString('a;b\n1;2');
        final reader = CsvReader(file.path);
        final header = reader.getHeader();
        expect(header, isNotNull);
        expect(header, ['a', 'b']);
      } finally {
        await tmp.delete(recursive: true);
      }
    });
  });

  group('InputParser isolation and non-reentrancy', () {
    test('fresh holds per line - mutating one Answer does not affect the other', () async {
      final parser = InputParser();
      parser.filePath = 'test/data/first.csv';
      await parser.getFile();
      final result = parser.result;
      expect(result, isNotNull);
      expect(result!.answers.length, greaterThan(0));

      // Take first two answers if available; otherwise duplicate first line to simulate two lines
      final answers = result.answers;
      if (answers.length >= 2) {
        final a1 = answers[0];
        final a2 = answers[1];
        // mutate a1's first field output
        a1.data[0].addInput('XMutated');
        expect(a1.data[0].getOutput(), 'XMutated');
        // a2 should remain unchanged
        expect(a2.data[0].getOutput(), isNot('XMutated'));
      } else {
        // Construct two answers manually from same underlying data to ensure isolation works via parseLine
        final line = ['A','B','', '', '', '', '', '', '', '', '', ''];
        // Convert list to sparse map format expected by parseLine
        final sparseData = <int, String>{};
        for (int i = 0; i < line.length; i++) {
          sparseData[i] = line[i];
        }
        final a1 = await parser.parseLine(sparseData);
        final a2 = await parser.parseLine(sparseData);
        a1.data[0].addInput('XMutated');
        expect(a1.data[0].getOutput(), 'XMutated');
        expect(a2.data[0].getOutput(), isNot('XMutated'));
      }
    });

    test('calculateStatus does not recurse via getters', () async {
      final parser = InputParser();
      // Build a simple line with minimal valid name/surname and missing rc -> warn
      final line = ['Jan', 'Novak', '', '', '', '', '', '', '', '', '', ''];
      // Convert list to sparse map format expected by parseLine
      final sparseData = <int, String>{};
      for (int i = 0; i < line.length; i++) {
        sparseData[i] = line[i];
      }
      final ans = await parser.parseLine(sparseData);
      // Call calculateStatus explicitly and via getters
      ans.calculateStatus();
      final data = ans.data; // should not cause recursion/stack overflow
      expect(data, isNotEmpty);
      expect(ans.lineStatus.index >= 0, isTrue);
    });
  });
}
