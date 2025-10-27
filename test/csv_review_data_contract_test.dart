import 'package:denik_zza/input/csv_review_models.dart';
import 'package:denik_zza/input/input_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late InputParser parser;
  late CsvImportReviewBuilder builder;

  setUp(() {
    parser = InputParser();
    builder = CsvImportReviewBuilder(definition: parser.definition);
  });

  group('CsvImportReviewBuilder', () {
    test('marks missing mandatory first name as rejected', () async {
      final Answer answer = await parser.parseLine({
        1: 'Novák',
        2: '130610/2567',
      });
      answer.originalIndex = 1;

      final CsvImportReview review = builder.build([answer]);
      final CsvReviewRow row = review.rows.single;

      expect(row.status, CsvRowReviewStatus.rejected);
      expect(
        row.messages.map((CsvReviewMessage message) => message.message),
        contains(CsvReviewMessageCatalog.missingFirstNameValue),
      );
    });

    test('surface inferred values for gender and birthdate as info', () async {
      final Answer answer = await parser.parseLine({
        0: 'Jan',
        1: 'Novák',
        2: '130610/2567',
      });
      answer.originalIndex = 1;

      final CsvImportReview review = builder.build([answer]);
      final CsvReviewRow row = review.rows.single;

      expect(row.status, CsvRowReviewStatus.info);
      final CsvFieldReview genderField = row.fields['pohlavi']!;
      final CsvFieldReview birthField = row.fields['datum_narozeni']!;

      expect(genderField.inferred, isTrue);
      expect(birthField.inferred, isTrue);
      expect(row.derived['pohlavi']?.applied, isTrue);
      expect(row.derived['datum_narozeni']?.applied, isTrue);
      expect(
        row.messages.map((CsvReviewMessage message) => message.message),
        contains(CsvReviewMessageCatalog.genderInferred),
      );
      expect(
        row.messages.map((CsvReviewMessage message) => message.message),
        contains(CsvReviewMessageCatalog.birthdateInferred),
      );
    });

    test('warns when gender mismatches rodné číslo', () async {
      final Answer answer = await parser.parseLine({
        0: 'Jan',
        1: 'Novák',
        2: '130610/2567',
        3: '2',
        5: '10.06.2013',
      });
      answer.originalIndex = 1;

      final CsvImportReview review = builder.build([answer]);
      final CsvReviewRow row = review.rows.single;

      expect(row.status, CsvRowReviewStatus.warn);
      expect(
        row.messages.map((CsvReviewMessage message) => message.message),
        contains(CsvReviewMessageCatalog.genderMismatch),
      );
      expect(row.derived['pohlavi']?.applied, isFalse);
    });

    test('exposes provided unparsed columns and missing header warnings', () async {
      final CsvImportReviewBuilder customBuilder = CsvImportReviewBuilder(
        definition: parser.definition,
        missingColumnIndices: {0},
        unparsedColumns: const <String>['neočekávaný sloupec'],
      );

      final Answer answer = await parser.parseLine({
        1: 'Novák',
      });
      answer.originalIndex = 2;

      final CsvImportReview review = customBuilder.build([answer]);
      final CsvReviewRow row = review.rows.single;

      expect(review.unparsedColumns, contains('neočekávaný sloupec'));
      expect(row.status, CsvRowReviewStatus.rejected);
      expect(
        row.messages.map((CsvReviewMessage message) => message.message),
        contains(CsvReviewMessageCatalog.missingFirstNameColumn),
      );
      expect(row.originalIndex, 2);
    });
  });
}
