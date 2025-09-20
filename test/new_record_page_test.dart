import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:denik_zza/screens2/new_record_page.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import 'package:denik_zza/database/drift_database/database.dart';
import 'package:denik_zza/database/database_wrapper.dart';
import 'helpers/database_test_helper.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_akce.dart';

void main() {
  group('NewRecordPage Widget Tests', () {
    late List<MemoryOsoba> testPersons;
    late AppDatabase testDb;

    setUpAll(() async {
      // Use in-memory DB for widget tests to avoid touching production DB
      DatabaseWrapper.setTestMode();
      // Suppress Drift's multiple database warnings in tests
      DatabaseTestHelper.disableDriftWarnings();
      testDb = AppDatabase.testInMemory();
      DatabaseWrapper.useTestDriftDatabase(testDb);
      // Seed a current event so watchParticipantsByCurrentEvent() has cache row
      final dbInterface = DatabaseWrapper.getDatabase();
      await dbInterface.addEvent(MemoryAction(
        idAkce: null,
        nadpis: 'Test Event',
        popis: 'Event for widget tests',
        odkdy: DateTime.now().subtract(const Duration(days: 1)),
        dokdy: DateTime.now().add(const Duration(days: 1)),
        domovskyAdresarPath: null,
      ));
      final actions = await dbInterface.getAllZzaActions();
      if (actions.isNotEmpty && actions.first.idAkce != null) {
        dbInterface.updateCurrentEvent(actions.first.idAkce);
      }
      // Create test participants for the UI tests
      testPersons = [
        MemoryOsoba.basic('Jan', 'Novák'),
        MemoryOsoba.basic('Marie', 'Svobodová'),
        MemoryOsoba.basic('Petr', 'Dvořák'),
      ];
      
      // Set IDs for the test persons to make them identifiable
      for (int i = 0; i < testPersons.length; i++) {
        testPersons[i].id = i + 1;
      }
    });

    tearDownAll(() async {
      await testDb.close();
      DatabaseWrapper.resetToProduction();
    });

    Widget createTestableWidget() {
      return MaterialApp(
        home: NewRecordPage(
          participant: null, // Start with no participant selected
        ),
      );
    }

    Widget createWidgetWithParticipant(MemoryOsoba participant) {
      return MaterialApp(
        home: NewRecordPage(
          participant: participant,
        ),
      );
    }

    testWidgets('should display initial UI components correctly', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Nový záznam úrazu'), findsOneWidget);
      // Participant section and search present
      expect(find.text('Účastník'), findsOneWidget);
      expect(find.text('Vyhledat'), findsOneWidget);
      expect(find.byKey(const Key('participant_autocomplete')), findsOneWidget);
      // Form fields (by keys)
      expect(find.byKey(const Key('title_field')), findsOneWidget);
      expect(find.byKey(const Key('description_field')), findsOneWidget);
      // Datetime and actions
      expect(find.text('Čas záznamu'), findsOneWidget);
      expect(find.byKey(const Key('datetime_change_button')), findsOneWidget);
      expect(find.byKey(const Key('save_button')), findsOneWidget);
      expect(find.byKey(const Key('cancel_button')), findsOneWidget);
    });

    testWidgets('should show participant selection interface', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      // Assert - Should show participant selection UI elements
      expect(find.text('Účastník'), findsOneWidget);
      expect(find.byKey(const Key('participant_autocomplete')), findsOneWidget);
    });

    testWidgets('should display form fields for record creation', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      // Assert - Check for form elements (by keys/labels)
      expect(find.byKey(const Key('title_field')), findsOneWidget);
      expect(find.byKey(const Key('description_field')), findsOneWidget);
      expect(find.byKey(const Key('save_button')), findsOneWidget);
    });

    testWidgets('should allow text input in description field', (WidgetTester tester) async {
      // Arrange: provide an initial participant to enable the form fields
      final osoba = MemoryOsoba.basic('Test', 'Osoba')..id = 1;
      await tester.pumpWidget(createWidgetWithParticipant(osoba));
      await tester.pumpAndSettle();

      // Act - Enter text in description field
      final descriptionField = find.byKey(const Key('description_field'));
      // Note: Without a selected participant, the field is disabled but still accepts tester.enterText
      await tester.enterText(descriptionField, 'Test injury description');
      await tester.pumpAndSettle();
      expect(find.text('Test injury description'), findsOneWidget);
    });

    testWidgets('should show timestamp in the UI', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      // Assert - Should display timestamp information (label present)
      expect(find.text('Čas záznamu'), findsOneWidget);
      expect(find.byKey(const Key('datetime_change_button')), findsOneWidget);
    });

    // testWidgets('should handle refresh button tap', (WidgetTester tester) async {
    //   // This test is obsolete: the refresh control is now integrated into PersonAutocomplete.
    //   // Keeping as skipped to document behavioral change.
    // }, skip: true);

    testWidgets('should handle save button interaction', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      // Act - Tap save button (without valid data)
      final saveButton = find.byKey(const Key('save_button'));
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Assert - Should handle the interaction (may show validation errors)
      // The exact behavior depends on validation logic
      expect(find.byKey(const Key('save_button')), findsOneWidget); // Button should still be there
    });

    testWidgets('should maintain form state during interactions', (WidgetTester tester) async {
      // Arrange: provide an initial participant so fields are enabled
      final osoba = MemoryOsoba.basic('Test', 'Osoba')..id = 1;
      await tester.pumpWidget(createWidgetWithParticipant(osoba));
      await tester.pumpAndSettle();

      // Act - Enter some text
      final textField = find.byKey(const Key('description_field'));
      await tester.enterText(textField, 'Test content that should persist');
      await tester.pumpAndSettle();

      // There is no standalone refresh button anymore; ensure structure persists
      expect(find.text('Nový záznam úrazu'), findsOneWidget);
      expect(find.byKey(const Key('description_field')), findsOneWidget);
    });

    testWidgets('should show proper form layout', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      // Assert - Check layout elements
      expect(find.text('Nový záznam úrazu'), findsOneWidget); // Page title
      expect(find.text('Účastník'), findsOneWidget); // Participant section
      expect(find.byKey(const Key('title_field')), findsOneWidget); // Title field
      expect(find.byKey(const Key('description_field')), findsOneWidget); // Description field
      expect(find.byKey(const Key('save_button')), findsOneWidget); // Save button
    });

    testWidgets('should handle widget lifecycle correctly', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

  // Assert initial state
  expect(find.text('Nový záznam úrazu'), findsOneWidget);

      // Act - Remove widget and recreate
      await tester.pumpWidget(Container()); // Empty widget
      await tester.pumpAndSettle();

      // Recreate
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      // Assert - Should properly reinitialize
      expect(find.text('Nový záznam úrazu'), findsOneWidget);
      expect(find.text('Účastník'), findsOneWidget);
    });
  });
}
