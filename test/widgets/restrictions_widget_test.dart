import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:denik_zza/screens2/widgets/restrictions_widget.dart';
import 'package:denik_zza/screens2/widgets/memory_restriction_widget.dart';
import 'package:denik_zza/database/database_wrapper.dart';
import 'package:denik_zza/database/drift_database/database.dart';
import '../utils/base_test_widget.dart';

/// Tests for RestrictionsWidget behavior:
/// - Add button functionality
/// - Enter key to add items
/// - Dropdown suggestions
/// - Custom entries allowed
/// - Duplicate prevention
void main() {
  late AppDatabase database;
  late MemoryOmezeniLogic omezeniLogic;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() async {
    DatabaseWrapper.setTestMode();
    database = AppDatabase.testInMemory();
    DatabaseWrapper.useTestDriftDatabase(database);
    omezeniLogic = MemoryOmezeniLogic();
    await omezeniLogic.fetchData();
  });

  tearDown(() async {
    await database.close();
  });

  group('RestrictionsWidget Add Item', () {
    testWidgets('typing text + Enter adds item to list', (tester) async {
      await tester.pumpWidget(
        BaseTestWidget(
          child: RestrictionsWidget(logic: omezeniLogic),
        ),
      );
      await tester.pumpAndSettle();

      // Find the input field
      final inputFinder =
          find.byKey(const Key('RestrictionsWidget_Omezení a alergie_input'));
      expect(inputFinder, findsOneWidget);

      // Type text and submit
      await tester.enterText(inputFinder, 'Alergie na ořechy');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Verify item appears in the list by checking logic
      // (find.text would match both input field and list item)
      expect(omezeniLogic.items, contains('Alergie na ořechy'));
      expect(omezeniLogic.items.length, 1);
    });

    testWidgets('duplicate entry is prevented', (tester) async {
      await tester.pumpWidget(
        BaseTestWidget(
          child: RestrictionsWidget(logic: omezeniLogic),
        ),
      );
      await tester.pumpAndSettle();

      final inputFinder =
          find.byKey(const Key('RestrictionsWidget_Omezení a alergie_input'));

      // Add first item
      await tester.enterText(inputFinder, 'Diabetes');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Try to add same item again
      await tester.enterText(inputFinder, 'Diabetes');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Should only appear once in logic
      expect(omezeniLogic.items.where((item) => item == 'Diabetes').length, 1);
    });

    testWidgets('empty text not added', (tester) async {
      await tester.pumpWidget(
        BaseTestWidget(
          child: RestrictionsWidget(logic: omezeniLogic),
        ),
      );
      await tester.pumpAndSettle();

      final inputFinder =
          find.byKey(const Key('RestrictionsWidget_Omezení a alergie_input'));

      // Enter empty/whitespace
      await tester.enterText(inputFinder, '   ');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Nothing should be added
      expect(omezeniLogic.items, isEmpty);
    });
  });

  group('MemoryLekLogic (Medications)', () {
    late MemoryLekLogic lekLogic;

    setUp(() async {
      lekLogic = MemoryLekLogic();
      await lekLogic.fetchData();
    });

    testWidgets('medication widget allows adding medications', (tester) async {
      await tester.pumpWidget(
        BaseTestWidget(
          child: RestrictionsWidget(logic: lekLogic),
        ),
      );
      await tester.pumpAndSettle();

      final inputFinder =
          find.byKey(const Key('RestrictionsWidget_Léky_input'));
      expect(inputFinder, findsOneWidget);

      await tester.enterText(inputFinder, 'Ibuprofen');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(lekLogic.items, contains('Ibuprofen'));
    });
  });
}
