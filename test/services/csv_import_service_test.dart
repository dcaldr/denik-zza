import 'package:denik_zza/input/csv_review_models.dart';
import 'package:denik_zza/input/input_parser.dart';
import 'package:denik_zza/services/csv_import_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CsvImportService', () {
    late DefaultCsvImportService service;

    setUp(() {
      service = DefaultCsvImportService();
    });

    test('loadCsv returns review and person result', () async {
      final CsvImportSession session =
          await service.loadCsv('test/data/first.csv');

      expect(session.review.rows, isNotEmpty);
      expect(session.personResult.goodPersons, isNotEmpty);
      expect(session.passingPersons, isNotEmpty);
      expect(session.passingCount, session.passingPersons.length);
      final CsvReviewRow row = session.review.rows.first;
      expect(row.status, CsvRowReviewStatus.ok);
      expect(row.fields.containsKey('jmeno'), isTrue);
      expect(row.fields['jmeno']?.status, CsvFieldReviewStatus.ok);
    });

    test('reparseRow infers values when rodné číslo present', () async {
      final CsvReviewRow row = await service.reparseRow(<String, String?>{
        'jmeno': 'Jan',
        'prijmeni': 'Novák',
        'rodne_cislo': '130610/2567',
      });

      expect(row.status, CsvRowReviewStatus.info);
      expect(row.messages.any(
        (CsvReviewMessage message) =>
            message.message == CsvReviewMessageCatalog.genderInferred,
      ), isTrue);
      expect(row.fields['pohlavi']?.inferred, isTrue);
      expect(row.fields['datum_narozeni']?.inferred, isTrue);
    });

    test('reparseRow rejects when mandatory field missing', () async {
      final CsvReviewRow row = await service.reparseRow(<String, String?>{
        'prijmeni': 'Novák',
        'rodne_cislo': '130610/2567',
      });

      expect(row.status, CsvRowReviewStatus.rejected);
      expect(row.messages.any(
        (CsvReviewMessage message) =>
            message.message == CsvReviewMessageCatalog.missingFirstNameValue,
      ), isTrue);
    });
  });
}
