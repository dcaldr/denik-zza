import 'package:denik_zza/input/input_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CSV header mapping', () {
    test('Parses CSV with shuffled headers and extra column', () async {
      final parser = InputParser();
      parser.filePath = 'test/data/shuffled_header.csv';
      await parser.getFile();
      final result = parser.result;
      expect(result, isNotNull);
      expect(result!.goodPersons.length, 1);
      final person = result.goodPersons.first;
      expect(person.jmeno, 'Jan');
      expect(person.prijmeni, 'Hus');
      expect(person.cisloPojisteni, '130610/2567');
      expect(person.datumNarozeni, DateTime(2013, 6, 10));
      expect(person.emailRodice, 'hello@proble.com');
      expect(person.telefonRodice, '123456');
      expect(person.zdravotniPojistovna, 'ozp');
    });
  });
}
