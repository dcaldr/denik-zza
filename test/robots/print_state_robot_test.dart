import 'package:flutter_test/flutter_test.dart';
import 'package:denik_zza/database/database_wrapper.dart';
import 'package:denik_zza/print_ops2/print_center_service.dart';
import 'package:denik_zza/print_ops2/print_state_controller.dart';
import 'package:denik_zza/print_ops2/print_state_management_page.dart';
import '../utils/base_test_widget.dart';
import '../setup_templates/hardcoded_setup.dart';
import '../../integration_test/infrastructure/robots/print_state_robot.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('PrintStateRobot', () {
    testWidgets('finds key elements and actions', (tester) async {
      await HardcodedTestSetup.setupTestData();
      final db = DatabaseWrapper.getDatabase();
      final participants = await db.getParticipantsByCurrentEvent();
      final karel = participants.firstWhere(
        (p) => p.jmeno == 'Karel' && p.prijmeni == 'Čapek',
      );
      final controller = PrintStateController(PrintCenterService());
      await tester.pumpWidget(
        BaseTestWidget(
          child: PrintStateManagementPage(controller: controller),
        ),
      );
      await tester.pumpAndSettle();

      final robot = PrintStateRobot(tester);
      await robot.verifyPageShown();
      await robot.expandPerson('Karel Čapek');
      await robot.verifyPersonPrintedBadge('Karel Čapek', false);
      await robot.verifyRecordPrintedBadge(0, false);
      await robot.toggleRecordPrinted(0);
      await robot.tapMarkAll(karel.id);
      await robot.tapResetAll(karel.id);
      await robot.tapRefresh();
    });
  });
}
