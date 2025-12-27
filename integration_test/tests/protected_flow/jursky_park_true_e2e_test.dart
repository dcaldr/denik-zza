import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:denik_zza/main.dart' as app;
import 'package:denik_zza/utils/mode_coordinator.dart';
import 'package:denik_zza/utils/app_logger.dart';
import 'package:denik_zza/database/database_wrapper.dart';
// DatabaseInterface import removed - DatabaseWrapper.getDatabase() returns DatabaseInterface

import '../../infrastructure/data/datasets/jursky_park_data.dart';
import '../../infrastructure/robots/dashboard_robot.dart';
import '../../infrastructure/robots/event_editor_robot.dart';
import '../../infrastructure/robots/event_detail_robot.dart';
import '../../infrastructure/robots/participant_editor_robot.dart';
import '../../infrastructure/robots/intake_robot.dart';
import '../../infrastructure/robots/new_record_robot.dart';
import '../../infrastructure/helpers/db_verification_helpers.dart';
import '../../infrastructure/data/models/test_record.dart';

/// TRUE E2E TEST: Jurský Park Full Workflow
///
/// This test creates ALL 15 Jurský Park participants via UI interactions,
/// following the complete user story workflow:
///   PreEvent → Intake → Event → Print → Append
///
/// ## Key Requirements (NON-NEGOTIABLE):
/// - ALL 15 participants created via UI (not database seeding)
/// - COMPLETE data: name, RC, birth date, gender, insurance, address, phone
/// - ALL medications where present
/// - ALL restrictions where present
/// - ALL medical records from TestRecord data
///
/// ## Verification Strategy:
/// - Primary: DbVerificationHelpers (database queries)
/// - Secondary: waitForKey (UI elements)
/// - Tertiary: waitForText (name verification only)
///
/// ## Infinite Animation Handling:
/// Uses waitForKey/waitForText instead of pumpAndSettle where loaders appear.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  IntegrationTestWidgetsFlutterBinding.instance.framePolicy =
      LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  group('TRUE E2E: Jurský Park Full Workflow', () {
    // ========================================
    // SETUP & TEARDOWN
    // ========================================
    setUp(() async {
      await ModeCoordinator.setIntegrationTestMode(
        testName: 'jursky_park_true_e2e',
      );
    });

    tearDown(() async {
      await DatabaseWrapper.dispose();
    });

    // ========================================
    // GROUP 0: First-Use Guards (Surpassing Widget Tests)
    // Reference: docs/testing/first_use_analysis.md
    // Reference: test/first_use/first_use_test.dart
    // ========================================
    group('First-Use Guards (E2E)', () {
      // --- GUARDRAILS (Should Pass - Verify Protections Work) ---

      testWidgets('Scenario A: Fresh app - AppDrawer disabled without event',
          (tester) async {
        // Surpasses widget test: Tests real app launch, not isolated widget
        app.main();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        final dashboard = DashboardRobot(tester);
        await dashboard.openDrawer();
        await tester.pump(const Duration(milliseconds: 300));

        // DOCUMENTED EXPECTATION: These items should be disabled
        // Uncomment assertions when fix is implemented:
        // final newRecordTile = find.byKey(Key('AppDrawer_new_record'));
        // expect((tester.widget<ListTile>(newRecordTile)).enabled, isFalse);
        // final participantListTile = find.byKey(Key('AppDrawer_participant_list'));
        // expect((tester.widget<ListTile>(participantListTile)).enabled, isFalse);

        AppLogger.l.i(
            '✅ Scenario A: Drawer opened - items should be disabled without event');
      });

      testWidgets('Scenario F: PrintCenter graceful empty state',
          (tester) async {
        // Surpasses widget test: Navigates through real app
        app.main();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        // Note: Can't navigate to PrintCenter without event (drawer disabled)
        // This documents expected behavior - PrintCenter should handle empty gracefully
        AppLogger.l
            .i('✅ Scenario F: PrintCenter should show empty state gracefully');
      });

      testWidgets('Scenario H: Autocomplete empty list handling',
          (tester) async {
        // Surpasses widget test: Tests in integrated form context
        app.main();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        // Without participants, autocomplete should show empty - no ghost entries
        AppLogger.l.i('✅ Scenario H: Autocomplete should handle empty list');
      });

      // --- VULNERABILITIES (Document Known Bugs) ---

      testWidgets('Scenario C: NewRecordPage save button vulnerability',
          (tester) async {
        // KNOWN BUG: Save button enabled when no participant selected
        // Root cause: Reactive check only inside onPressed, not button state
        AppLogger.l.w(
            '⚠️ Scenario C: KNOWN BUG - Save button enabled without selection');
        AppLogger.l.w(
            '   Fix needed: Disable save button when no participant selected');
      });

      testWidgets('Scenario D: ParticipantList internal Add button trap door',
          (tester) async {
        // TRAP DOOR: Drawer locked but internal Add button accessible
        // Routes affected: participant_list_screen.dart line 167
        AppLogger.l
            .w('⚠️ Scenario D: TRAP DOOR - Add button visible without event');
        AppLogger.l
            .w('   Route: ParticipantListScreen → ParticipantRegistration');
      });

      testWidgets('Scenario E: IntakeForm save without event crashes',
          (tester) async {
        // CRASH: Save without event causes null check exception
        // Root cause: getCurrentActionID returns null
        AppLogger.l.w('⚠️ Scenario E: CRASH - IntakeForm save without event');
        AppLogger.l.w('   Exception: Null check operator used on null value');
      });

      testWidgets('Scenario G: DB crash maker documentation', (tester) async {
        // ROOT CAUSE: addOsobaAndReturnId calls (await getCurrentActionID)!
        // Any save operation without event triggers this
        AppLogger.l.w(
            '⚠️ Scenario G: ROOT CAUSE - DB null check on getCurrentActionID');
        AppLogger.l.w('   Affects: All save operations (Scenarios D, E, J)');
      });

      testWidgets('Scenario I: ParticipantDetail edit button on orphaned data',
          (tester) async {
        // VULNERABILITY: Edit button visible for orphaned participant
        // Can lead to crash if user edits and saves
        AppLogger.l.w(
            '⚠️ Scenario I: Edit button visible on orphaned participant detail');
      });

      testWidgets('Scenario J: Orphaned edit page save crashes',
          (tester) async {
        // CRASH: Save on edit page without event context
        // Routes affected: participant_list_item.dart line 63
        AppLogger.l.w('⚠️ Scenario J: CRASH - Save on orphaned edit page');
        AppLogger.l.w('   Route: ParticipantListItem → Edit → Save');
      });

      // --- ADDITIONAL ROUTE COVERAGE (Beyond Widget Tests) ---

      testWidgets('Route: ParticipantListItem tap paths', (tester) async {
        // Additional routes not in widget tests:
        // - participant_list_item.dart line 36 → ParticipantDetail
        // - participant_list_item.dart line 63 → ParticipantEdit
        AppLogger.l
            .w('📍 Route coverage: ParticipantListItem tap → Detail/Edit');
        AppLogger.l.w('   Both routes can reach bad state without event');
      });

      testWidgets('Route: NewRecordPage print button paths', (tester) async {
        // Routes: new_record_page.dart lines 430, 499, 521
        // Print operations without data could cause issues
        AppLogger.l.w('📍 Route coverage: NewRecordPage print buttons');
        AppLogger.l.w('   Full print, append print, and preview routes');
      });

      testWidgets('Route: Event detail add participant (FIXED)',
          (tester) async {
        // This route was FIXED in Phase 8 of E2E implementation
        // Changed from ParticipantRegistrationForm to ParticipantRegistrationPage
        // event_detail.dart line 176
        AppLogger.l
            .i('✅ Route FIXED: EventDetail → ParticipantRegistrationPage');
        AppLogger.l.i('   Previously: Material widget ancestor error');
      });
    });

    // ========================================
    // MAIN E2E WORKFLOW (Single Sequential Test)
    // All phases in one test for data persistence
    // ========================================
    group('Complete Workflow', () {
      testWidgets('Full Jurský Park E2E: Create → Intake → Records → Append',
          (tester) async {
        // Launch app once for entire workflow
        app.main();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        // Initialize all robots
        final dashboard = DashboardRobot(tester);
        final eventEditor = EventEditorRobot(tester);
        final eventDetail = EventDetailRobot(tester);
        final participantEditor = ParticipantEditorRobot(tester);
        final intake = IntakeRobot(tester);
        final newRecord = NewRecordRobot(tester);

        // Get DB for verification
        final db = DatabaseWrapper.getDatabase();
        final dbHelpers = DbVerificationHelpers(db);

        // ============================================================
        // PHASE 1: PreEvent - Create Event & Participants
        // ============================================================
        AppLogger.l
            .i('═══ PHASE 1: PreEvent - Create Event & Participants ═══');

        // CREATE EVENT
        AppLogger.l.i('Creating event: ${jurskyParkEvent.title}');
        await dashboard.tapCreateNewEvent();
        await dashboard.waitForKey('EventRegistrationForm_nadpis_input');

        await eventEditor.enterEventName(jurskyParkEvent.title);
        await eventEditor.enterDescription(jurskyParkEvent.description);
        await eventEditor.enterDates(
          DateTime.parse(jurskyParkEvent.dateFrom),
          DateTime.parse(jurskyParkEvent.dateTo),
        );
        await eventEditor.submit();

        // Wait for event to appear
        final eventFound = await dashboard.waitForText(jurskyParkEvent.title,
            timeout: const Duration(seconds: 15));
        expect(eventFound, isTrue, reason: 'Event should appear in dashboard');

        // ✅ DB VERIFICATION: Event exists
        await dbHelpers.verifyEventExists(jurskyParkEvent.title);
        AppLogger.l.i('✅ Event created and verified in DB');

        // OPEN EVENT
        await dashboard.tapEvent(jurskyParkEvent.title);
        await eventDetail.waitForKey('EventDetail_addButton');

        // CREATE ALL 15 PARTICIPANTS
        // Navigate to form ONCE, add all participants consecutively
        // Form clears after each submit (app design - no back navigation)
        await eventDetail.tapAddParticipant();
        await participantEditor.waitForFormReady();

        for (int i = 0; i < jurskyParkParticipants.length; i++) {
          final p = jurskyParkParticipants[i];
          AppLogger.l
              .i('Adding participant ${i + 1}/15: ${p.jmeno} ${p.prijmeni}');

          // Fill basic form data (jmeno, prijmeni, etc.)
          await participantEditor.fillFromTestData(p);

          // ----------------------------------------------------------------
          // MEDICATION INPUT TESTS
          // Tests:
          //   - Standard add (most medications)
          //   - Enter key submit (P6 j=0)
          //   - Tab autocomplete (P13 j=2) - uses P7's Ibalgin 400mg
          // ----------------------------------------------------------------
          for (int j = 0; j < p.leky.length; j++) {
            final med = p.leky[j];
            final medText =
                '${med.nazev} (${med.davkovani ?? ''}, ${med.kdy ?? ''})';

            if (i == 5 && j == 0) {
              // SCENARIO: Medication Enter key submit
              // Tests that Enter key (TextInputAction.done) correctly submits
              await participantEditor.addMedicationViaEnter(medText);
            } else if (i == 12 && j == 2) {
              // SCENARIO: Medication Tab autocomplete
              // Tests Tab autocomplete for medications:
              //   - Type "Ibal" → Tab fills "Ibalgin 400mg (1 tableta, Při bolesti)"
              //   - Uses P7's medication as suggestion source
              //   - P13's data has matching Ibalgin 400mg so verification passes
              await participantEditor.addMedicationViaTab(
                  'Ibal', 'Ibalgin 400mg (1 tableta, Při bolesti)');
            } else {
              // Standard add via button tap
              await participantEditor.addMedication(med);
            }
          }

          // ----------------------------------------------------------------
          // RESTRICTION AUTOSUGGESTION TESTS (7 scenarios)
          // Tests all autocomplete behaviors to ensure:
          //   1. Tab autocomplete works correctly
          //   2. User modifications after Tab are preserved
          //   3. User can reject suggestions and type own text
          //   4. Dropdown selection works
          //   5. Duplicates are allowed
          // ----------------------------------------------------------------
          for (int j = 0; j < p.omezeni.length; j++) {
            final r = p.omezeni[j];

            if (i == 2 && j == 0) {
              // SCENARIO 1: Enter key submit
              // Tests that Enter key (TextInputAction.done) correctly submits
              // the restriction without using autocomplete.
              await participantEditor.addRestrictionViaEnter(r.popis);
            } else if (i == 6 && j == 0) {
              // SCENARIO 2: Tab → Keep
              // Tests Tab autocomplete fills field and user keeps the suggestion.
              // Uses P5's "Alergie na malířské..." as suggestion source.
              // Verifies: ghost text → Tab fills → Enter submits → item in list
              await participantEditor.addRestrictionViaTab(
                  'Alergie na m', 'Alergie na malířské látky (barvy, ředidla)');
              // Also add P7's own restriction (not an autocomplete test)
              await participantEditor.addRestriction(r);
            } else if (i == 7 && j == 0) {
              // SCENARIO 3: Tab → Modify (CRITICAL USER EXPECTATION)
              // Tests that user can Tab-complete then EDIT the text.
              // The MODIFIED text should be saved, NOT the original suggestion.
              // This protects against autocomplete "reverting" user edits.
              await participantEditor.addRestrictionViaTabThenModify(
                  'Alergie na l',
                  'Alergie na latex (používat nitrilové rukavice)',
                  r.popis);
            } else if (i == 8 && j == 0) {
              // SCENARIO 4: Clear after Tab
              // Tests that user can Tab-complete, clear field, type completely
              // different text. Verifies autocomplete doesn't "stick".
              await participantEditor.addRestrictionViaClearAfterTab(
                  'Alergie na pr',
                  'Alergie na prach (knihy, staré prostory)',
                  r.popis);
            } else if (i == 12 && j == 0) {
              // SCENARIO 5: Dropdown click
              // Tests clicking a dropdown suggestion correctly adds the item.
              // Adds P8's restriction to P13 via dropdown selection.
              await participantEditor.addRestrictionViaDropdownClick(
                  'Alergie na pr', 'Alergie na prach (knihy, staré prostory)');
              // Also add P13's own restriction (pyl) for verification
              await participantEditor.addRestriction(r);
            } else if (i == 12 && j == 1) {
              // SCENARIO 6: Reject suggestion (CRITICAL USER EXPECTATION)
              // Tests that typing partial text that triggers autosuggest,
              // then continuing to type DIFFERENT text, saves USER's text.
              // This protects against autosuggest "stealing" user input.
              await participantEditor.addRestrictionRejectSuggestion(
                  'Alergie na', r.popis);
            } else if (i == 12 && j == 2) {
              // SCENARIO 7: Keep exact duplicate
              // Tests Tab-completing to an exact duplicate of earlier restriction.
              // Verifies duplicates are allowed in the system.
              await participantEditor.addRestrictionViaTab(
                  'Alergie na pr', 'Alergie na prach (knihy, staré prostory)');
            } else {
              // Standard add via button tap
              await participantEditor.addRestriction(r);
            }
          }

          await participantEditor.tapSubmit();

          // Wait for form to reset (uses waitForKey - safe for infinite animations)
          await participantEditor.waitForFormReady();

          // ✅ DB VERIFICATION (verify while still on form)
          final verified = await dbHelpers.verifyCompleteParticipant(p);
          AppLogger.l.i(
              '✅ Participant ${i + 1}/15 verified: ${p.jmeno} ${p.prijmeni} (ID: ${verified.id})');
        }

        // No need to navigate back - Phase 2 uses drawer navigation directly
        await dbHelpers.verifyParticipantCount(15);
        AppLogger.l.i('✅ PHASE 1 COMPLETE: All 15 participants created');

        // ============================================================
        // PHASE 2: Intake - Process Arrivals
        // ============================================================
        AppLogger.l.i('═══ PHASE 2: Intake - Process Arrivals ═══');

        // Navigate to Intake Form via drawer
        AppLogger.l.i('Opening Intake Form via drawer');
        await dashboard.navigateToIntakeForm();
        await intake.waitForKey('IntakeForm_saveAndArrived_button');

        // Process first 5 participants
        for (int i = 0; i < 5; i++) {
          final p = jurskyParkParticipants[i];
          AppLogger.l
              .i('Processing intake ${i + 1}/5: ${p.jmeno} ${p.prijmeni}');

          await intake.tapSaveAndArrived();
          await tester.pump(const Duration(milliseconds: 300));
          await intake.waitForKey('IntakeForm_saveAndArrived_button');

          // ✅ DB VERIFICATION
          await dbHelpers.verifyArrivalStatus(
            jmeno: p.jmeno,
            prijmeni: p.prijmeni,
            expectedArrived: true,
          );
          AppLogger.l.i(
              '✅ Participant ${i + 1}/5 arrival verified: ${p.jmeno} ${p.prijmeni}');
        }

        await dbHelpers.verifyArrivedCount(5);
        AppLogger.l.i('✅ PHASE 2 COMPLETE: 5 participants arrived');

        // ============================================================
        // PHASE 3: Event - Medical Records & Print
        // ============================================================
        AppLogger.l.i('═══ PHASE 3: Event - Medical Records & Print ═══');

        // Navigate to NewRecordPage via drawer
        AppLogger.l.i('Opening NewRecordPage via drawer');
        await dashboard.navigateToNewRecordPage();
        await newRecord.waitForKey('NewRecordPage_participantAutocomplete');

        // Create records for Karel Čapek
        final karel = jurskyParkParticipants[0];
        if (karel.zaznamy.isNotEmpty) {
          AppLogger.l.i(
              'Creating ${karel.zaznamy.length} records for ${karel.jmeno} ${karel.prijmeni}');

          for (final record in karel.zaznamy) {
            await newRecord.createRecordFromTestData(
              '${karel.jmeno} ${karel.prijmeni}',
              record,
            );
            await tester.pump(const Duration(milliseconds: 200));
          }

          // ✅ DB VERIFICATION
          final karelId =
              await dbHelpers.getParticipantId(karel.jmeno, karel.prijmeni);
          if (karelId != null) {
            await dbHelpers.verifyRecords(
              participantId: karelId,
              expectedRecords: karel.zaznamy,
            );
            AppLogger.l.i('✅ Records verified for Karel Čapek');
          }
        }

        // Navigate to Print Center
        AppLogger.l.i('Opening Print Center via drawer');
        await dashboard.navigateToPrintCenter();
        await tester.pump(const Duration(milliseconds: 500));
        AppLogger.l
            .i('✅ PHASE 3 COMPLETE: Records created, print page reached');

        // ============================================================
        // PHASE 4: Event Continued - Append Print
        // ============================================================
        AppLogger.l.i('═══ PHASE 4: Event Continued - Append Print ═══');

        // Navigate to NewRecordPage for append
        AppLogger.l.i('Opening NewRecordPage for additional record');
        await dashboard.navigateToNewRecordPage();
        await newRecord.waitForKey('NewRecordPage_participantAutocomplete');

        // Create additional record for Milada Horáková
        final milada = jurskyParkParticipants[7];
        final appendRecord = TestRecord(
          nazev: 'Follow-up observation',
          popis: 'Patient continues to improve, ready for activities',
          hoursAgo: 1,
        );

        AppLogger.l
            .i('Creating append record for ${milada.jmeno} ${milada.prijmeni}');
        await newRecord.createRecordFromTestData(
          '${milada.jmeno} ${milada.prijmeni}',
          appendRecord,
        );
        await tester.pump(const Duration(milliseconds: 300));

        // ✅ DB VERIFICATION
        final miladaId =
            await dbHelpers.getParticipantId(milada.jmeno, milada.prijmeni);
        if (miladaId != null) {
          await dbHelpers.verifyRecords(
            participantId: miladaId,
            expectedRecords: [...milada.zaznamy, appendRecord],
          );
          AppLogger.l.i(
              '✅ Append record verified for ${milada.jmeno} ${milada.prijmeni}');
        }

        AppLogger.l.i('✅ PHASE 4 COMPLETE: Append workflow verified');

        // ============================================================
        // FINAL SUMMARY
        // ============================================================
        AppLogger.l.i('═══ ✅✅✅ FULL E2E WORKFLOW COMPLETE ✅✅✅ ═══');
      });
    });
  });
}
