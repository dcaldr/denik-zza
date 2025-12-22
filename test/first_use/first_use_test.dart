import 'package:denik_zza/database/database_interface.dart';
import 'package:denik_zza/database/database_wrapper.dart';
import 'package:denik_zza/database/drift_database/database.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_akce.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import 'package:denik_zza/print_ops2/print_center.dart';
import 'package:denik_zza/screens2/intake_form_improved.dart';
import 'package:denik_zza/screens2/new_record_page.dart';
import 'package:denik_zza/screens2/participant_detail.dart';
import 'package:denik_zza/screens2/participant_list_screen.dart';
import 'package:denik_zza/screens2/participant_registration_form.dart';
import 'package:denik_zza/screens2/widgets/app_drawer.dart';
import 'package:denik_zza/screens2/widgets/person_autocomplete.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils/base_test_widget.dart';

void main() {
  group('First Use & Empty States', () {
    late DatabaseInterface db;

    setUp(() async {
      // 1. Initialize Concrete Test DB for Setup
      final concreteDb = AppDatabase.testInMemory();

      // 2. Add Paramedic (Medic Login Sim) - Required for record creation logic
      await concreteDb.addParamedic(ParamedicsCompanion(
        firstName: Value('Test'),
        lastName: Value('Medic'),
        address: Value('Test Address'),
        birthDate: Value(DateTime(1980)),
        phoneNumber: Value('123456789'),
        username: Value('tester1'),
      ));

      // 3. Inject into Wrapper
      DatabaseWrapper.useTestDriftDatabase(concreteDb);
      DatabaseWrapper.setTestMode();

      // 4. Get Interface for Test Usage
      db = DatabaseWrapper.getDatabase();
    });

    tearDown(() async {
      await DatabaseWrapper.dispose();
    });

    // =========================================================================
    // GUARDRAILS (Should PASS if working correctly)
    // =========================================================================

    testWidgets('Scenario A: AppDrawer - No Event State', (tester) async {
      // Pump AppDrawer without any event in DB
      await tester.pumpWidget(const BaseTestWidget(
        isDrawer: true,
        child: AppDrawer(),
      ));
      await tester.pumpAndSettle();

      // "New Record" should be DISABLED
      final newRecordTile = find.byKey(const Key('AppDrawer_new_record'));
      expect((tester.widget(newRecordTile) as ListTile).enabled, isFalse);

      // "Participant List" should be DISABLED
      final participantListTile =
          find.byKey(const Key('AppDrawer_participant_list'));
      expect((tester.widget(participantListTile) as ListTile).enabled, isFalse);
    });

    testWidgets('Scenario B: AppDrawer - Partial State (Event Exists)',
        (tester) async {
      // Setup: Add one event AND set it as current (Correct Usage)
      final event = MemoryAction(
          idAkce: null,
          nadpis: 'Test Event',
          popis: 'Desc',
          odkdy: DateTime.now(),
          dokdy: DateTime.now());
      await db.addEvent(event);

      final events = await db.getAllZzaActions();

      if (events.isNotEmpty) {
        db.updateCurrentEvent(events.first.idAkce);
      }

      await tester.pumpWidget(const BaseTestWidget(
        isDrawer: true,
        child: AppDrawer(),
      ));
      await tester.pumpAndSettle();

      // "New Participant" should be ENABLED (Now correct state)
      final newParticipantTile =
          find.byKey(const Key('AppDrawer_new_participant'));
      expect((tester.widget(newParticipantTile) as ListTile).enabled, isTrue);

      // "New Record" should be DISABLED (Still requires participants)
      final newRecordTile = find.byKey(const Key('AppDrawer_new_record'));
      expect((tester.widget(newRecordTile) as ListTile).enabled, isFalse);
    });

    testWidgets('Scenario F: PrintCenter Resilience - Empty State',
        (tester) async {
      // Pump without event
      await tester.pumpWidget(const BaseTestWidget(
        child: PrintCenterPage(),
      ));
      await tester.pumpAndSettle();

      // Should render without crashing (showing empty state)
      expect(find.byType(PrintCenterPage), findsOneWidget);
    });

    testWidgets('Scenario H: Autocomplete Ghost Search - Empty List',
        (tester) async {
      await tester.pumpWidget(BaseTestWidget(
        child: Scaffold(
          body: PersonAutocomplete(
            availablePersons: const [],
            onPersonSelected: (_) {},
            onRefresh: () async {},
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Ghost');
      await tester.pumpAndSettle();

      // Should show input but NO suggestions
      expect(find.byType(ListTile), findsNothing);
    });

    // =========================================================================
    // VULNERABILITIES (EXPECTED TO FAIL)
    // These tests assert *Correct Behavior*. They will FAIL because the app
    // currently lacks these protections.
    // =========================================================================

    testWidgets(
        'Scenario C: NewRecordPage - Save Button Disabled (Bug: It is Enabled)',
        (tester) async {
      await tester.pumpWidget(const BaseTestWidget(
        child: NewRecordPage(),
      ));
      await tester.pumpAndSettle();

      // Assert Desired Behavior: Save button should be DISABLED if no user selected
      final saveBtn = tester.widget<IconButton>(
          find.byKey(const Key('NewRecordPage_save_button')));

      // EXPECTED FAILURE: The button is currently enabled (reactive check only inside onPressed)
      expect(saveBtn.onPressed, isNull,
          reason:
              "Save button should be disabled when no participant selected");
    });

    testWidgets(
        'Scenario D: ParticipantList - Trap Door (Bug: Add Button Visible)',
        (tester) async {
      await tester.pumpWidget(const BaseTestWidget(
        child: ParticipantListScreen(),
      ));
      await tester.pumpAndSettle();

      // Assert Desired Behavior: "Add" button should NOT be visible if no event
      // EXPECTED FAILURE: The button is currently visible
      expect(find.byKey(const Key('ParticipantList_addButton')), findsNothing,
          reason: "Add button should be hidden when no event exists");
    });

    testWidgets('Scenario I: Zombie Detail View (Bug: Edit Button Visible)',
        (tester) async {
      final dummy = MemoryOsoba.named(
          id: 999,
          jmeno: 'Z',
          prijmeni: 'Z',
          datumNarozeni: DateTime(2000),
          adresa: '',
          zpusobilost: true,
          bezinfekcnost: true,
          wasPrinted: false);

      await tester.pumpWidget(BaseTestWidget(
        child: ParticipantDetailPage(participant: dummy),
      ));
      await tester.pumpAndSettle();

      // Assert Desired Behavior: Edit button should NOT be visible for orphaned/dummy user
      // EXPECTED FAILURE: Button is visible
      expect(
          find.byKey(const Key('ParticipantDetail_edit_button')), findsNothing,
          reason:
              "Edit button should be hidden for invalid participant context");
    });

    testWidgets('Scenario E: IntakeForm Zombie State (Bug: Crashes on Save)',
        (tester) async {
      await tester.pumpWidget(const BaseTestWidget(
        child: NewIntakeFormImproved(),
      ));
      await tester.pumpAndSettle();

      final saveButton = find.byKey(const Key('IntakeBottomRow_save_button'));
      await tester.tap(saveButton);

      // Assert Desired Behavior: App should NOT crash
      // EXPECTED FAILURE: App crashes with Null Check Operator exception
      await tester.pump();
      expect(tester.takeException(), isNull,
          reason: "App crashed on Intake Save");
    });

    testWidgets('Scenario J: Orphaned Edit Page (Bug: Crashes on Save)',
        (tester) async {
      await tester.pumpWidget(const BaseTestWidget(
        child: ParticipantRegistrationPage(),
      ));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byKey(const Key('ParticipantRegistrationForm_jmeno_input')),
          'Crash');
      await tester.enterText(
          find.byKey(const Key('ParticipantRegistrationForm_prijmeni_input')),
          'Test');

      final saveButton =
          find.byKey(const Key('ParticipantRegistrationForm_submit_button'));
      await tester.tap(saveButton);

      // Assert Desired Behavior: App should NOT crash
      // EXPECTED FAILURE: App crashes
      await tester.pump();
      expect(tester.takeException(), isNull,
          reason: "App crashed on Orphan Registration Save");
    });

    testWidgets('Scenario G: DB Crash Check (Bug: Unhandled Exception)',
        (tester) async {
      final person = MemoryOsoba.named(
          id: -1,
          jmeno: 'Crash',
          prijmeni: 'Dummy',
          datumNarozeni: DateTime(2000),
          adresa: '',
          zpusobilost: true,
          bezinfekcnost: true,
          wasPrinted: false);

      // Assert Desired Behavior: Method should throw a handled error (e.g. StateError) or return result
      // NOT crash with TypeError/NullPointer
      // EXPECTED FAILURE: Throws TypeError (Null check operator)
      expect(() async => await db.addOsoba(person),
          returnsNormally, // Or throwsA(isA<StateError>()) if we implemented fix
          reason: "Database method crashed instead of failing gracefully");
    });
  });
}
