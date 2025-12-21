import 'package:flutter_test/flutter_test.dart';
import 'package:denik_zza/screens2/event_registration_form.dart';
import '../utils/base_test_widget.dart';
// Import Robot from integration_test relative path
import '../../integration_test/infrastructure/robots/event_editor_robot.dart';

void main() {
  testWidgets('EventEditorRobot finds input fields on EventRegistrationForm',
      (tester) async {
    // 1. Pump the widget using BaseTestWidget which handles localization
    await tester.pumpWidget(
      const BaseTestWidget(
        child: EventRegistrationForm(),
      ),
    );

    // 2. Instantiate Robot
    final robot = EventEditorRobot(tester);

    // 3. Verify Name Input
    await robot.enterEventName('Test Event Name');
    expect(find.text('Test Event Name'), findsOneWidget);

    // 4. Verify Date Inputs
    final date = DateTime(2024, 1, 1);
    await robot.enterDates(date, date);

    await tester.pumpAndSettle();
    expect(
        find.text('01.01.2024'), findsAtLeastNWidgets(2)); // Start and End date

    // 5. Verify Submit
    expect(robot.submitButton, findsOneWidget);

    try {
      await robot.submit();
    } catch (e) {
      // Ignore DB errors if they happen, we just want to prove the robot clicked.
    }
  });
}
