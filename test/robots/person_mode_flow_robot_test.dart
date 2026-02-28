import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:denik_zza/print_ops2/print_center.dart';
import 'package:denik_zza/services/system/system_interface.dart';
import '../utils/base_test_widget.dart';
import '../setup_templates/hardcoded_setup.dart';
import '../../integration_test/infrastructure/robots/print_center_robot.dart';
import '../../integration_test/infrastructure/robots/person_mode_flow_robot.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('PersonModeFlowRobot', () {
    testWidgets('finds key elements and actions', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 900));
      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });
      SystemInterface.registerWith(TestSystemInterface());
      await HardcodedTestSetup.setupTestData();
      await tester.pumpWidget(
        const BaseTestWidget(
          child: PrintCenterPage(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      final centerRobot = PrintCenterRobot(tester);
      await centerRobot.tapPersonModeCard();

      final robot = PersonModeFlowRobot(tester);
      await robot.verifyPageShown();
      await robot.selectParticipant('Karel Čapek');
      await robot.selectFullPrintMode();
      await robot.tapPrintButton();
      await robot.verifyPdfPreviewShown();
      await robot.confirmPrintSuccess();
    });
  });
}
