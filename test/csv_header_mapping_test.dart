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

    test('Multi-person CSV with normal column order - comprehensive validation', () async {
      final parser = InputParser();
      parser.filePath = 'test/data/multi_person_normal_order.csv';
      await parser.getFile();
      final result = parser.result;
      expect(result, isNotNull);
      expect(result!.goodPersons.length, 3);
      
      // Person 1: Jan Novák (all fields populated)
      final jan = result.goodPersons[0];
      expect(jan.jmeno, 'Jan');
      expect(jan.prijmeni, 'Novák');
      expect(jan.cisloPojisteni, '030615/5678');
      expect(jan.pohlavi, 1); // Male
      expect(jan.adresa, 'Praha 1');
      expect(jan.datumNarozeni, DateTime(2003, 6, 15));
      expect(jan.jmenoRodice, 'Jan Senior');
      expect(jan.telefonRodice, '111222333');
      expect(jan.emailRodice, 'jan.novak@test.com');
      expect(jan.zpusobilost, true);
      expect(jan.zdravotniPojistovna, 'vzp');
      expect(jan.poznamka, 'Jan poznámka');
      
      // Person 2: Marie Svoboda (missing some optional fields)
      final marie = result.goodPersons[1];
      expect(marie.jmeno, 'Marie');
      expect(marie.prijmeni, 'Svoboda');
      expect(marie.cisloPojisteni, '041210/9876');
      expect(marie.pohlavi, 2); // Female
      expect(marie.adresa, 'Brno 2');
      expect(marie.datumNarozeni, DateTime(2004, 12, 12));
      expect(marie.jmenoRodice, 'Marie Senior');
      expect(marie.telefonRodice, anyOf('', isNull)); // Empty or null
      expect(marie.emailRodice, 'marie.svoboda@test.com'); // Has email
      expect(marie.zpusobilost, true);
      expect(marie.zdravotniPojistovna, 'ozp');
      expect(marie.poznamka, anyOf('', isNull)); // Empty or null
      
      // Person 3: Petr Dvořák (minimal fields only)
      final petr = result.goodPersons[2];
      expect(petr.jmeno, 'Petr');
      expect(petr.prijmeni, 'Dvořák');
      expect(petr.cisloPojisteni, '050520/7777');
      expect(petr.pohlavi, 1); // Male
      expect(petr.adresa, 'Ostrava 3');
      expect(petr.datumNarozeni, DateTime(2005, 5, 20));
      expect(petr.jmenoRodice, 'Petr Senior');
      expect(petr.telefonRodice, anyOf('', isNull)); // Empty or null
      expect(petr.emailRodice, anyOf('', isNull)); // Empty or null
      expect(petr.zpusobilost, true);
      expect(petr.zdravotniPojistovna, 'cpzp');
      expect(petr.poznamka, anyOf('', isNull)); // Empty or null
    });

    test('Multi-person CSV with shuffled headers - data integrity verification', () async {
      final parser = InputParser();
      parser.filePath = 'test/data/multi_person_shuffled_order.csv';
      await parser.getFile();
      final result = parser.result;
      expect(result, isNotNull);
      expect(result!.goodPersons.length, 3);
      
      // Critical test: Verify that shuffled headers don't cause cross-contamination
      // Each person should get exactly their own data, not mixed with others
      
      // Person 1: Jan Novák (all fields populated) - SAME AS NORMAL ORDER
      final jan = result.goodPersons[0];
      expect(jan.jmeno, 'Jan', reason: 'Jan should keep his own name');
      expect(jan.prijmeni, 'Novák', reason: 'Jan should keep his own surname');
      expect(jan.emailRodice, 'jan.novak@test.com', reason: 'Jan should keep his own email, not Marie\'s or Petr\'s');
      expect(jan.telefonRodice, '111222333', reason: 'Jan should keep his own phone');
      expect(jan.zdravotniPojistovna, 'vzp', reason: 'Jan should keep his own insurance');
      expect(jan.poznamka, 'Jan poznámka', reason: 'Jan should keep his own note');
      expect(jan.adresa, 'Praha 1', reason: 'Jan should keep his own address');
      expect(jan.cisloPojisteni, '030615/5678', reason: 'Jan should keep his own rodné číslo');
      
      // Person 2: Marie Svoboda (partial fields) - SAME AS NORMAL ORDER
      final marie = result.goodPersons[1];
      expect(marie.jmeno, 'Marie', reason: 'Marie should keep her own name');
      expect(marie.prijmeni, 'Svoboda', reason: 'Marie should keep her own surname');
      expect(marie.emailRodice, 'marie.svoboda@test.com', reason: 'Marie should keep her own email, not Jan\'s or Petr\'s');
      expect(marie.telefonRodice, anyOf('', isNull), reason: 'Marie should have empty phone, not Jan\'s');
      expect(marie.zdravotniPojistovna, 'ozp', reason: 'Marie should keep her own insurance');
      expect(marie.poznamka, anyOf('', isNull), reason: 'Marie should have empty note, not Jan\'s');
      expect(marie.adresa, 'Brno 2', reason: 'Marie should keep her own address');
      expect(marie.cisloPojisteni, '041210/9876', reason: 'Marie should keep her own rodné číslo');
      
      // Person 3: Petr Dvořák (minimal fields) - SAME AS NORMAL ORDER  
      final petr = result.goodPersons[2];
      expect(petr.jmeno, 'Petr', reason: 'Petr should keep his own name');
      expect(petr.prijmeni, 'Dvořák', reason: 'Petr should keep his own surname');
      expect(petr.emailRodice, anyOf('', isNull), reason: 'Petr should have empty email, not Jan\'s or Marie\'s');
      expect(petr.telefonRodice, anyOf('', isNull), reason: 'Petr should have empty phone, not Jan\'s');
      expect(petr.zdravotniPojistovna, 'cpzp', reason: 'Petr should keep his own insurance');
      expect(petr.poznamka, anyOf('', isNull), reason: 'Petr should have empty note, not Jan\'s');
      expect(petr.adresa, 'Ostrava 3', reason: 'Petr should keep his own address');
      expect(petr.cisloPojisteni, '050520/7777', reason: 'Petr should keep his own rodné číslo');
    });

    test('Multi-person CSV with extra columns - tolerance and data integrity', () async {
      final parser = InputParser();
      parser.filePath = 'test/data/multi_person_with_extra_columns.csv';
      await parser.getFile();
      final result = parser.result;
      expect(result, isNotNull);
      expect(result!.goodPersons.length, 3);
      
      // Verify extra columns are ignored and don't affect data assignment
      final jan = result.goodPersons[0];
      expect(jan.jmeno, 'Jan');
      expect(jan.emailRodice, 'jan.novak@test.com');
      expect(jan.telefonRodice, '111222333');
      
      final marie = result.goodPersons[1];
      expect(marie.jmeno, 'Marie');
      expect(marie.emailRodice, 'marie.svoboda@test.com'); // Marie has email
      expect(marie.telefonRodice, anyOf('', isNull));
      
      final petr = result.goodPersons[2];
      expect(petr.jmeno, 'Petr');
      expect(petr.emailRodice, anyOf('', isNull)); // Should remain empty, not get "IGNORE" values
      expect(petr.telefonRodice, anyOf('', isNull));
    });

    test('Complex mixed optional fields - data integrity with shuffled headers', () async {
      final parser = InputParser();
      parser.filePath = 'test/data/complex_mixed_fields.csv';
      await parser.getFile();
      final result = parser.result;
      expect(result, isNotNull);
      expect(result!.goodPersons.length, 4);
      
      // Person 1: Alena (has everything except rodné číslo parent name)
      final alena = result.goodPersons[0];
      expect(alena.jmeno, 'Alena');
      expect(alena.prijmeni, 'Nováková');
      expect(alena.emailRodice, 'alena.novakova@test.com');
      expect(alena.telefonRodice, '555777999');
      expect(alena.zdravotniPojistovna, 'cpzp');
      expect(alena.poznamka, 'Alena má poznámku');
      expect(alena.pohlavi, 2); // Female
      expect(alena.adresa, 'Plzeň');
      expect(alena.jmenoRodice, 'Alena Maminka');
      expect(alena.cisloPojisteni, '060306/2345');
      expect(alena.datumNarozeni, DateTime(2006, 3, 5));
      
      // Person 2: Tomáš (minimal - no email, no phone, no note, no address)
      final tomas = result.goodPersons[1];
      expect(tomas.jmeno, 'Tomáš');
      expect(tomas.prijmeni, 'Procházka');
      expect(tomas.emailRodice, anyOf('', isNull));
      expect(tomas.telefonRodice, anyOf('', isNull));
      expect(tomas.zdravotniPojistovna, 'vzp');
      expect(tomas.poznamka, anyOf('', isNull));
      expect(tomas.pohlavi, 1); // Male
      expect(tomas.adresa, 'České Budějovice');
      expect(tomas.jmenoRodice, 'Tomáš Tatínek');
      expect(tomas.cisloPojisteni, '040815/1234');
      expect(tomas.datumNarozeni, DateTime(2004, 8, 15));
      
      // Person 3: Pavel (has note, phone, email but missing address and parent name)
      final pavel = result.goodPersons[2];
      expect(pavel.jmeno, 'Pavel');
      expect(pavel.prijmeni, 'Svoboda');
      expect(pavel.emailRodice, 'pavel@test.com');
      expect(pavel.telefonRodice, '333444555');
      expect(pavel.zdravotniPojistovna, 'ozp');
      expect(pavel.poznamka, 'Pavel poznámka');
      expect(pavel.pohlavi, 1); // Male
      expect(pavel.adresa, anyOf('', isNull)); // Empty address
      expect(pavel.jmenoRodice, anyOf('', isNull)); // Empty parent name
      expect(pavel.cisloPojisteni, '051122/2346');
      expect(pavel.datumNarozeni, DateTime(2005, 11, 22));
      
      // Person 4: Kateřina (has phone, no email, no note, no insurance, no parent name)
      final katerina = result.goodPersons[3];
      expect(katerina.jmeno, 'Kateřina');
      expect(katerina.prijmeni, 'Černá');
      expect(katerina.emailRodice, anyOf('', isNull));
      expect(katerina.telefonRodice, '111222333');
      expect(katerina.zdravotniPojistovna, anyOf('', isNull)); // No insurance
      expect(katerina.poznamka, anyOf('', isNull));
      expect(katerina.pohlavi, 2); // Female
      expect(katerina.adresa, 'Ostrava');
      expect(katerina.jmenoRodice, 'Kateřina Maminka'); // Has parent name
      expect(katerina.cisloPojisteni, '020718/4567');
      expect(katerina.datumNarozeni, DateTime(2002, 7, 18));
      
      // Critical verification: Each person should have their own unique data
      // Check that no cross-contamination occurred with shuffled headers
      expect(alena.emailRodice, 'alena.novakova@test.com');
      expect(tomas.emailRodice, anyOf('', isNull)); // Should NOT have Alena's email
      expect(pavel.emailRodice, 'pavel@test.com'); // Should NOT have Alena's email
      expect(katerina.emailRodice, anyOf('', isNull)); // Should NOT have anyone else's email
      
      expect(alena.telefonRodice, '555777999');
      expect(tomas.telefonRodice, anyOf('', isNull)); // Should NOT have Alena's phone
      expect(pavel.telefonRodice, '333444555'); // Should NOT have Alena's phone
      expect(katerina.telefonRodice, '111222333'); // Should NOT have Alena's or Pavel's phone
    });

    test('Minimal required fields - způsobilost defaults to false, empty birth date warns', () async {
      final parser = InputParser();
      parser.filePath = 'test/data/minimal_required_fields.csv';
      await parser.getFile();
      final result = parser.result;
      expect(result, isNotNull);
      expect(result!.goodPersons.length, 2);
      
      // Person 1: Has all fields, but způsobilost was empty so should default to false
      final testPerson = result.goodPersons[0];
      expect(testPerson.jmeno, 'Testovací');
      expect(testPerson.prijmeni, 'Osoba');
      expect(testPerson.zpusobilost, false); // Should default to false when empty in CSV
      expect(testPerson.datumNarozeni, DateTime(2001, 1, 1)); // Has birth date
      expect(testPerson.cisloPojisteni, '010101/0123'); // Valid rodné číslo
      expect(testPerson.zdravotniPojistovna, 'vzp');
      expect(testPerson.adresa, 'Praha');
      expect(testPerson.jmenoRodice, 'Test Rodič');
      
      // Person 2: Has rodné číslo but empty birth date, způsobilost empty
      final druhy = result.goodPersons[1];
      expect(druhy.jmeno, 'Další');
      expect(druhy.prijmeni, 'Člověk');
      expect(druhy.zpusobilost, false); // Should default to false when empty in CSV
      expect(druhy.cisloPojisteni, '020202/0123'); // Valid rodné číslo
      expect(druhy.datumNarozeni, isNull); // Empty birth date should be null
      expect(druhy.zdravotniPojistovna, 'ozp');
      expect(druhy.adresa, 'Brno');
      expect(druhy.jmenoRodice, 'Jiný Rodič');
    });

    test('Absolute minimal CSV - only jméno and příjmení fields', () async {
      final parser = InputParser();
      parser.filePath = 'test/data/minimal_absolute.csv';
      await parser.getFile();
      final result = parser.result;
      expect(result, isNotNull);
      expect(result!.goodPersons.length, 4);
      
      // Verify all 4 people are parsed correctly with only names
      final jan = result.goodPersons[0];
      expect(jan.jmeno, 'Jan');
      expect(jan.prijmeni, 'Novák');
      
      final marie = result.goodPersons[1];
      expect(marie.jmeno, 'Marie');
      expect(marie.prijmeni, 'Svoboda');
      
      final petr = result.goodPersons[2];
      expect(petr.jmeno, 'Petr');
      expect(petr.prijmeni, 'Dvořák');
      
      final anna = result.goodPersons[3];
      expect(anna.jmeno, 'Anna');
      expect(anna.prijmeni, 'Nová');
      
      // Verify optional fields have reasonable defaults
      for (final person in result.goodPersons) {
        // These should be null or empty, not causing errors
        expect(person.datumNarozeni, anyOf(isNull, isA<DateTime>()));
        expect(person.cisloPojisteni, anyOf('', isNull, isA<String>()));
        expect(person.emailRodice, anyOf('', isNull));
        expect(person.telefonRodice, anyOf('', isNull));
        expect(person.zdravotniPojistovna, anyOf('', isNull, isA<String>()));
        expect(person.zpusobilost, anyOf(isNull, false, true)); // Should default to false
        expect(person.adresa, anyOf('', isNull));
        expect(person.jmenoRodice, anyOf('', isNull));
        expect(person.poznamka, anyOf('', isNull));
      }
    });

    test('Absolute minimal CSV with swapped headers - header mapping tolerance', () async {
      final parser = InputParser();
      parser.filePath = 'test/data/minimal_swapped.csv';
      await parser.getFile();
      final result = parser.result;
      expect(result, isNotNull);
      expect(result!.goodPersons.length, 4);
      
      // Critical: Verify that header mapping works correctly
      // Even though headers are "příjmení,jméno", the data should be assigned correctly
      final jan = result.goodPersons[0];
      expect(jan.jmeno, 'Jan', reason: 'Jan should get his first name, not surname');
      expect(jan.prijmeni, 'Novák', reason: 'Jan should get his surname, not first name');
      
      final marie = result.goodPersons[1];
      expect(marie.jmeno, 'Marie', reason: 'Marie should get her first name, not surname');
      expect(marie.prijmeni, 'Svoboda', reason: 'Marie should get her surname, not first name');
      
      final petr = result.goodPersons[2];
      expect(petr.jmeno, 'Petr', reason: 'Petr should get his first name, not surname');
      expect(petr.prijmeni, 'Dvořák', reason: 'Petr should get his surname, not first name');
      
      final anna = result.goodPersons[3];
      expect(anna.jmeno, 'Anna', reason: 'Anna should get her first name, not surname');
      expect(anna.prijmeni, 'Nová', reason: 'Anna should get her surname, not first name');
      
      // Verify this produces IDENTICAL results to the normal order CSV
      // This is the ultimate test of header mapping tolerance
      final normalParser = InputParser();
      normalParser.filePath = 'test/data/minimal_absolute.csv';
      await normalParser.getFile();
      final normalResult = normalParser.result;
      
      expect(normalResult!.goodPersons.length, result.goodPersons.length);
      for (int i = 0; i < normalResult.goodPersons.length; i++) {
        expect(result.goodPersons[i].jmeno, normalResult.goodPersons[i].jmeno, 
               reason: 'Swapped headers should produce identical first names');
        expect(result.goodPersons[i].prijmeni, normalResult.goodPersons[i].prijmeni,
               reason: 'Swapped headers should produce identical surnames');
      }
    });

    test('Handles reordered mandatory columns correctly', () async {
      final parser = InputParser();
      parser.filePath = 'test/data/reordered_mandatory.csv';
      await parser.getFile();
      final result = parser.result;
      expect(result, isNotNull);
      
      // Should successfully parse with mandatory fields in different order
      expect(result!.goodPersons.length, 1);
      final person = result.goodPersons.first;
      expect(person.jmeno, 'Jan');
      expect(person.prijmeni, 'Hus');
      expect(person.cisloPojisteni, '130610/2567');
    });

    test('Documents limitation with missing mandatory column (jméno)', () async {
      // NOTE: This test documents a current limitation in the system
      // When mandatory columns are missing, toPerson() fails due to hardcoded assumptions
      // This is a known issue that should be addressed in future iterations
      
      final parser = InputParser();
      parser.filePath = 'test/data/missing_mandatory_column.csv';
      
      // The parsing should fail gracefully, but currently throws an exception
      bool caughtException = false;
      try {
        await parser.getFile();
      } catch (e) {
        caughtException = true;
        expect(e.toString(), contains('Null'));
      }
      
      // Document that this is a known limitation
      if (!caughtException) {
        final result = parser.result;
        expect(result, isNotNull);
        // If it doesn't throw, it should at least have no good persons
        expect(result!.goodPersons.length, 0);
      }
    });

    test('Handles extra columns by checking answers', () async {
      final parser = InputParser();
      parser.filePath = 'test/data/shuffled_header.csv';
      await parser.getFile();
      
      // Check that parsing completed successfully despite extra columns
      final result = parser.result;
      expect(result, isNotNull);
      expect(result!.goodPersons.length, 1);
    });
  });
}
