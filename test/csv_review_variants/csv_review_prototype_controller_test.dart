import 'package:denik_zza/input/csv_review_models.dart';
import 'package:denik_zza/input/input_parser.dart';
import 'package:denik_zza/screens2/csv_review_variants/csv_review_shared.dart';
import 'package:denik_zza/services/csv_import_service.dart';
import 'package:denik_zza/services/models/csv_import_payload.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils/csv_test_builders.dart';

void main() {
  group('CsvReviewPrototypeController', () {
    late _FakeCsvReviewService service;
    late CsvReviewPrototypeController controller;

    setUp(() {
      service = _FakeCsvReviewService();
      controller = CsvReviewPrototypeController.fromPath(
        path: 'ignored.csv',
        service: service,
      );
    });

    test('load populates rows and grouped data', () async {
      await controller.load();

      expect(controller.hasSession, isTrue);
      expect(controller.rows, hasLength(2));
      expect(controller.groupedRows[CsvRowReviewStatus.ok], hasLength(1));
      expect(controller.groupedRows[CsvRowReviewStatus.warn], hasLength(1));
      expect(controller.duplicateRowCount, equals(1));
    });

    test('decision helpers mutate state consistently', () async {
      await controller.load();

      controller.bulkApproveOk();
      expect(controller.approvedCount, equals(0));

      controller.bulkRejectAll();
      expect(controller.rejectedCount, equals(2));

      controller.bulkClearApprovals();
      expect(controller.approvedCount, equals(0));
    });

    test('editRow applies payload and updates row cache', () async {
      await controller.load();
      final CsvReviewRow row = controller.rows.first;

      final Map<String, String?> payload = controller.buildPayload(row);
      payload['jmeno'] = 'Karolina';

      final CsvReviewRow? updated = await controller.editRow(row, payload);

      expect(updated, isNotNull);
      expect(updated!.fields['jmeno']?.normalizedValue, equals('Karolina'));
      expect(controller.isRowEdited(row.originalIndex), isTrue);
      expect(controller.isCellEdited(row.originalIndex, 'jmeno'), isTrue);
      expect(controller.isCellEdited(row.originalIndex, 'prijmeni'), isFalse);
      expect(service.lastPayload?['jmeno'], equals('Karolina'));
    });
  });
}

class _FakeCsvReviewService implements CsvImportService {
  _FakeCsvReviewService()
      : _rows = <CsvReviewRow>[
          CsvReviewRowBuilder.build(
            index: 1,
            firstName: 'Alena',
            lastName: 'Nováková',
            status: CsvRowReviewStatus.ok,
          ),
          CsvReviewRowBuilder.buildWithWarning(
            index: 2,
            firstName: 'Jana',
            lastName: 'Svobodová',
            warningMessage: 'Zkontrolujte telefonní číslo.',
          ),
        ];

  final List<CsvReviewRow> _rows;
  Map<String, String?>? lastPayload;

  @override
  Future<CsvImportSession> loadCsv(String path) async {
    final CsvImportReview review = CsvImportReview(
      unparsedColumns: const <String>[],
      rows: _rows,
    );
    return CsvImportSession(
      review: review,
      personResult: PersonResult(<Answer>[]),
    );
  }

  @override
  Future<CsvImportSession> loadCsvFromPayload(CsvImportPayload payload) {
    if (payload.hasPath) {
      return loadCsv(payload.path!);
    }
    throw UnsupportedError('In-memory payloads are not supported in this test.');
  }

  @override
  Future<CsvReviewRow> reparseRow(Map<String, String?> updatedFields) async {
    lastPayload = Map<String, String?>.from(updatedFields);
    final int index = updatedFields['index'] as int? ?? 1;
    final CsvReviewRow existing =
        _rows.firstWhere((CsvReviewRow row) => row.originalIndex == index);
    final Map<String, CsvFieldReview> newFields = existing.fields.map(
      (String key, CsvFieldReview field) => MapEntry<String, CsvFieldReview>(
        key,
        CsvFieldReview(
          columnKey: field.columnKey,
          columnName: field.columnName,
          status: field.status,
          originalValue: updatedFields[key],
          normalizedValue: updatedFields[key],
          inferred: field.inferred,
          messages: field.messages,
        ),
      ),
    );
    final CsvReviewRow updated = CsvReviewRow(
      originalIndex: existing.originalIndex,
      status: existing.status,
      messages: existing.messages,
      fields: newFields,
      derived: existing.derived,
    );
    final int replaceIndex =
        _rows.indexWhere((CsvReviewRow row) => row.originalIndex == index);
    _rows[replaceIndex] = updated;
    return updated;
  }

  @override
  Future<CsvFinalizeResult> finalizeImport({
    required CsvImportSession session,
    required Map<int, CsvRowDecision> decisions,
  }) async {
    return CsvFinalizeResult(
      approvedCount: decisions.values
          .where(
              (CsvRowDecision decision) => decision == CsvRowDecision.approved)
          .length,
      rejectedCount: decisions.values
          .where(
              (CsvRowDecision decision) => decision == CsvRowDecision.rejected)
          .length,
      savedRowIndices: decisions.entries
          .where((MapEntry<int, CsvRowDecision> entry) =>
              entry.value == CsvRowDecision.approved)
          .map((MapEntry<int, CsvRowDecision> entry) => entry.key)
          .toList(),
      failures: const <CsvFinalizeFailure>[],
    );
  }

  @override
  Future<Map<int, List<CsvDuplicateCandidate>>> findPotentialDuplicates({
    required CsvImportSession session,
  }) async {
    return <int, List<CsvDuplicateCandidate>>{
      1: <CsvDuplicateCandidate>[
        CsvDuplicateCandidateBuilder.build(
          participantId: 10,
          displayName: 'Alena Nováková',
          reason: 'Stejné jméno a datum narození',
        ),
      ],
    };
  }
}
