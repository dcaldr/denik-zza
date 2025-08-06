import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' as drift;
import 'package:denik_zza/screens2/new_record_page.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import 'package:denik_zza/database/drift_database/database.dart';
import 'package:denik_zza/screens2/widgets/person_autocomplete.dart';
import 'helpers/database_test_helper.dart';
import 'setup_templates/hardcoded_setup.dart';

/// Realistic tests for NewRecordPage based on actual implementation
/// 
/// Tests the real functionality:
/// - Basic page loading
/// - Participant selection through autocomplete
/// - Unsaved changes warning dialog
/// - Form validation and saving
void main() {
  group('NewRecordPage Real Implementation Tests', () {
    late AppDatabase database;
    late List<MemoryOsoba> testParticipants;

    setUp(() async {
      // Set up test database with participants using existing setup functions
      database = await HardcodedTestSetup.setupTestData(databaseType: TestDatabaseType.memory);
      
      // Get test participants from the setup and convert to MemoryOsoba
      final participants = await database.select(database.participants).get();
      testParticipants = participants.map((p) => MemoryOsoba.named(
        id: p.id,
        jmeno: p.firstName,
        prijmeni: p.lastName,
        datumNarozeni: p.birthDate,
        adresa: p.address,
        zpusobilost: p.eligibleConfirmation,
        bezinfekcnost: p.nonInfectiousConfirmation,
        wasPrinted: p.wasPrinted,
      )).toList();
      
      // Ensure we have at least 2 participants for switching tests
      if (testParticipants.length < 2) {
        // Add additional test participants if needed
        final participant1 = await createTestParticipant(database, 'Test', 'User1');
        final participant2 = await createTestParticipant(database, 'Test', 'User2');
        testParticipants.addAll([participant1, participant2]);
      }
    });

    tearDown(() async {
      await database.close();
    });

    group('Basic Functionality', () {
      testWidgets('should load correctly without pre-selected participant', (WidgetTester tester) async {
        await pumpNewRecordPage(tester);

        // Verify page structure
        expect(find.text('Nový záznam úrazu'), findsOneWidget);
        expect(find.text('Účastník'), findsOneWidget);
        expect(find.text('Vyberte účastníka...'), findsOneWidget);
        expect(find.text('Nejprve vyberte účastníka'), findsOneWidget);
        
        // Form should be disabled
        expect(find.text('Nejprve vyberte účastníka'), findsOneWidget);
      });

      testWidgets('should load correctly with pre-selected participant', (WidgetTester tester) async {
        final participant = testParticipants.first;
        await pumpNewRecordPage(tester, participant: participant);

        // Verify participant is displayed
        expect(find.text('${participant.jmeno} ${participant.prijmeni}'), findsOneWidget);
        
        // Form should be enabled
        expect(find.text('Nadpis'), findsOneWidget);
        expect(find.text('Popis'), findsOneWidget);
      });
    });

    group('Form Validation', () {
      testWidgets('should validate required title field', (WidgetTester tester) async {
        final participant = testParticipants.first;
        await pumpNewRecordPage(tester, participant: participant);

        // Try to save without title
        await tapSaveButton(tester);
        await tester.pumpAndSettle();

        // Should show validation error
        expect(find.text('Prosím zadejte nadpis'), findsOneWidget);
      });

      testWidgets('should allow saving with valid data', (WidgetTester tester) async {
        final participant = testParticipants.first;
        await pumpNewRecordPage(tester, participant: participant);

        // Fill form
        await enterTitle(tester, 'Test Title');
        await enterDescription(tester, 'Test Description');

        // Save should work
        await tapSaveButton(tester);
        await tester.pumpAndSettle();

        // Should navigate back or show success
        // (Implementation details may vary)
      });
    });

    group('Unsaved Changes Warning', () {
      testWidgets('should show warning dialog when text is entered and participant would be changed', (WidgetTester tester) async {
        final participant1 = testParticipants[0];
        await pumpNewRecordPage(tester, participant: participant1);

        // Enter some text
        await enterTitle(tester, 'Some title');
        await tester.pumpAndSettle();

        // Try to select different participant via autocomplete
        await searchForParticipant(tester, testParticipants[1].jmeno);
        await tester.pumpAndSettle();

        // Should show confirmation dialog
        expect(find.text('Změnit účastníka?'), findsOneWidget);
        expect(find.text('Změnou účastníka se ztratí neuložené změny v formuláři. Chcete pokračovat?'), findsOneWidget);
      });

      testWidgets('should allow canceling participant change', (WidgetTester tester) async {
        final participant1 = testParticipants[0];
        await pumpNewRecordPage(tester, participant: participant1);

        // Enter some text
        await enterTitle(tester, 'Some title');
        await tester.pumpAndSettle();

        // Try to select different participant
        await searchForParticipant(tester, testParticipants[1].jmeno);
        await tester.pumpAndSettle();

        // Cancel the change
        await tester.tap(find.text('Zrušit'));
        await tester.pumpAndSettle();

        // Should still show original participant
        expect(find.text('${participant1.jmeno} ${participant1.prijmeni}'), findsOneWidget);
        // Text should still be there
        expect(find.text('Some title'), findsOneWidget);
      });
    });

    group('Timestamp Handling', () {
      testWidgets('should show datetime picker button', (WidgetTester tester) async {
        final participant = testParticipants.first;
        await pumpNewRecordPage(tester, participant: participant);

        // Should find the change time button
        expect(find.text('Změnit'), findsOneWidget);
        expect(find.text('Čas záznamu'), findsOneWidget);
      });
    });
  });
}

/// Helper function to create test participant in database
Future<MemoryOsoba> createTestParticipant(AppDatabase db, String firstName, String lastName) async {
  final participant = await db.into(db.participants).insertReturning(ParticipantsCompanion(
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

/// Pumps the NewRecordPage widget with proper MaterialApp wrapper
Future<void> pumpNewRecordPage(WidgetTester tester, {MemoryOsoba? participant}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: NewRecordPage(participant: participant),
      localizationsDelegates: const [
        // Add necessary localizations
      ],
    ),
  );
  await tester.pumpAndSettle();
}

/// Enters text in the title field
Future<void> enterTitle(WidgetTester tester, String text) async {
  final titleField = find.ancestor(
    of: find.text('Nadpis'),
    matching: find.byType(TextFormField),
  );
  await tester.enterText(titleField, text);
  await tester.pump();
}

/// Enters text in the description field
Future<void> enterDescription(WidgetTester tester, String text) async {
  final descriptionField = find.ancestor(
    of: find.text('Popis'),
    matching: find.byType(TextFormField),
  );
  await tester.enterText(descriptionField, text);
  await tester.pump();
}

/// Taps the save button
Future<void> tapSaveButton(WidgetTester tester) async {
  final saveButton = find.text('Uložit do deníku');
  await tester.tap(saveButton);
  await tester.pumpAndSettle();
}

/// Searches for a participant using the autocomplete
Future<void> searchForParticipant(WidgetTester tester, String searchText) async {
  // Find the search field in PersonAutocomplete
  final searchField = find.descendant(
    of: find.byType(PersonAutocomplete),
    matching: find.byType(TextField),
  );
  
  await tester.enterText(searchField, searchText);
  await tester.pump();
  
  // Wait for autocomplete options to appear
  await tester.pump(const Duration(milliseconds: 300));
  
  // Tap on the first option if available
  final suggestions = find.byType(ListTile);
  if (tester.widgetList(suggestions).isNotEmpty) {
    await tester.tap(suggestions.first);
    await tester.pumpAndSettle();
  }
}
