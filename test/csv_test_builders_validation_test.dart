import 'package:denik_zza/input/csv_review_models.dart';
import 'package:denik_zza/input/rodne_cislo.dart';
import 'package:flutter_test/flutter_test.dart';
import 'utils/csv_test_builders.dart';

/// Verifies that CsvReviewRowBuilder generates valid rodné číslo values
void main() {
  group('CsvReviewRowBuilder RC validation', () {
    test('generates valid RC with proper checksum when not provided', () {
      // Build a row without providing rodné číslo - should generate valid one
      final CsvReviewRow row = CsvReviewRowBuilder.build(
        index: 0,
        firstName: 'Jan',
        lastName: 'Novák',
      );

      // Extract the generated RC
      final String? generatedRc = row.fields['rodne_cislo']!.originalValue;
      expect(generatedRc, isNotNull, reason: 'RC should be generated');

      // Verify it passes validation
      final RodneCislo rc = RodneCislo(generatedRc!);
      expect(rc.hasValidFormat, isTrue,
          reason: 'Generated RC should have valid format');
      expect(rc.hasValidSum, isTrue,
          reason: 'Generated RC should have valid checksum');
    });

    test('generates valid RC for female when pohlavi is 2', () {
      final CsvReviewRow row = CsvReviewRowBuilder.build(
        index: 0,
        firstName: 'Jana',
        lastName: 'Nováková',
        pohlavi: '2',
      );

      final String? generatedRc = row.fields['rodne_cislo']!.originalValue;
      expect(generatedRc, isNotNull);
      final RodneCislo rc = RodneCislo(generatedRc!);

      expect(rc.hasValidFormat, isTrue);
      expect(rc.hasValidSum, isTrue);
      // getPohlavi() returns int: 2 for female
      expect(rc.getPohlavi(), equals(2),
          reason: 'RC should indicate female gender');
    });

    test('generates valid RC for male when pohlavi is 1', () {
      final CsvReviewRow row = CsvReviewRowBuilder.build(
        index: 0,
        firstName: 'Jan',
        lastName: 'Novák',
        pohlavi: '1',
      );

      final String? generatedRc = row.fields['rodne_cislo']!.originalValue;
      expect(generatedRc, isNotNull);
      final RodneCislo rc = RodneCislo(generatedRc!);

      expect(rc.hasValidFormat, isTrue);
      expect(rc.hasValidSum, isTrue);
      // getPohlavi() returns int: 1 for male
      expect(rc.getPohlavi(), equals(1),
          reason: 'RC should indicate male gender');
    });

    test('uses custom RC when provided and skips generation', () {
      const String customRc = '0001010001';

      final CsvReviewRow row = CsvReviewRowBuilder.build(
        index: 0,
        firstName: 'Test',
        lastName: 'Person',
        rodneCislo: customRc,
      );

      final String? actualRc = row.fields['rodne_cislo']!.originalValue;
      expect(actualRc, equals(customRc),
          reason: 'Should use provided RC instead of generating');
    });

    test('multiple generated RCs are all valid', () {
      // Generate 10 different rows and verify all have valid RCs
      for (int i = 0; i < 10; i++) {
        final CsvReviewRow row = CsvReviewRowBuilder.build(
          index: i,
          firstName: 'Osoba$i',
          lastName: 'TestPrijmeni',
          pohlavi: i % 2 == 0 ? '1' : '2',
        );

        final String? generatedRc = row.fields['rodne_cislo']!.originalValue;
        expect(generatedRc, isNotNull, reason: 'Row $i: RC should be generated');
        final RodneCislo rc = RodneCislo(generatedRc!);

        expect(rc.hasValidFormat, isTrue,
            reason: 'Row $i: Generated RC should have valid format');
        expect(rc.hasValidSum, isTrue,
            reason: 'Row $i: Generated RC should have valid checksum');
      }
    });
  });
}
