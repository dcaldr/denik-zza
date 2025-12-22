import 'package:denik_zza/input/csv_review_models.dart';
import 'package:denik_zza/input/input_parser.dart';
import 'package:denik_zza/screens2/csv/csv_review_shared.dart';
import 'package:denik_zza/services/csv_import_service.dart';
import 'package:denik_zza/services/models/csv_import_payload.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils/csv_test_builders.dart';
import 'package:logger/logger.dart';
import 'package:denik_zza/utils/app_logger.dart';

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

    // ═══════════════════════════════════════════════════════════════
    // EDGE CASES: Error Handling and Lifecycle
    // ═══════════════════════════════════════════════════════════════

    test('handles load error gracefully', () async {
      AppLogger.configureForTests(level: Level.off);
      addTearDown(() => AppLogger.configureForTests(level: Level.error));

      final _ErrorThrowingService errorService = _ErrorThrowingService();
      final CsvReviewPrototypeController errorController =
          CsvReviewPrototypeController.fromPath(
        path: 'error.csv',
        service: errorService,
      );

      await errorController.load();

      expect(errorController.isLoading, isFalse);
      expect(errorController.loadError, isNotNull);
      expect(errorController.hasSession, isFalse);
      expect(errorController.rows, isEmpty);

      errorController.dispose();
    });

    test('handles editRow before load completes', () async {
      // Controller starts loading immediately in fromPath constructor
      // Try to edit before load() is called
      final CsvReviewRow dummyRow = CsvReviewRowBuilder.build(
        index: 999,
        firstName: 'Test',
        lastName: 'User',
        status: CsvRowReviewStatus.ok,
      );

      // EditRow should handle missing row gracefully (row not in _rows yet)
      final CsvReviewRow? updated = await controller.editRow(
        dummyRow,
        {'jmeno': 'Changed', 'prijmeni': 'Name'},
      );

      // The row won't be found in _rows, so _replaceRow returns early
      // Service still reparsed, but row isn't in controller's list
      expect(updated, isNotNull);
      expect(controller.rows, isEmpty); // Not yet loaded
    });

    test('handles reparse failure during edit', () async {
      AppLogger.configureForTests(level: Level.off);
      addTearDown(() => AppLogger.configureForTests(level: Level.error));

      final _ReparseErrorService reparseErrorService = _ReparseErrorService();
      final CsvReviewPrototypeController reparseController =
          CsvReviewPrototypeController.fromPath(
        path: 'test.csv',
        service: reparseErrorService,
      );

      // Load with successful service first
      await reparseController.load();

      expect(reparseController.hasSession, isTrue);
      expect(reparseController.rows, hasLength(2));

      final CsvReviewRow row = reparseController.rows.first;
      final Map<String, String?> payload = reparseController.buildPayload(row);
      payload['jmeno'] = 'WillFail';

      // Now make reparse throw
      reparseErrorService.shouldThrowOnReparse = true;

      try {
        await reparseController.editRow(row, payload);
        fail('Expected editRow to rethrow error');
      } catch (e) {
        // Expected - error should be rethrown
        expect(e, isA<StateError>());
      }

      // Loading state should be cleared even after error
      expect(reparseController.isRowLoading(row.originalIndex), isFalse);

      reparseController.dispose();
    });

    test('validates session exists before finalize', () async {
      // Controller hasn't loaded yet
      final CsvFinalizeResult? result = await controller.finalizeImport();

      // Should return null when no session loaded
      expect(result, isNull);
    });

    test('cleans up resources on dispose', () async {
      AppLogger.configureForTests(level: Level.off);
      addTearDown(() => AppLogger.configureForTests(level: Level.error));

      await controller.load();
      expect(controller.hasSession, isTrue);

      // Dispose should not throw and should clean up ChangeNotifier
      expect(() => controller.dispose(), returnsNormally);

      // After dispose, listeners should not be notified
      // (ChangeNotifier throws if you try to add listeners after dispose)
      expect(
        () => controller.addListener(() {}),
        throwsA(isA<AssertionError>()),
      );
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
    throw UnsupportedError(
        'In-memory payloads are not supported in this test.');
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

/// Service that can successfully load but throws on reparse when flag is set.
class _ReparseErrorService implements CsvImportService {
  _ReparseErrorService()
      : _rows = <CsvReviewRow>[
          CsvReviewRowBuilder.build(
            index: 1,
            firstName: 'Test',
            lastName: 'User',
            status: CsvRowReviewStatus.ok,
          ),
          CsvReviewRowBuilder.buildWithWarning(
            index: 2,
            firstName: 'Another',
            lastName: 'Person',
            warningMessage: 'Test warning',
          ),
        ];

  final List<CsvReviewRow> _rows;
  bool shouldThrowOnReparse = false;

  @override
  Future<CsvImportSession> loadCsv(String path) async {
    // Successful load
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
    throw UnsupportedError(
        'In-memory payloads are not supported in this test.');
  }

  @override
  Future<CsvReviewRow> reparseRow(Map<String, String?> updatedFields) async {
    if (shouldThrowOnReparse) {
      throw StateError('Simulated reparse error for testing');
    }

    // Normal reparse logic (same as _FakeCsvReviewService)
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
    return CsvReviewRow(
      originalIndex: existing.originalIndex,
      status: existing.status,
      messages: existing.messages,
      fields: newFields,
      derived: existing.derived,
    );
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
    return <int, List<CsvDuplicateCandidate>>{};
  }
}

/// Service that throws errors on load for testing error handling paths.
class _ErrorThrowingService implements CsvImportService {
  _ErrorThrowingService()
      : _rows = <CsvReviewRow>[
          CsvReviewRowBuilder.build(
            index: 1,
            firstName: 'Test',
            lastName: 'User',
            status: CsvRowReviewStatus.ok,
          ),
          CsvReviewRowBuilder.buildWithWarning(
            index: 2,
            firstName: 'Another',
            lastName: 'Person',
            warningMessage: 'Test warning',
          ),
        ];

  final List<CsvReviewRow> _rows;
  bool shouldThrowOnReparse = false;

  @override
  Future<CsvImportSession> loadCsv(String path) async {
    throw StateError('Simulated load error for testing');
  }

  @override
  Future<CsvImportSession> loadCsvFromPayload(CsvImportPayload payload) {
    if (payload.hasPath) {
      return loadCsv(payload.path!);
    }
    throw UnsupportedError(
        'In-memory payloads are not supported in this test.');
  }

  @override
  Future<CsvReviewRow> reparseRow(Map<String, String?> updatedFields) async {
    if (shouldThrowOnReparse) {
      throw StateError('Simulated reparse error for testing');
    }

    // Normal reparse logic (same as _FakeCsvReviewService)
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
    return CsvReviewRow(
      originalIndex: existing.originalIndex,
      status: existing.status,
      messages: existing.messages,
      fields: newFields,
      derived: existing.derived,
    );
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
    return <int, List<CsvDuplicateCandidate>>{};
  }
}
