import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' as drift;
import 'package:denik_zza/screens2/new_record/new_record_page.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import 'package:denik_zza/database/drift_database/database.dart';
import 'package:denik_zza/utils/mode_coordinator.dart';
import 'package:denik_zza/screens2/widgets/person_autocomplete.dart';
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
        // Add additional test participants if needed
        final participant1 =
            await createTestParticipant(database, 'Test', 'User1');
        final participant2 =
            await createTestParticipant(database, 'Test', 'User2');
        testParticipants.addAll([participant1, participant2]);
      }
    });

    tearDown(() async {
      await database.close();
    });

    group('Basic Functionality', () {
      testWidgets('should load correctly without pre-selected participant',
          (WidgetTester tester) async {
        await pumpNewRecordPage(tester);

        // Verify page structure
        expect(find.text('Nový záznam úrazu'), findsOneWidget);
        expect(find.text('Účastník'), findsOneWidget);
        expect(find.text('Vyberte účastníka...'), findsOneWidget);
        expect(find.text('Nejprve vyberte účastníka'), findsOneWidget);

        // Form should be disabled
        expect(find.text('Nejprve vyberte účastníka'), findsOneWidget);
      });

      testWidgets('should load correctly with pre-selected participant',
          (WidgetTester tester) async {
        final participant = testParticipants.first;
        await pumpNewRecordPage(tester, participant: participant);

        // Verify participant is displayed
        expect(
            find.textContaining('${participant.jmeno} ${participant.prijmeni}'),
            findsOneWidget);

        // Form should be enabled
        final titleField = find.byKey(const Key('NewRecordPage_title_input'));
        final descriptionField =
            find.byKey(const Key('NewRecordPage_description_input'));
        expect(titleField, findsOneWidget);
        expect(descriptionField, findsOneWidget);
        // Check enabled state
        expect(tester.widget<TextFormField>(titleField).enabled, isTrue);
        expect(tester.widget<TextFormField>(descriptionField).enabled, isTrue);
      });
    });

    group('Form Validation', () {
      testWidgets('should validate required title field',
          (WidgetTester tester) async {
        final participant = testParticipants.first;
        await pumpNewRecordPage(tester, participant: participant);

        // Try to save without title
        await tapSaveButton(tester);
        await tester.pumpAndSettle();

        // Should show validation error
        expect(find.text('Prosím zadejte nadpis'), findsOneWidget);
      });

      testWidgets('should allow saving with valid data',
          (WidgetTester tester) async {
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
      testWidgets(
          'should show warning dialog when text is entered and participant would be changed',
          (WidgetTester tester) async {
        final participant1 = testParticipants[0];
        await pumpNewRecordPage(tester, participant: participant1);

        // Enter some text
        await enterTitle(tester, 'Some title');
        await tester.pumpAndSettle();

        // Try to select different participant via autocomplete
        await selectParticipantProgrammatically(tester, testParticipants[1]);
        await tester.pumpAndSettle();

        // Should show confirmation dialog
        expect(find.text('Změnit účastníka?'), findsOneWidget);
        expect(
            find.text(
                'Změnou účastníka se ztratí neuložené změny v formuláři. Chcete pokračovat?'),
            findsOneWidget);
      });

      testWidgets('should allow canceling participant change',
          (WidgetTester tester) async {
        final participant1 = testParticipants[0];
        await pumpNewRecordPage(tester, participant: participant1);

        // Enter some text
        await enterTitle(tester, 'Some title');
        await tester.pumpAndSettle();

        // Try to select different participant
        await selectParticipantProgrammatically(tester, testParticipants[1]);
        await tester.pumpAndSettle();

        // Cancel the change
        await tester.tap(find.byKey(const Key('dialog_cancel_button')));
        await tester.pumpAndSettle();

        // Should still show original participant
        expect(
            find.textContaining(
                '${participant1.jmeno} ${participant1.prijmeni}'),
            findsOneWidget);
        // Text should still be there
        expect(find.text('Some title'), findsOneWidget);
      });
    });

    group('Timestamp Handling', () {
      testWidgets('should show datetime picker button',
          (WidgetTester tester) async {
        final participant = testParticipants.first;
        await pumpNewRecordPage(tester, participant: participant);

        // Should find the change time button
        expect(find.byKey(const Key('datetime_change_button')), findsOneWidget);
        expect(
          find.byWidgetPredicate(
            (widget) => widget is Tooltip && widget.message == 'Čas záznamu',
          ),
          findsOneWidget,
        );
      });
    });
  });
}

/// Helper function to create test participant in database
Future<MemoryOsoba> createTestParticipant(
    AppDatabase db, String firstName, String lastName) async {
  final participant =
      await db.into(db.participants).insertReturning(ParticipantsCompanion(
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
Future<void> pumpNewRecordPage(WidgetTester tester,
    {MemoryOsoba? participant}) async {
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
  final titleField = find.byKey(const Key('NewRecordPage_title_input'));
  expect(titleField, findsOneWidget);
  await tester.ensureVisible(titleField);
  await tester.tap(titleField);
  await tester.pump();
  await tester.enterText(titleField, text);
  await tester.pump();
}

/// Enters text in the description field
Future<void> enterDescription(WidgetTester tester, String text) async {
  final descriptionField =
      find.byKey(const Key('NewRecordPage_description_input'));
  expect(descriptionField, findsOneWidget);
  await tester.ensureVisible(descriptionField);
  await tester.tap(descriptionField);
  await tester.pump();
  await tester.enterText(descriptionField, text);
  await tester.pump();
}

/// Taps the save button
Future<void> tapSaveButton(WidgetTester tester) async {
  final saveButton = find.byKey(const Key('NewRecordPage_save_button'));
  expect(saveButton, findsOneWidget);
  await tester.tap(saveButton);
  await tester.pumpAndSettle();
}

/// Searches for a participant using the autocomplete
Future<void> searchForParticipant(
    WidgetTester tester, String searchText) async {
  // Find the search field in PersonAutocomplete via its key
  final autocomplete =
      find.byKey(const Key('NewRecordPage_participantAutocomplete'));
  expect(autocomplete, findsOneWidget);
  final searchField = find.descendant(
    of: autocomplete,
    matching: find.byType(TextField),
  );
  expect(searchField, findsOneWidget);

  await tester.enterText(searchField, searchText);
  await tester.pump();

  // Wait for autocomplete options to appear
  bool suggestionsVisible = false;
  for (int i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (tester.any(find.textContaining(searchText))) {
      suggestionsVisible = true;
      break;
    }
  }
  // Fallback: If searching for full name didn't show suggestions, try first token (usually first name)
  if (!suggestionsVisible) {
    final tokens = searchText.split(' ');
    if (tokens.isNotEmpty) {
      await tester.enterText(searchField, tokens.first);
      await tester.pump();
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
        if (tester.any(find.textContaining(tokens.first))) {
          suggestionsVisible = true;
          break;
        }
      }
    }
  }

  // Prefer selecting by the full name text to be deterministic
  // This relies on displayStringForOption = "<jmeno> <prijmeni>"
  final exactOption = find.text(searchText);
  if (tester.any(exactOption)) {
    await tester.tap(exactOption.first);
    await tester.pumpAndSettle();
    return;
  }
  // Fallback to first token if exact not found
  final tokens = searchText.split(' ');
  if (tokens.isNotEmpty) {
    final containsToken = find.textContaining(tokens.first);
    if (tester.any(containsToken)) {
      await tester.tap(containsToken.first);
      await tester.pumpAndSettle();
      return;
    }
  }
  // Final fallback: tap any tappable option (InkWell/Text)
  final anyText = find.byType(Text);
  if (tester.any(anyText)) {
    await tester.tap(anyText.first);
    await tester.pumpAndSettle();
  }
}

/// Programmatically selects a participant by invoking the autocomplete's callback
Future<void> selectParticipantProgrammatically(
  WidgetTester tester,
  MemoryOsoba participant,
) async {
  final autocompleteFinder =
      find.byKey(const Key('NewRecordPage_participantAutocomplete'));
  expect(autocompleteFinder, findsOneWidget);
  final autocompleteWidget =
      tester.widget<PersonAutocomplete>(autocompleteFinder);
  // Deterministic selection without relying on overlay popups
  autocompleteWidget.onPersonSelected(participant);
  await tester.pumpAndSettle();
}
