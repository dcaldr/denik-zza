import 'package:flutter_test/flutter_test.dart';
import 'package:denik_zza/print_ops2/print_center.dart';
import '../utils/base_test_widget.dart';
import '../setup_templates/hardcoded_setup.dart';
import '../../integration_test/infrastructure/robots/print_center_robot.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('PrintCenterRobot', () {
    testWidgets('finds print center cards and title', (tester) async {

      await HardcodedTestSetup.setupTestData();

      await tester.pumpWidget(
        const BaseTestWidget(
          child: PrintCenterPage(),
        ),
      );

      await tester.pumpAndSettle();



      final robot = PrintCenterRobot(tester);

      
      await robot.waitForCardEnabled('PrintCenter_personMode');


      await robot.verifyPageShown();


      await robot.verifyCardEnabled('PrintCenter_personMode');
      await robot.verifyCardEnabled('PrintCenter_aggregated');
      await robot.verifyCardEnabled('PrintCenter_stateManagement');
      await robot.verifyCardEnabled('PrintCenter_firstPrint');

    });
  });
}
