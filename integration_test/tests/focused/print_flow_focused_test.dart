import 'dart:io';
import 'package:path/path.dart' as path;

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:drift/drift.dart';

import 'package:denik_zza/main.dart' as app;
import 'package:denik_zza/utils/mode_coordinator.dart';
import 'package:denik_zza/database/database_wrapper.dart';
import 'package:denik_zza/database/drift_database_connector.dart';
import 'package:denik_zza/database/drift_database/database.dart';
import 'package:denik_zza/input/file_manager.dart';
import 'package:denik_zza/utils/app_logger.dart';
import 'package:denik_zza/services/system/system_interface.dart';

import '../../infrastructure/data/datasets/jursky_park_data.dart';
import '../../infrastructure/data/shared_infrastructure.dart';
import '../../infrastructure/robots/event_list_robot.dart';
import '../../infrastructure/robots/print_center_robot.dart';
import '../../infrastructure/robots/person_mode_flow_robot.dart';
import '../../infrastructure/helpers/db_verification_helpers.dart';
import '../../../test/utils/capturing_system_interface.dart';

/// Seeds event + 2 participants with records directly into DB.
///
/// Karel Čapek (2 records) — simple full-print case.
/// Milada Horáková (9 records) — complex case for full + append.
Future<void> _seedPrintTestData(AppDatabase database) async {
  final insuranceMap = await createTestInsuranceCompanies(database);
  final paramedicIds = await createTestParamedics(database);
  final paramedicId = paramedicIds.first;

  final fmConfig = FileManager().getConfigSummary();
  final testOutputPath = fmConfig['testOutputPath'] as String?;
  final basePath = testOutputPath ?? '';
  final eventPath = basePath.isNotEmpty
      ? path.join(basePath, jurskyParkEvent.homeDirectory)
      : jurskyParkEvent.homeDirectory;

  if (basePath.isNotEmpty) {
    final eventDir = Directory(eventPath);
    await eventDir.create(recursive: true);
    for (final sub in const ['backup', 'zpusobilosti', 'vysetreni']) {
      await Directory(path.join(eventDir.path, sub)).create(recursive: true);
    }
  }

  final eventId = await createTestEvent(
    database,
    title: jurskyParkEvent.title,
    description: jurskyParkEvent.description,
    dateFrom: DateTime.parse(jurskyParkEvent.dateFrom),
    dateTo: DateTime.parse(jurskyParkEvent.dateTo),
    homeDirectory: eventPath,
  );

  await database.updateCache(CacheCompanion(
    id: const Value(1),
    currentActionID: Value(eventId),
  ));

  // Seed Karel Čapek (index 0) and Milada Horáková (index 6, which is #7)
  final baseTime = DateTime.now();
  for (final index in [0, 6]) {
    final p = jurskyParkParticipants[index];
    final insuranceId = insuranceMap[p.pojistovna];
    final pid = await database.addParticipant(
      p.toCompanion(eventId, insuranceId),
    );

    for (final med in p.leky) {
      await database.addMedication(med.toCompanion(pid));
    }

    for (final r in p.omezeni) {
      await database.addAllergiesLimitations(r.toCompanion(pid));
    }

    for (final rec in p.zaznamy) {
      await database.addRecord(rec.toCompanion(pid, paramedicId, baseTime));
    }
  }
}

/// Focused Print Flow Test
///
/// Exercises the PrintCenter → PersonModeFlowPage path with DB-seeded data,
/// skipping the expensive UI-based participant creation and intake phases.
///
/// This test isolates the print functionality that failed in the main E2E test
/// at `personMode.tapPrintButton()` — "Could not find any matching widgets"
/// for Key('PersonMode_printButton').
///
/// Purpose:
/// - Fast iteration on print flow bugs (~30s vs ~6min full E2E)
/// - Clear failure messages for debugging
/// - Validates: person selection, mode selection, print action, confirmation
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  IntegrationTestWidgetsFlutterBinding.instance.framePolicy =
      LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  void logStep(String message) {
    AppLogger.l.i('[Focused/PrintFlow] $message');
  }

  group('Focused - Print Flow', () {
    setUp(() async {
      await ModeCoordinator.setIntegrationTestMode(
        testName: 'focused_print_flow',
      );
      logStep('ModeCoordinator integration-test mode ready');

      final fmConfig = FileManager().getConfigSummary();
      logStep('FileManager config: $fmConfig');

      final db = DatabaseWrapper.getDatabase();
      final appDb = (db as DriftDatabaseConnector).appDatabase;
      logStep('Seeding print test data');
      await _seedPrintTestData(appDb);
    });

    tearDown(() async {
      await DatabaseWrapper.dispose();
      // Force all microtasks to clear so we don't hold the test runner hostage
      // We cannot call pump on tester easily without passing it, but `pumpAndSettle` is done
      // manually if needed. At least the DB is disposed.
    });

    testWidgets(
      'Full print (Karel) + Full & Append print (Milada)',
      (tester) async {
        final dashboard = EventListRobot(tester);
        final printCenter = PrintCenterRobot(tester);
        final personMode = PersonModeFlowRobot(tester);
        final dbHelpers =
            DbVerificationHelpers(DatabaseWrapper.getDatabase());
        final capture = CapturingSystemInterface.forCurrentTest();
        SystemInterface.registerWith(capture);

        logStep('Launching app');
        app.main();
        await dashboard.pumpAndSettle();

        logStep('Waiting for event on dashboard');
        final eventFound = await dashboard.waitForText(
          jurskyParkEvent.title,
          timeout: const Duration(seconds: 10),
        );
        expect(eventFound, isTrue, reason: 'Event should appear in dashboard');

        // ============================================================
        // PART 1: Full Print — Karel Čapek
        // ============================================================
        logStep('--- Part 1: Full Print Karel Čapek ---');

        logStep('Navigating to Print Center');
        await dashboard.navigateToPrintCenter();
        await printCenter.verifyPageShown();

        logStep('Tapping Person Mode card');
        await printCenter.tapPersonModeCard();
        await personMode.verifyPageShown();

        logStep('Selecting Karel Čapek');
        await personMode.selectParticipant('Karel Čapek');

        logStep('Selecting full print mode');
        await personMode.selectFullPrintMode();

        logStep('Tapping print button');
        await personMode.tapPrintButton();

        logStep('Confirming print success');
        await personMode.confirmPrintSuccess();
        // Wait for DB writes to complete before verifying
        await personMode.pumpAndSettle();

        logStep('Verifying DB: Karel printed');
        await dbHelpers.verifyParticipantPrinted('Karel', 'Čapek', true);

        logStep('Verifying captured PDF');
        expect(capture.capturedPdfs.length, equals(1),
            reason: 'Expected 1 captured PDF after Karel full print');
        expect(capture.capturedPdfs.last.name, contains('Osoba_'),
            reason: 'PDF name should contain participant ID pattern');

        logStep('✅ Part 1 passed: Karel full print');

        // Stay in PersonModeFlow, reset to person selection
        logStep('Tapping Nový tisk to reset flow');
        await personMode.tapNewPrint();
        await personMode.verifyPageShown();

        // ============================================================
        // PART 2: Full Print — Milada Horáková
        // ============================================================
        logStep('--- Part 2: Full Print Milada Horáková ---');

        logStep('Selecting Milada Horáková');
        await personMode.selectParticipant('Milada Horáková');

        logStep('Selecting full print mode');
        await personMode.selectFullPrintMode();

        logStep('Tapping print button');
        await personMode.tapPrintButton();

        logStep('Confirming print success');
        await personMode.confirmPrintSuccess();
        // Wait for DB writes to complete before verifying
        await personMode.pumpAndSettle();

        await dbHelpers.verifyParticipantPrinted(
            'Milada', 'Horáková', true);
        expect(capture.capturedPdfs.length, equals(2),
            reason: 'Expected 2 PDFs (Karel + Milada full)');

        logStep('✅ Part 2 passed: Milada full print');

        // Stay in PersonModeFlow, reset to person selection
        logStep('Tapping Nový tisk to reset flow');
        await personMode.tapNewPrint();
        await personMode.verifyPageShown();

        // ============================================================
        // PART 3: Append Print — Milada Horáková
        // ============================================================
        logStep('--- Part 3: Append Print Milada Horáková ---');

        // After tapNewPrint() we're still on PersonModeFlowPage at Stage 1
        // (person selection). No need to navigate back to PrintCenter.

        logStep('Selecting Milada Horáková');
        await personMode.selectParticipant('Milada Horáková');

        logStep('Selecting append print mode');
        await personMode.selectAppendPrintMode();

        logStep('Tapping print button');
        await personMode.tapPrintButton();

        logStep('Waiting for AppendInstruction dialog');
        final continueFound = await personMode.waitForKey(
          'AppendInstruction_continue',
        );
        expect(continueFound, isTrue,
            reason: 'Append instruction dialog should appear');
        await personMode
            .tap(personMode.findKey('AppendInstruction_continue'));

        logStep('Confirming print success');
        await personMode.confirmPrintSuccess();
        // Wait for background DB writes and state updates
        await personMode.pumpAndSettle();

        logStep('Verifying DB: Milada records all printed');
        final miladaId =
            await dbHelpers.getParticipantId('Milada', 'Horáková');
        await dbHelpers.verifyAllRecordsPrinted(miladaId, true);

        expect(capture.capturedPdfs.length, equals(3),
            reason: 'Expected 3 PDFs (Karel + Milada full + Milada append)');

        logStep('✅ Part 3 passed: Milada append print');
        logStep('✅ ALL PRINT FLOW TESTS PASSED');

        // Drain any pending microtasks but don't wait for infinite animations
        logStep('Draining final microtasks before teardown');
        
        // Tap 'Zpět na centrum' to leave the success screen.
        // This stops the infinite checkmark animation so the test framework can shut down cleanly!
        final backToCenterBtn = find.text('Zpět na centrum');
        if (backToCenterBtn.evaluate().isNotEmpty) {
          await tester.tap(backToCenterBtn);
          await personMode.pumpAndSettle();
        }
      },
      // Give enough time for the 3 test portions (approx 20 seconds total execution time on slow devices)
      timeout: const Timeout(Duration(seconds: 40)),
    );
  });
}
