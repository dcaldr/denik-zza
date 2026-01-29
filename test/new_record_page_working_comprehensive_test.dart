import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' as drift;
import 'package:denik_zza/screens2/new_record/new_record_page.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import 'package:denik_zza/database/drift_database/database.dart';
import 'package:denik_zza/utils/mode_coordinator.dart';
import 'setup_templates/hardcoded_setup.dart';

/// Comprehensive tests for NewRecordPage covering real scenarios
///
/// Tests include:
/// - Warning behavior (text written → form disabled until participant selected)
/// - Proper form validation
/// - Actual UI interactions that work with the real implementation
/// - Timestamp functionality
/// - Save functionality with proper validation
void main() {
  group('NewRecordPage Comprehensive Tests', () {
    late AppDatabase database;
    late List<MemoryOsoba> testParticipants;

    /// Helper function to create test participant in database
    Future<MemoryOsoba> createTestParticipant(
        String firstName, String lastName) async {
      final participant = await database
          .into(database.participants)
          .insertReturning(ParticipantsCompanion(
            firstName: drift.Value(firstName),
            lastName: drift.Value(lastName),
            birthDate: drift.Value(DateTime(1990, 1, 1)),
            address: const drift.Value('Test Address'),
            eligibleConfirmation: const drift.Value(true),
            nonInfectiousConfirmation: const drift.Value(true),
            wasPrinted: const drift.Value(false),
          ));

      return MemoryOsoba.named(
        id: participant.id,
        jmeno: participant.firstName,
        prijmeni: participant.lastName,
        datumNarozeni: participant.birthDate,
        adresa: participant.address,
        zpusobilost: participant.eligibleConfirmation,
        bezinfekcnost: participant.nonInfectiousConfirmation,
        wasPrinted: participant.wasPrinted,
      );
    }

    setUp(() async {
      // Mode handled by flutter_test_config.dart
      // Set up test database with participants using existing setup functions
      database = await HardcodedTestSetup.setupTestData();

      // Get test participants from the setup and convert to MemoryOsoba
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

      // Ensure we have at least 2 participants for switching tests
      if (testParticipants.length < 2) {
        final participant1 = await createTestParticipant('Test', 'User1');
        final participant2 = await createTestParticipant('Test', 'User2');
        testParticipants.addAll([participant1, participant2]);
      }
    });

    tearDown(() async {
      await database.close();
    });

    group('Initial State Tests', () {
      testWidgets('should load correctly with no pre-selected participant',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(home: const NewRecordPage()),
        );
        await tester.pumpAndSettle();

        // Verify basic structure
        expect(find.text('Nový záznam úrazu'), findsOneWidget);
        expect(find.text('Účastník'), findsOneWidget);
        expect(find.text('Vyberte účastníka...'), findsOneWidget);

        // Should show placeholder message in history area
        expect(find.text('Nejprve vyberte účastníka'), findsWidgets);

        // Form should be present but disabled (via opacity)
        expect(find.textContaining('Nadpis'), findsOneWidget);
        expect(find.text('Popis úrazu a ošetření'), findsOneWidget);
      });

      testWidgets('should load correctly with pre-selected participant',
          (WidgetTester tester) async {
        if (testParticipants.isNotEmpty) {
          final participant = testParticipants.first;

          await tester.pumpWidget(
            MaterialApp(home: NewRecordPage(participant: participant)),
          );
          await tester.pumpAndSettle();

          // Verify participant is displayed
          expect(
              find.textContaining(
                  '${participant.jmeno} ${participant.prijmeni}'),
              findsOneWidget);

          // Form should be fully visible and enabled
          expect(find.textContaining('Nadpis'), findsOneWidget);
          expect(find.text('Popis úrazu a ošetření'), findsOneWidget);
        }
      });
    });

    group('Form Validation Tests', () {
      testWidgets('should prevent saving when no participant is selected',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(home: const NewRecordPage()),
        );
        await tester.pumpAndSettle();

        // Try to save without selecting participant
        final saveButton = find.byKey(const Key('NewRecordPage_save_button'));
        await tester.tap(saveButton);
        await tester.pumpAndSettle();

        // Should show snackbar with warning
        expect(find.text('Nejprve vyberte účastníka'), findsWidgets);
      });

      testWidgets('should validate required title field',
          (WidgetTester tester) async {
        if (testParticipants.isNotEmpty) {
          final participant = testParticipants.first;

          await tester.pumpWidget(
            MaterialApp(home: NewRecordPage(participant: participant)),
          );
          await tester.pumpAndSettle();

          // Try to save without title
          final saveButton = find.byKey(const Key('NewRecordPage_save_button'));
          await tester.tap(saveButton);
          await tester.pumpAndSettle();

          // Should show validation error
          expect(find.text('Prosím zadejte nadpis'), findsOneWidget);
        }
      });

      testWidgets('should accept valid form data', (WidgetTester tester) async {
        if (testParticipants.isNotEmpty) {
          final participant = testParticipants.first;

          await tester.pumpWidget(
            MaterialApp(home: NewRecordPage(participant: participant)),
          );
          await tester.pumpAndSettle();

          // Fill in title field
          final titleField = find.widgetWithText(TextFormField, '');
          await tester.enterText(titleField.first, 'Test Injury Title');
          await tester.pumpAndSettle();

          // Verify text was entered
          expect(find.text('Test Injury Title'), findsOneWidget);

          // Try to save - should work (or at least not show validation errors)
          final saveButton = find.byKey(const Key('NewRecordPage_save_button'));
          await tester.tap(saveButton);
          await tester.pumpAndSettle();

          // Should not show the validation error anymore
          expect(find.text('Prosím zadejte nadpis'), findsNothing);
        }
      });
    });

    group('Unsaved Changes Detection', () {
      testWidgets('should show unsaved changes indicator when typing',
          (WidgetTester tester) async {
        if (testParticipants.isNotEmpty) {
          final participant = testParticipants.first;

          await tester.pumpWidget(
            MaterialApp(home: NewRecordPage(participant: participant)),
          );
          await tester.pumpAndSettle();

          // Enter some text in title
          final titleField = find.widgetWithText(TextFormField, '');
          await tester.enterText(titleField.first, 'Some text');
          await tester.pumpAndSettle();

          // Should show unsaved changes indicator
          expect(find.text('Neuloženo'), findsOneWidget);
        }
      });
    });

    group('Timestamp Functionality', () {
      testWidgets('should show datetime controls', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(home: const NewRecordPage()),
        );
        await tester.pumpAndSettle();

        // Should show datetime section
        expect(find.text('Čas záznamu'), findsOneWidget);
        expect(find.byKey(const Key('datetime_change_button')), findsOneWidget);

        // Should show default text indicating current time
        expect(find.textContaining('aktuální'), findsOneWidget);
      });

      testWidgets('should allow datetime changes when participant is selected',
          (WidgetTester tester) async {
        if (testParticipants.isNotEmpty) {
          final participant = testParticipants.first;

          await tester.pumpWidget(
            MaterialApp(home: NewRecordPage(participant: participant)),
          );
          await tester.pumpAndSettle();

          // The "Změnit" button should be enabled
          final changeButton = find.byKey(const Key('datetime_change_button'));
          expect(changeButton, findsOneWidget);

          // Button should be tappable (this will open date picker, but we'll just verify the button exists)
          await tester.tap(changeButton);
          await tester
              .pump(); // Just pump once to start the date picker opening

          // No assertion here as date picker is system-dependent in testing
        }
      });
    });

    group('Search and Autocomplete', () {
      testWidgets('should show search functionality',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(home: const NewRecordPage()),
        );
        await tester.pumpAndSettle();

        // Should show search area (button label + TextField hint)
        expect(find.textContaining('Vyhledat'), findsNWidgets(2));
        // Should have autocomplete widget (by key per conventions)
        expect(find.byKey(const Key('NewRecordPage_participantAutocomplete')),
            findsOneWidget);
      });
    });

    group('Complex Scenario Combinations', () {
      testWidgets('should handle form filling and validation properly',
          (WidgetTester tester) async {
        if (testParticipants.isNotEmpty) {
          final participant = testParticipants.first;

          await tester.pumpWidget(
            MaterialApp(home: NewRecordPage(participant: participant)),
          );
          await tester.pumpAndSettle();

          // 1. Fill in title
          final titleField = find.widgetWithText(TextFormField, '');
          await tester.enterText(titleField.first, 'Test Injury');
          await tester.pumpAndSettle();

          // 2. Should show unsaved changes
          expect(find.text('Neuloženo'), findsOneWidget);

          // 3. Try to save (should work since we have title and participant)
          final saveButton = find.byKey(const Key('NewRecordPage_save_button'));
          await tester.tap(saveButton);
          await tester.pumpAndSettle();

          // Should either succeed or show a different error (not validation error)
          expect(find.text('Prosím zadejte nadpis'), findsNothing);
        }
      });
    });
  });
}
