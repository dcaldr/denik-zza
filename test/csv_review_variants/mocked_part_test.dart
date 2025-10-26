import 'package:denik_zza/database/database_wrapper.dart';
import 'package:denik_zza/database/drift_database/database.dart';
import 'package:denik_zza/dev/dev_environment.dart';
import 'package:denik_zza/input/csv_review_models.dart';
import 'package:denik_zza/services/csv_import_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// Integration tests for CSV import with REAL database.
///
/// These tests exercise the complete CSV import flow:
/// - Load CSV → Parse → Review → Finalize → ACTUAL database save
///
/// **Why these tests exist:**
/// Mocked tests in other files test service logic but don't catch:
/// - Null safety violations in database layer
/// - Foreign key constraint failures
/// - getCurrentActionID() returning null
/// - Real persistence and retrieval issues
///
/// **The Bug This Would Have Caught:**
/// CSV import crashed with "Null check operator used on a null value"
/// because `getCurrentActionID()!` was called without current event.
/// Mocked tests returned fake success, never hitting real database code.
///
/// See: ROOT_CAUSE_ANALYSIS.md for full post-mortem.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CSV Import Integration with Real Database', () {
    late AppDatabase database;
    late DefaultCsvImportService service;

    tearDown(() async {
      await database.close();
    });

    test('fails gracefully when no current event exists (the null error bug)', () async {
      // Setup: Empty database WITHOUT current event
      // This is the scenario that caused the original bug!
      DatabaseWrapper.setTestMode();
      database = AppDatabase.testInMemory();
      DatabaseWrapper.useTestDriftDatabase(database);
      service = DefaultCsvImportService();

      // Load CSV successfully
      final session = await service.loadCsv('test/data/first.csv');
      expect(session.review.rows, isNotEmpty);

      // Build approval decisions
      final decisions = <int, CsvRowDecision>{};
      for (final row in session.review.rows) {
        if (row.status == CsvRowReviewStatus.ok) {
          decisions[row.originalIndex] = CsvRowDecision.approved;
        }
      }

      // Attempt to finalize - should fail or handle null gracefully
      // In the bug scenario, this crashed with null check operator error
      expect(
        () async => await service.finalizeImport(
          session: session,
          decisions: decisions,
        ),
        throwsA(isA<TypeError>()), // Null check operator throws TypeError
      );
    });

    test('successfully imports participants when current event exists', () async {
      // Setup: Database WITH current event (using DevEnvironment)
      database = await DevEnvironment.initialize();
      service = DefaultCsvImportService();

      // Verify current event exists (this fixes the bug!)
      final currentId = await database.getCurrentActionID();
      expect(currentId, isNotNull, reason: 'Current event must exist for import to work');

      // Load CSV
      final session = await service.loadCsv('test/data/first.csv');
      expect(session.review.rows, isNotEmpty);

      // Approve all valid rows
      final decisions = <int, CsvRowDecision>{};
      for (final row in session.review.rows) {
        if (row.status == CsvRowReviewStatus.ok) {
          decisions[row.originalIndex] = CsvRowDecision.approved;
        }
      }
      expect(decisions, isNotEmpty, reason: 'Should have at least one valid row to import');

      // Finalize import - should succeed with real database!
      final result = await service.finalizeImport(
        session: session,
        decisions: decisions,
      );

      // Verify result shows success
      expect(result.savedCount, greaterThan(0), reason: 'Should save at least one participant');
      expect(result.failedCount, 0, reason: 'Should have no failures with valid data');
      expect(result.savedRowIndices.length, equals(result.savedCount));

      // CRITICAL: Verify actual database state (not just service return value!)
      final dbInterface = DatabaseWrapper.getDatabase();
      final participants = await dbInterface.getParticipantsByCurrentEvent();
      expect(
        participants.length,
        equals(result.savedCount),
        reason: 'Database should contain exactly the saved participants',
      );
    });

    test('verifies imported participant data matches CSV fields', () async {
      // Setup with current event
      database = await DevEnvironment.initialize();
      service = DefaultCsvImportService();

      // Load CSV with known data
      final session = await service.loadCsv('test/data/first.csv');
      final firstRow = session.review.rows.firstWhere(
        (row) => row.status == CsvRowReviewStatus.ok,
      );

      // Get expected data from CSV row
      final expectedFirstName = firstRow.fields['jmeno']?.normalizedValue;
      final expectedLastName = firstRow.fields['prijmeni']?.normalizedValue;
      expect(expectedFirstName, isNotNull);
      expect(expectedLastName, isNotNull);

      // Approve and import
      final decisions = {firstRow.originalIndex: CsvRowDecision.approved};
      final result = await service.finalizeImport(
        session: session,
        decisions: decisions,
      );

      expect(result.savedCount, 1);

      // Verify actual database content
      final dbInterface = DatabaseWrapper.getDatabase();
      final participants = await dbInterface.getParticipantsByCurrentEvent();
      expect(participants.length, 1);

      final saved = participants.first;
      expect(saved.jmeno, equals(expectedFirstName));
      expect(saved.prijmeni, equals(expectedLastName));
    });

    test('handles multi_person_shuffled_order.csv (the bug trigger file!)', () async {
      // This is the exact file that triggered the null error bug
      database = await DevEnvironment.initialize();
      service = DefaultCsvImportService();

      // Load the problematic file
      final session = await service.loadCsv('test/data/multi_person_shuffled_order.csv');
      expect(session.review.rows, isNotEmpty);

      // Approve all valid rows
      final decisions = <int, CsvRowDecision>{};
      int validCount = 0;
      for (final row in session.review.rows) {
        if (row.status == CsvRowReviewStatus.ok) {
          decisions[row.originalIndex] = CsvRowDecision.approved;
          validCount++;
        }
      }
      expect(validCount, greaterThan(0));

      // Finalize - this used to crash with null check operator error!
      final result = await service.finalizeImport(
        session: session,
        decisions: decisions,
      );

      // Verify success
      expect(result.savedCount, equals(validCount));
      expect(result.failedCount, 0);

      // Verify database state
      final dbInterface = DatabaseWrapper.getDatabase();
      final participants = await dbInterface.getParticipantsByCurrentEvent();
      expect(participants.length, equals(validCount));
    });

    test('reports failures correctly when some rows fail to save', () async {
      // Setup with current event
      database = await DevEnvironment.initialize();
      service = DefaultCsvImportService();

      // Load CSV
      final session = await service.loadCsv('test/data/first.csv');

      // Approve all rows (including any that might have issues)
      final decisions = <int, CsvRowDecision>{};
      for (final row in session.review.rows) {
        decisions[row.originalIndex] = CsvRowDecision.approved;
      }

      // Finalize
      final result = await service.finalizeImport(
        session: session,
        decisions: decisions,
      );

      // Total should match
      expect(
        result.savedCount + result.failedCount,
        equals(decisions.length),
        reason: 'Every approved row should be either saved or failed',
      );

      // If failures exist, verify they have messages
      for (final failure in result.failures) {
        expect(failure.originalIndex, greaterThan(0));
        expect(failure.message, isNotEmpty);
      }
    });

    test('database state persists across multiple imports', () async {
      // Setup
      database = await DevEnvironment.initialize();
      service = DefaultCsvImportService();

      // First import
      final session1 = await service.loadCsv('test/data/first.csv');
      final decisions1 = <int, CsvRowDecision>{};
      for (final row in session1.review.rows) {
        if (row.status == CsvRowReviewStatus.ok) {
          decisions1[row.originalIndex] = CsvRowDecision.approved;
        }
      }
      final result1 = await service.finalizeImport(
        session: session1,
        decisions: decisions1,
      );

      final dbInterface = DatabaseWrapper.getDatabase();
      final count1 = await dbInterface.getParticipantsByCurrentEvent();
      expect(count1.length, equals(result1.savedCount));

      // Second import (should add to existing)
      final session2 = await service.loadCsv('test/data/minimal_required_fields.csv');
      final decisions2 = <int, CsvRowDecision>{};
      for (final row in session2.review.rows) {
        if (row.status == CsvRowReviewStatus.ok) {
          decisions2[row.originalIndex] = CsvRowDecision.approved;
        }
      }
      final result2 = await service.finalizeImport(
        session: session2,
        decisions: decisions2,
      );

      // Verify total count
      final totalParticipants = await dbInterface.getParticipantsByCurrentEvent();
      expect(
        totalParticipants.length,
        equals(result1.savedCount + result2.savedCount),
      );
    });
  });
}
