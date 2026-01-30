import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:denik_zza/screens2/participant_detail.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import '../utils/base_test_widget.dart';
import '../../integration_test/infrastructure/robots/participant_detail_robot.dart';
import '../setup_templates/hardcoded_setup.dart';
import 'package:denik_zza/database/database_wrapper.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() {
    // Mode handled by flutter_test_config.dart
  });

  Future<MemoryOsoba> loadTestParticipant() async {
    await HardcodedTestSetup.setupTestData();
    final db = DatabaseWrapper.getDatabase();
    final participants = await db.getParticipantsByCurrentEvent();
    return participants.first;
  }

  group('ParticipantDetailRobot', () {
    testWidgets('finds edit button in AppBar', (tester) async {
      final participant = await loadTestParticipant();
      await tester.pumpWidget(
        BaseTestWidget(
          child: ParticipantDetailPage(participant: participant),
        ),
      );
      await tester.pumpAndSettle();

      final robot = ParticipantDetailRobot(tester);

      // Edit button is always visible in AppBar
      expect(robot.editButton, findsOneWidget);
    });

    testWidgets('displays participant name in AppBar', (tester) async {
      final participant = await loadTestParticipant();
      await tester.pumpWidget(
        BaseTestWidget(
          child: ParticipantDetailPage(participant: participant),
        ),
      );
      await tester.pumpAndSettle();

      // Verify participant name is shown in AppBar
      expect(
        find.text('${participant.jmeno} ${participant.prijmeni}'),
        findsOneWidget,
      );
    });

    testWidgets('finds action buttons after scrolling', (tester) async {
      final participant = await loadTestParticipant();
      await tester.pumpWidget(
        BaseTestWidget(
          child: ParticipantDetailPage(participant: participant),
        ),
      );
      await tester.pumpAndSettle();

      // Scroll to bottom to reveal action buttons
      final listFinder = find.byType(ListView).first;
      await tester.drag(listFinder, const Offset(0, -300));
      await tester.pumpAndSettle();

      final robot = ParticipantDetailRobot(tester);
      expect(robot.newRecordButton, findsOneWidget);
      expect(robot.printButton, findsOneWidget);
    });
  });
}
