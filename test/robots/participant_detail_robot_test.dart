import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:denik_zza/screens2/participant_detail.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import 'package:denik_zza/database/database_wrapper.dart';
import 'package:denik_zza/utils/mode_coordinator.dart';
import '../utils/base_test_widget.dart';
import '../../integration_test/infrastructure/robots/participant_detail_robot.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() {
    ModeCoordinator.setTestingMode();
    DatabaseWrapper.setTestMode();
  });

  /// Creates a test participant for widget tests.
  MemoryOsoba createTestParticipant() {
    return MemoryOsoba.named(
      id: 1,
      jmeno: 'Karel',
      prijmeni: 'Čapek',
      datumNarozeni: DateTime(2010, 1, 15),
      adresa: 'Praha 1',
      zpusobilost: true,
      bezinfekcnost: true,
      wasPrinted: false,
    );
  }

  group('ParticipantDetailRobot', () {
    testWidgets('finds edit button in AppBar', (tester) async {
      await tester.pumpWidget(
        BaseTestWidget(
          child: ParticipantDetailPage(participant: createTestParticipant()),
        ),
      );
      await tester.pumpAndSettle();

      final robot = ParticipantDetailRobot(tester);

      // Edit button is always visible in AppBar
      expect(robot.editButton, findsOneWidget);
    });

    testWidgets('displays participant name in AppBar', (tester) async {
      await tester.pumpWidget(
        BaseTestWidget(
          child: ParticipantDetailPage(participant: createTestParticipant()),
        ),
      );
      await tester.pumpAndSettle();

      // Verify participant name is shown in AppBar
      expect(find.text('Karel Čapek'), findsOneWidget);
    });

    testWidgets('finds action buttons after scrolling', (tester) async {
      await tester.pumpWidget(
        BaseTestWidget(
          child: ParticipantDetailPage(participant: createTestParticipant()),
        ),
      );
      await tester.pumpAndSettle();

      // Scroll to bottom to reveal action buttons
      await tester.scrollUntilVisible(
        find.byKey(const Key('ParticipantDetail_newRecord_button')),
        100.0,
      );
      await tester.pumpAndSettle();

      final robot = ParticipantDetailRobot(tester);
      expect(robot.newRecordButton, findsOneWidget);
      expect(robot.printButton, findsOneWidget);
    });
  });
}
