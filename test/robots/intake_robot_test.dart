import 'package:flutter_test/flutter_test.dart';
import 'package:denik_zza/screens2/intake_form_improved.dart';
import 'package:denik_zza/database/database_wrapper.dart';
import 'package:denik_zza/utils/mode_coordinator.dart';
import '../utils/base_test_widget.dart';
import '../../integration_test/infrastructure/robots/intake_robot.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() {
    ModeCoordinator.setTestingMode();
    DatabaseWrapper.setTestMode();
  });

  group('IntakeRobot', () {
    testWidgets('finds page title on NewIntakeFormImproved', (tester) async {
      await tester.pumpWidget(
        const BaseTestWidget(
          child: NewIntakeFormImproved(),
        ),
      );
      await tester.pumpAndSettle();

      final robot = IntakeRobot(tester);

      // Verify page title exists
      await robot.verifyPageShown();
    });

    testWidgets('finds action buttons on NewIntakeFormImproved',
        (tester) async {
      await tester.pumpWidget(
        const BaseTestWidget(
          child: NewIntakeFormImproved(),
        ),
      );
      await tester.pumpAndSettle();

      final robot = IntakeRobot(tester);

      // Verify action buttons exist
      expect(robot.saveAndArrivedButton, findsOneWidget);
      expect(robot.saveButton, findsOneWidget);
      expect(robot.cancelButton, findsOneWidget);
    });
  });
}
