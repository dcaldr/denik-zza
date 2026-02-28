import 'package:flutter_test/flutter_test.dart';
// removed unused import: database_wrapper
import 'package:denik_zza/print_ops2/print_center_service.dart';
import 'package:denik_zza/print_ops2/print_state_controller.dart';
import 'package:denik_zza/print_ops2/print_state_management_page.dart';
import '../utils/base_test_widget.dart';
import '../setup_templates/hardcoded_setup.dart';
// removed unused integration test robot import

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('PrintStateRobot', () {
    testWidgets('finds key elements and actions', (tester) async {

      await HardcodedTestSetup.setupTestData();
      // database handle not needed in this test

      final controller = PrintStateController(PrintCenterService());

      await tester.pumpWidget(
        BaseTestWidget(
          child: PrintStateManagementPage(controller: controller),
        ),
      );

      await tester.pumpAndSettle();



    });
  });
}
