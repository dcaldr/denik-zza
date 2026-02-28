import 'package:denik_zza/database/drift_database/database.dart';
import 'package:denik_zza/dev/dev_environment.dart';
import 'package:denik_zza/input/csv_review_models.dart';
import 'package:denik_zza/services/csv_import_service.dart';
import 'package:denik_zza/database/drift_database_connector.dart';
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
    });

    test('fails gracefully when no current event exists (the null error bug)',
        () async {
      // Setup: Empty database WITHOUT current event
      // This is the scenario that caused the original bug!
      database = AppDatabase.testInMemory();
      // Isolate: Do NOT use DatabaseWrapper
      // DatabaseWrapper.useTestDriftDatabase(database);
      service = DefaultCsvImportService(
          database: DriftDatabaseConnector.withDatabase(database));

      // Load CSV successfully
      final session = await service.loadCsv('test/data/first.csv');
      expect(session.review.rows, isNotEmpty);

      // Build approval decisions
      final decisions = <int, CsvRowDecision>{};
      for (final row in session.review.rows) {
        // Valid = not rejected (includes ok, info, warn)
        if (row.status != CsvRowReviewStatus.rejected) {
          decisions[row.originalIndex] = CsvRowDecision.approved;
        }
      }

      // Attempt to finalize - should now return result with failures instead of throwing
      // The bug fix moved error handling from unhandled exception to graceful failure reporting
      final result = await service.finalizeImport(
        session: session,
        decisions: decisions,
      );

      // Should report failures for all rows (since no current event exists)
      expect(result.savedCount, 0,
          reason: 'Should save no rows when no current event exists');
      expect(result.failedCount, greaterThan(0),
          reason: 'Should report failures for all approved rows');
      expect(result.failures.length, equals(decisions.length),
          reason: 'Every approved row should fail');

      // Verify failures contain error information
      for (final failure in result.failures) {
        expect(failure.originalIndex, greaterThan(0));
        expect(failure.message, isNotEmpty);
      }
    });

    test('successfully imports participants when current event exists',
        () async {
      // Setup: Database WITH current event (using DevEnvironment)
      database = await DevEnvironment.initialize(registerGlobally: false);
      service = DefaultCsvImportService(
          database: DriftDatabaseConnector.withDatabase(database));

      // Verify current event exists (this fixes the bug!)
      final currentId = await database.getCurrentActionID();
      expect(currentId, isNotNull,
          reason: 'Current event must exist for import to work');

      // Load CSV
      final session = await service.loadCsv('test/data/first.csv');
      expect(session.review.rows, isNotEmpty);

      // Approve all VALID rows (all statuses except rejected)
      final decisions = <int, CsvRowDecision>{};
      for (final row in session.review.rows) {
        // Valid = not rejected (includes ok, info, warn)
        if (row.status != CsvRowReviewStatus.rejected) {
          decisions[row.originalIndex] = CsvRowDecision.approved;
        }
      }
      expect(decisions, isNotEmpty,
          reason: 'Should have at least one valid row to import');

      // Count participants BEFORE import
      final dbInterface = DriftDatabaseConnector.withDatabase(database);
      final participantsBefore =
          await dbInterface.getParticipantsByCurrentEvent();
      final countBefore = participantsBefore.length;

      // Finalize import - should succeed with real database!
      final result = await service.finalizeImport(
        session: session,
        decisions: decisions,
      );

      // Verify result shows success
      expect(result.savedCount, greaterThan(0),
          reason: 'Should save at least one participant');
      expect(result.failedCount, 0,
          reason: 'Should have no failures with valid data');
      expect(result.savedRowIndices.length, equals(result.savedCount));

      // CRITICAL: Verify actual database state (not just service return value!)
      // DevEnvironment.initialize() pre-populates DB, so check INCREMENT not absolute count
      final participantsAfter =
          await dbInterface.getParticipantsByCurrentEvent();
      expect(
        participantsAfter.length,
        equals(countBefore + result.savedCount),
        reason:
            'Database should have ${result.savedCount} MORE participants after import',
      );
    });

    test('verifies imported participant data matches CSV fields', () async {
      // Setup with current event
      database = await DevEnvironment.initialize(registerGlobally: false);
      service = DefaultCsvImportService(
          database: DriftDatabaseConnector.withDatabase(database));

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
      final dbInterface = DriftDatabaseConnector.withDatabase(database);
      final participants = await dbInterface.getParticipantsByCurrentEvent();
      // DevEnvironment pre-populates DB with 10 participants, so we have 11 total now
      expect(participants.length, greaterThan(0),
          reason: 'Should have participants in database');

      // Find the newly imported participant by matching name
      final saved = participants.firstWhere(
        (p) => p.jmeno == expectedFirstName && p.prijmeni == expectedLastName,
      );
      expect(saved.jmeno, equals(expectedFirstName));
      expect(saved.prijmeni, equals(expectedLastName));
    });

    test('handles multi_person_shuffled_order.csv (the bug trigger file!)',
        () async {
      // This is the exact file that triggered the null error bug
      database = await DevEnvironment.initialize(registerGlobally: false);
      service = DefaultCsvImportService(
          database: DriftDatabaseConnector.withDatabase(database));

      // Load the problematic file
      final session =
          await service.loadCsv('test/data/multi_person_shuffled_order.csv');
      expect(session.review.rows, isNotEmpty);

      // Approve all VALID rows (all statuses except rejected)
      // According to CsvRowReviewStatus documentation:
      // - ok: No issues
      // - info: Informational messages
      // - warn: Warnings but still processable
      // - rejected: Should NOT be approved (invalid data)
      final decisions = <int, CsvRowDecision>{};
      int validCount = 0;
      for (final row in session.review.rows) {
        // Count all rows that are NOT rejected as valid
        if (row.status != CsvRowReviewStatus.rejected) {
          decisions[row.originalIndex] = CsvRowDecision.approved;
          validCount++;
        }
      }
      expect(validCount, greaterThan(0),
          reason: 'Should have at least one valid (non-rejected) row');

      // Count participants BEFORE import to handle DevEnvironment pre-population
      final dbInterface = DriftDatabaseConnector.withDatabase(database);
      final participantsBefore =
          await dbInterface.getParticipantsByCurrentEvent();
      final countBefore = participantsBefore.length;

      // Finalize - this used to crash with null check operator error!
      final result = await service.finalizeImport(
        session: session,
        decisions: decisions,
      );

      // Verify success
      expect(result.savedCount, equals(validCount));
      expect(result.failedCount, 0);

      // Verify database state - check INCREMENT not absolute count
      final participantsAfter =
          await dbInterface.getParticipantsByCurrentEvent();
      expect(participantsAfter.length, equals(countBefore + validCount),
          reason: 'Should have $validCount MORE participants after import');
    });

    test('reports failures correctly when some rows fail to save', () async {
      // Setup with current event
      database = await DevEnvironment.initialize(registerGlobally: false);
      service = DefaultCsvImportService(
          database: DriftDatabaseConnector.withDatabase(database));

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
      database = await DevEnvironment.initialize(registerGlobally: false);
      service = DefaultCsvImportService(
          database: DriftDatabaseConnector.withDatabase(database));

      final dbInterface = DriftDatabaseConnector.withDatabase(database);
      final countInitial =
          (await dbInterface.getParticipantsByCurrentEvent()).length;

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

      final count1 = (await dbInterface.getParticipantsByCurrentEvent()).length;
      expect(count1, equals(countInitial + result1.savedCount),
          reason: 'First import should add ${result1.savedCount} participants');

      // Second import (should add to existing)
      final session2 =
          await service.loadCsv('test/data/minimal_required_fields.csv');
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

      // Verify total count includes both imports PLUS initial data
      final totalParticipants =
          await dbInterface.getParticipantsByCurrentEvent();
      expect(
        totalParticipants.length,
        equals(countInitial + result1.savedCount + result2.savedCount),
        reason: 'Should have initial + first import + second import',
      );
    });
  });
}
