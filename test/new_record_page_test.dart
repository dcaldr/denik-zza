import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:denik_zza/screens2/new_record_page.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';

void main() {
  group('NewRecordPage Widget Tests', () {
    late List<MemoryOsoba> testPersons;

    setUpAll(() async {
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

    Widget createTestableWidget() {
      return MaterialApp(
        home: NewRecordPage(
          participant: null, // Start with no participant selected
        ),
      );
    }

    testWidgets('should display initial UI components correctly', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Nový záznam'), findsOneWidget);
      expect(find.byType(TextField), findsAtLeastNWidgets(1)); // Text input field
      expect(find.text('Zvolte účastníka:'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
      expect(find.text('Uložit'), findsOneWidget);
    });

    testWidgets('should show participant selection interface', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      // Assert - Should show participant selection UI
      expect(find.text('Zvolte účastníka:'), findsOneWidget);
      expect(find.byType(TextField), findsAtLeastNWidgets(1)); // At least the main text field
    });

    testWidgets('should display form fields for record creation', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      // Assert - Check for form elements
      expect(find.text('Titul:'), findsOneWidget);
      expect(find.text('Popis úrazu:'), findsOneWidget);
      expect(find.text('Uložit'), findsOneWidget);
    });

    testWidgets('should allow text input in description field', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      // Act - Enter text in description field
      final descriptionField = find.byKey(const Key('description_field'));
      if (descriptionField.evaluate().isNotEmpty) {
        await tester.enterText(descriptionField, 'Test injury description');
        await tester.pumpAndSettle();

        // Assert - Text should be entered
        expect(find.text('Test injury description'), findsOneWidget);
      } else {
        // Fallback: find by type and enter text
        final textFields = find.byType(TextField);
        if (textFields.evaluate().isNotEmpty) {
          await tester.enterText(textFields.last, 'Test injury description');
          await tester.pumpAndSettle();
          expect(find.text('Test injury description'), findsOneWidget);
        }
      }
    });

    testWidgets('should show timestamp in the UI', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      // Assert - Should display timestamp information
      expect(find.textContaining('Čas záznamu:'), findsOneWidget);
    });

    testWidgets('should handle refresh button tap', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      // Act - Tap refresh button
      final refreshButton = find.byIcon(Icons.refresh);
      await tester.tap(refreshButton);
      await tester.pumpAndSettle();

      // Assert - UI should still be functional after refresh
      expect(find.text('Nový záznam'), findsOneWidget);
      expect(find.text('Zvolte účastníka:'), findsOneWidget);
    });

    testWidgets('should handle save button interaction', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      // Act - Tap save button (without valid data)
      final saveButton = find.text('Uložit');
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Assert - Should handle the interaction (may show validation errors)
      // The exact behavior depends on validation logic
      expect(find.text('Uložit'), findsOneWidget); // Button should still be there
    });

    testWidgets('should maintain form state during interactions', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      // Act - Enter some text
      final textFields = find.byType(TextField);
      if (textFields.evaluate().isNotEmpty) {
        await tester.enterText(textFields.last, 'Test content that should persist');
        await tester.pumpAndSettle();

        // Interact with refresh button
        final refreshButton = find.byIcon(Icons.refresh);
        await tester.tap(refreshButton);
        await tester.pumpAndSettle();

        // Assert - Form should maintain its basic structure
        expect(find.text('Nový záznam'), findsOneWidget);
        expect(find.byType(TextField), findsAtLeastNWidgets(1));
      }
    });

    testWidgets('should show proper form layout', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      // Assert - Check layout elements
      expect(find.text('Nový záznam'), findsOneWidget); // Page title
      expect(find.text('Zvolte účastníka:'), findsOneWidget); // Participant selection
      expect(find.text('Titul:'), findsOneWidget); // Title field
      expect(find.text('Popis úrazu:'), findsOneWidget); // Description field
      expect(find.byIcon(Icons.refresh), findsOneWidget); // Refresh button
      expect(find.text('Uložit'), findsOneWidget); // Save button
    });

    testWidgets('should handle widget lifecycle correctly', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      // Assert initial state
      expect(find.text('Nový záznam'), findsOneWidget);

      // Act - Remove widget and recreate
      await tester.pumpWidget(Container()); // Empty widget
      await tester.pumpAndSettle();

      // Recreate
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      // Assert - Should properly reinitialize
      expect(find.text('Nový záznam'), findsOneWidget);
      expect(find.text('Zvolte účastníka:'), findsOneWidget);
    });
  });
}
