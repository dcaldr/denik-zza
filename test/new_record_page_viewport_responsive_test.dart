import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';

import 'package:denik_zza/database/database_wrapper.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import 'package:denik_zza/screens2/new_record/new_record_page.dart';
import 'package:denik_zza/utils/app_logger.dart';

import 'setup_templates/hardcoded_setup.dart';

void main() {
  group('NewRecordPage responsive viewport tests', () {
    late List<MemoryOsoba> participants;

    setUp(() async {
      AppLogger.configureForTests(level: Level.error);
      await HardcodedTestSetup.setupTestData();
      final db = DatabaseWrapper.getDatabase();
      participants = await db.getParticipantsByCurrentEvent();
    });

    Future<void> pumpWithSize(
      WidgetTester tester,
      Size size, {
      MemoryOsoba? participant,
    }) async {
      await tester.binding.setSurfaceSize(size);
      await tester.pumpWidget(
        MaterialApp(
          home: NewRecordPage(participant: participant),
        ),
      );
      await tester.pumpAndSettle();
    }

    Future<void> resetSurface(WidgetTester tester) async {
      await tester.binding.setSurfaceSize(null);
    }

    testWidgets('renders on narrow phone size', (tester) async {
      await pumpWithSize(
        tester,
        const Size(360, 640),
        participant: participants.isNotEmpty ? participants.first : null,
      );

      expect(find.text('Nový záznam úrazu'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await resetSurface(tester);
    });

    testWidgets('renders on short height window', (tester) async {
      await pumpWithSize(
        tester,
        const Size(900, 520),
        participant: participants.isNotEmpty ? participants.first : null,
      );

      expect(find.text('Nový záznam úrazu'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await resetSurface(tester);
    });

    testWidgets('renders on wide tablet size', (tester) async {
      await pumpWithSize(
        tester,
        const Size(1100, 800),
        participant: participants.isNotEmpty ? participants.first : null,
      );

      expect(find.text('Nový záznam úrazu'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await resetSurface(tester);
    });
  });
}
