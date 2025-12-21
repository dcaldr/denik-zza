import 'package:flutter_test/flutter_test.dart';
import 'package:denik_zza/screens2/new_record_page.dart';
import 'package:denik_zza/database/database_wrapper.dart';
import 'package:denik_zza/utils/mode_coordinator.dart';
import '../utils/base_test_widget.dart';
import '../../integration_test/infrastructure/robots/new_record_robot.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() {
    ModeCoordinator.setTestingMode();
    DatabaseWrapper.setTestMode();
  });

  group('NewRecordRobot', () {
    testWidgets('finds key form elements on NewRecordPage', (tester) async {
      await tester.pumpWidget(
        const BaseTestWidget(
          child: NewRecordPage(),
        ),
      );
      await tester.pumpAndSettle();

      final robot = NewRecordRobot(tester);

      // Verify key elements are found
      expect(robot.participantAutocomplete, findsOneWidget);
      expect(robot.titleInput, findsOneWidget);
      expect(robot.descriptionInput, findsOneWidget);
      expect(robot.saveButton, findsOneWidget);
    });

    testWidgets('finds action buttons', (tester) async {
      await tester.pumpWidget(
        const BaseTestWidget(
          child: NewRecordPage(),
        ),
      );
      await tester.pumpAndSettle();

      final robot = NewRecordRobot(tester);

      // Verify action buttons exist
      expect(robot.saveButton, findsOneWidget);
      expect(robot.cancelButton, findsOneWidget);
    });

    testWidgets('verifyPageShown method works', (tester) async {
      await tester.pumpWidget(
        const BaseTestWidget(
          child: NewRecordPage(),
        ),
      );
      await tester.pumpAndSettle();

      final robot = NewRecordRobot(tester);

      // This should not throw
      await robot.verifyPageShown();
    });
  });
}
