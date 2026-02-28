import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:denik_zza/screens2/widgets/record_list_widget.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import 'package:denik_zza/database/drift_database/database.dart';
import 'package:denik_zza/database/database_wrapper.dart';
import 'utils/database_test_helper.dart';

void main() {
  group('RecordListWidget Tests', () {
    late AppDatabase testDb;

    setUp(() async {
      // Mode handled by flutter_test_config.dart
      DatabaseTestHelper.disableDriftWarnings();
      testDb = AppDatabase.testInMemory();
      DatabaseWrapper.useTestDriftDatabase(testDb);
    });

    tearDown(() async {
    });

    Widget createTestWidget(MemoryOsoba participant) {
      return MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 300, // Limited height to trigger scrolling
            child: RecordListWidget(
              participant: participant,
            ),
          ),
        ),
      );
    }

    testWidgets('should display empty state when participant has no records',
        (WidgetTester tester) async {
      final participant = MemoryOsoba.basic('Jan', 'Novák')..id = 1;

      await tester.pumpWidget(createTestWidget(participant));
      await tester.pumpAndSettle();

      expect(find.text('Zatím žádné zdravotní záznamy.'), findsOneWidget,
          reason: 'Empty state message must be visible when no records exist');
    });

    testWidgets('should display loading indicator while fetching records',
        (WidgetTester tester) async {
      final participant = MemoryOsoba.basic('Jan', 'Novák')..id = 1;

      await tester.pumpWidget(createTestWidget(participant));

      // Before pumpAndSettle completes, loading indicator should be visible
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();
    });

    testWidgets('should render widget without crashing',
        (WidgetTester tester) async {
      final participant = MemoryOsoba.basic('Jan', 'Novák')..id = 1;

      await tester.pumpWidget(createTestWidget(participant));
      await tester.pumpAndSettle();

      // Basic smoke test
      expect(find.byType(RecordListWidget), findsOneWidget);
    });

    // Note: Comprehensive tests for record expansion, scroll indicator behavior,
    // and print status require seeded test data. These will be added when
    // test data helpers are available.
  });
}
