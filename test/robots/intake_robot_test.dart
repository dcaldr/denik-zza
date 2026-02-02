import 'package:flutter_test/flutter_test.dart';
import 'package:denik_zza/screens2/intake_form_improved.dart';
import '../utils/base_test_widget.dart';
import '../../integration_test/infrastructure/robots/intake_robot.dart';
import '../setup_templates/hardcoded_setup.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() {
    // Mode handled by flutter_test_config.dart
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

    testWidgets('selectParticipant picks autocomplete suggestion',
        (tester) async {
      await HardcodedTestSetup.setupTestData();

      await tester.pumpWidget(
        const BaseTestWidget(
          child: NewIntakeFormImproved(),
        ),
      );
      await tester.pumpAndSettle();

      final robot = IntakeRobot(tester);
      await robot.selectParticipant('Karel Čapek');

      expect(find.text('Karel Čapek'), findsWidgets);
    });
  });
}
