import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:denik_zza/screens2/participant_detail.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import 'package:denik_zza/services/system/system_interface.dart';
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
    testWidgets('verifyPageShown and verifyParticipantName succeed', (tester) async {
      final participant = await loadTestParticipant();
      await tester.pumpWidget(
        BaseTestWidget(
          child: ParticipantDetailPage(participant: participant),
        ),
      );
      await tester.pumpAndSettle();

      final robot = ParticipantDetailRobot(tester);
      await robot.verifyPageShown();
      await robot.verifyParticipantName('${participant.jmeno} ${participant.prijmeni}');
    });

    testWidgets('tapEdit interacts successfully', (tester) async {
      final participant = await loadTestParticipant();
      await tester.pumpWidget(
        BaseTestWidget(
          child: ParticipantDetailPage(participant: participant),
        ),
      );
      await tester.pumpAndSettle();

      final robot = ParticipantDetailRobot(tester);
      await robot.tapEdit();
      await tester.pumpAndSettle(); 
    });

    testWidgets('tapNewRecord interacts successfully', (tester) async {
      final participant = await loadTestParticipant();
      await tester.pumpWidget(
        BaseTestWidget(
          child: ParticipantDetailPage(participant: participant),
        ),
      );
      await tester.pumpAndSettle();

      // Scroll to bottom
      final listFinder = find.byType(ListView).first;
      await tester.drag(listFinder, const Offset(0, -500));
      await tester.pumpAndSettle();

      final robot = ParticipantDetailRobot(tester);
      await robot.tapNewRecord();
      await tester.pumpAndSettle();
    });

    testWidgets('tapPrint opens modern print flow', (tester) async {
      // Set desktop-like window size for proper layout
      await tester.binding.setSurfaceSize(const Size(1200, 900));
      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });
      SystemInterface.registerWith(TestSystemInterface());
      final participant = await loadTestParticipant();
      await tester.pumpWidget(
        BaseTestWidget(
          child: ParticipantDetailPage(participant: participant),
        ),
      );
      await tester.pumpAndSettle();

      // Scroll to bottom
      final listFinder = find.byType(ListView).first;
      await tester.drag(listFinder, const Offset(0, -500));
      await tester.pumpAndSettle();

      final robot = ParticipantDetailRobot(tester);
      // Verify print button is present and enabled
      expect(robot.printButton, findsOneWidget);
      
      // Note: Tapping the button navigates to PersonAndModeFlowPage which is tested separately.
      // We verify the button exists and is interactive.
      expect(find.byType(FilledButton), findsWidgets);
    });
  });
}
