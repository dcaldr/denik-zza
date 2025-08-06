import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:denik_zza/screens2/new_record_page.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import 'package:denik_zza/database/drift_database/database.dart';
import 'helpers/database_test_helper.dart';
import 'setup_templates/hardcoded_setup.dart';

/// Basic working tests for NewRecordPage
/// 
/// These tests focus on what actually works and is testable
void main() {
  group('NewRecordPage Basic Tests', () {
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
    });

    tearDown(() async {
      await database.close();
    });

    testWidgets('should render without crashing', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const NewRecordPage(),
        ),
      );
      await tester.pumpAndSettle();

      // Basic structure should be present
      expect(find.text('Nový záznam úrazu'), findsOneWidget);
      expect(find.text('Účastník'), findsOneWidget);
    });

    testWidgets('should show participant info when participant is provided', (WidgetTester tester) async {
      if (testParticipants.isNotEmpty) {
        final participant = testParticipants.first;
        
        await tester.pumpWidget(
          MaterialApp(
            home: NewRecordPage(participant: participant),
          ),
        );
        await tester.pumpAndSettle();

        // Should show participant name
        expect(find.text('${participant.jmeno} ${participant.prijmeni}'), findsOneWidget);
      }
    });

    testWidgets('should have form fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const NewRecordPage(),
        ),
      );
      await tester.pumpAndSettle();

      // Should have form fields
      expect(find.text('Nadpis'), findsOneWidget);
      expect(find.text('Popis úrazu a ošetření'), findsOneWidget);
      expect(find.text('Uložit do deníku'), findsOneWidget);
    });

    testWidgets('should show datetime section', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const NewRecordPage(),
        ),
      );
      await tester.pumpAndSettle();

      // Should have datetime section
      expect(find.text('Čas záznamu'), findsOneWidget);
      expect(find.text('Změnit'), findsOneWidget);
    });

    testWidgets('should validate title field when participant is selected', (WidgetTester tester) async {
      if (testParticipants.isNotEmpty) {
        final participant = testParticipants.first;
        
        await tester.pumpWidget(
          MaterialApp(
            home: NewRecordPage(participant: participant),
          ),
        );
        await tester.pumpAndSettle();

        // Try to save without entering title
        final saveButton = find.text('Uložit do deníku');
        await tester.tap(saveButton);
        await tester.pumpAndSettle();

        // Should show validation error
        expect(find.text('Prosím zadejte nadpis'), findsOneWidget);
      }
    });

    testWidgets('should show warning when no participant is selected and trying to save', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const NewRecordPage(),
        ),
      );
      await tester.pumpAndSettle();

      // Try to save without selecting participant
      final saveButton = find.text('Uložit do deníku');
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Should show participant selection warning
      expect(find.text('Nejprve vyberte účastníka'), findsWidgets);
    });
  });
}
