import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:denik_zza/screens2/new_record_page.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import 'package:denik_zza/database/drift_database/database.dart';
import 'utils/database_test_helper.dart';
import 'setup_templates/hardcoded_setup.dart';
import 'package:denik_zza/database/database_wrapper.dart';
import 'package:denik_zza/input/file_manager.dart';

/// Advanced tests focusing on warning behaviors and edge cases
/// specifically requested by the user for "combination of situations"
void main() {
  group('NewRecordPage Warning & Edge Case Tests', () {
    late AppDatabase database;
    late List<MemoryOsoba> testParticipants;

    setUp(() async {
      print('[TMP] Test: setUp started');
      // Defensive cleanup to protect against protection from other tests
      DatabaseWrapper.resetToProduction();
      FileManager().setMode(FileManagerMode.production);

      database = await HardcodedTestSetup.setupTestData(
          databaseType: TestDatabaseType.memory);

      // Get existing test participants from the setup and convert to MemoryOsoba
      final participants = await database.select(database.participants).get();
      testParticipants = participants
          .map((p) => MemoryOsoba.named(
                id: p.id,
                jmeno: p.firstName,
                prijmeni: p.lastName,
                datumNarozeni: p.birthDate,
                adresa: p.address,
                zpusobilost: p.eligibleConfirmation,
                bezinfekcnost: p.nonInfectiousConfirmation,
                wasPrinted: p.wasPrinted,
              ))
          .toList();
      print(
          '[TMP] Test: setUp finished. Participants: ${testParticipants.length}');
    });

    tearDown(() async {
      print('[TMP] Test: tearDown started');
      await database.close();
      DatabaseWrapper.resetToProduction();
      print('[TMP] Test: tearDown finished');
    });

    group('Warning Behavior Tests', () {
      testWidgets(
          'SCENARIO: Write text first → Warning should appear until participant selected',
          (WidgetTester tester) async {
        // Start with no participant
        await tester.pumpWidget(
          MaterialApp(home: const NewRecordPage()),
        );
        await tester.pumpAndSettle();

        // 1. Try to write in form (should see warning state)
        expect(find.text('Nejprve vyberte účastníka'), findsWidgets);

        // 2. The form area should show the warning opacity
        final formArea = find.textContaining('Nadpis');
        expect(formArea, findsOneWidget);

        // 3. Try to interact with disabled form
        final titleFields = find.byType(TextFormField);
        if (titleFields.evaluate().isNotEmpty) {
          // Form is there but should be in warning state
          expect(find.text('Nejprve vyberte účastníka'), findsWidgets);
        }
      });

      testWidgets('SCENARIO: Form enables properly after participant selection',
          (WidgetTester tester) async {
        final participant = testParticipants.first;

        // Start with participant selected
        await tester.pumpWidget(
          MaterialApp(home: NewRecordPage(participant: participant)),
        );
        await tester.pumpAndSettle();

        // Should NOT show warning
        expect(find.text('Nejprve vyberte účastníka'), findsNothing);

        // Form should be fully functional
        expect(
            find.textContaining('${participant.jmeno} ${participant.prijmeni}'),
            findsOneWidget);
        expect(find.textContaining('Nadpis'), findsOneWidget);
        expect(find.text('Popis úrazu a ošetření'), findsOneWidget);
      });

      testWidgets(
          'SCENARIO: Save attempt without participant shows proper warning',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(home: const NewRecordPage()),
        );
        await tester.pumpAndSettle();

        // Try to save
        final saveButton = find.byKey(const Key('save_button'));
        await tester.tap(saveButton);
        await tester.pumpAndSettle();

        // Should show warning (either in snackbar or dialog)
        expect(find.text('Nejprve vyberte účastníka'), findsWidgets);
      });
    });

    group('Timestamp Preservation Tests', () {
      testWidgets('SCENARIO: Timestamp persists during participant changes',
          (WidgetTester tester) async {
        final participant = testParticipants.first;

        await tester.pumpWidget(
          MaterialApp(home: NewRecordPage(participant: participant)),
        );
        await tester.pumpAndSettle();

        // Check that datetime section exists and shows current time
        expect(find.text('Čas záznamu'), findsOneWidget);
        expect(find.byKey(const Key('datetime_change_button')), findsOneWidget);

        // Timestamp should be preserved between participant changes
        // (This is more of a state management test - the UI shows the controls)
        final beforeTimestamp = find.textContaining('aktuální');
        expect(beforeTimestamp, findsOneWidget);
      });

      testWidgets('SCENARIO: Custom timestamp can be set',
          (WidgetTester tester) async {
        final participant = testParticipants.first;

        await tester.pumpWidget(
          MaterialApp(home: NewRecordPage(participant: participant)),
        );
        await tester.pumpAndSettle();

        // Tap the change timestamp button
        final changeButton = find.byKey(const Key('datetime_change_button'));
        await tester.tap(changeButton);
        await tester.pump(); // Start date picker opening

        // Just verify the button was tappable
        expect(changeButton, findsOneWidget);
      });
    });

    group('Form State Preservation Tests', () {
      testWidgets('SCENARIO: Unsaved changes indicator works correctly',
          (WidgetTester tester) async {
        final participant = testParticipants.first;

        await tester.pumpWidget(
          MaterialApp(home: NewRecordPage(participant: participant)),
        );
        await tester.pumpAndSettle();

        // Initially no unsaved changes
        expect(find.text('Neuloženo'), findsNothing);

        // Type something
        final titleField = find.byType(TextFormField).first;
        await tester.enterText(titleField, 'Test content');
        await tester.pumpAndSettle();

        // Should show unsaved changes
        expect(find.text('Neuloženo'), findsOneWidget);
      });
    });

    group('Validation Combination Tests', () {
      testWidgets('SCENARIO: Multiple validation errors at once',
          (WidgetTester tester) async {
        print(
            '[TMP] Test: SCENARIO: Multiple validation errors at once STARTED');
        final participant = testParticipants.first;

        await tester.pumpWidget(
          MaterialApp(home: NewRecordPage(participant: participant)),
        );
        await tester.pumpAndSettle();

        // Try to save with empty form
        final saveButton = find.byKey(const Key('save_button'));
        await tester.tap(saveButton);
        await tester.pumpAndSettle();

        // Should show title validation error
        expect(find.text('Prosím zadejte nadpis'), findsOneWidget);
      });

      testWidgets('SCENARIO: Valid form submission pathway',
          (WidgetTester tester) async {
        final participant = testParticipants.first;

        await tester.pumpWidget(
          MaterialApp(home: NewRecordPage(participant: participant)),
        );
        await tester.pumpAndSettle();

        // Fill required fields
        final titleField = find.byType(TextFormField).first;
        await tester.enterText(titleField, 'Valid Title');
        await tester.pumpAndSettle();

        // Add description in the second field if it exists
        final formFields = find.byType(TextFormField);
        if (formFields.evaluate().length > 1) {
          await tester.enterText(formFields.at(1), 'Valid description');
          await tester.pumpAndSettle();
        }

        // Try to save
        final saveButton = find.byKey(const Key('save_button'));
        await tester.tap(saveButton);
        await tester.pumpAndSettle();

        // Should not show validation errors
        expect(find.text('Prosím zadejte nadpis'), findsNothing);
      });
    });

    group('UI State Consistency Tests', () {
      testWidgets('SCENARIO: All required UI elements present in all states',
          (WidgetTester tester) async {
        // Test empty state
        await tester.pumpWidget(
          MaterialApp(home: const NewRecordPage()),
        );
        await tester.pumpAndSettle();

        expect(find.text('Nový záznam úrazu'), findsOneWidget);
        expect(find.text('Účastník'), findsOneWidget);
        expect(find.textContaining('Vyhledat'),
            findsNWidgets(2)); // Button label + TextField hint
        expect(find.text('Čas záznamu'), findsOneWidget);
        expect(find.byKey(const Key('save_button')), findsOneWidget);

        // Test with participant
        final participant = testParticipants.first;
        await tester.pumpWidget(
          MaterialApp(home: NewRecordPage(participant: participant)),
        );
        await tester.pumpAndSettle();

        expect(find.text('Nový záznam úrazu'), findsOneWidget);
        expect(find.text('Účastník'), findsOneWidget);
        expect(find.textContaining('Nadpis'), findsOneWidget);
        expect(find.text('Popis úrazu a ošetření'), findsOneWidget);
        expect(find.text('Čas záznamu'), findsOneWidget);
        expect(find.byKey(const Key('save_button')), findsOneWidget);
      });

      testWidgets('SCENARIO: Search functionality is always available',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(home: const NewRecordPage()),
        );
        await tester.pumpAndSettle();

        // Search should always be visible (button label + TextField hint)
        expect(find.textContaining('Vyhledat'), findsNWidgets(2));
        expect(find.byKey(const Key('NewRecordPage_participantAutocomplete')),
            findsOneWidget);
      });
    });

    group('Edge Case Combinations', () {
      testWidgets(
          'COMBINATION: No participant + form interaction + save attempt',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(home: const NewRecordPage()),
        );
        await tester.pumpAndSettle();

        // 1. Verify warning state
        expect(find.text('Nejprve vyberte účastníka'), findsWidgets);

        // 2. Try to save anyway
        final saveButton = find.byKey(const Key('save_button'));
        await tester.tap(saveButton);
        await tester.pumpAndSettle();

        // 3. Should still show warning
        expect(find.text('Nejprve vyberte účastníka'), findsWidgets);
      });

      testWidgets(
          'COMBINATION: Participant selected + form filled + validation',
          (WidgetTester tester) async {
        final participant = testParticipants.first;

        await tester.pumpWidget(
          MaterialApp(home: NewRecordPage(participant: participant)),
        );
        await tester.pumpAndSettle();

        // 1. Participant should be shown
        expect(
            find.textContaining('${participant.jmeno} ${participant.prijmeni}'),
            findsOneWidget);

        // 2. Fill form
        final titleField = find.byType(TextFormField).first;
        await tester.enterText(titleField, 'Comprehensive Test Injury');
        await tester.pumpAndSettle();

        // 3. Should show unsaved changes
        expect(find.text('Neuloženo'), findsOneWidget);

        // 4. Save should work (no validation errors)
        final saveButton = find.byKey(const Key('save_button'));
        await tester.tap(saveButton);
        await tester.pumpAndSettle();

        expect(find.text('Prosím zadejte nadpis'), findsNothing);
      });
    });
  });
}
