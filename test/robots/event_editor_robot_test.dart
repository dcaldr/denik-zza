import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:denik_zza/screens2/event_registration_form.dart';
// Import Robot from integration_test relative path
import '../../integration_test/infrastructure/robots/event_editor_robot.dart';

void main() {
  testWidgets('EventEditorRobot finds input fields on EventRegistrationForm',
      (tester) async {
    // 1. Pump the widget
    await tester.pumpWidget(
      const MaterialApp(
        home: EventRegistrationForm(),
        localizationsDelegates: [
          DefaultMaterialLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
        ],
      ),
    );

    // 2. Instantiate Robot
    final robot = EventEditorRobot(tester);

    // 3. Verify Name Input
    // This is the "Verification" - does the robot find the widget?
    // We try to enter text. If key is wrong, this throws a StateError.
    await robot.enterEventName('Test Event Name');

    // Verify text was actually entered (redundant if enterText passed, but good practice)
    expect(find.text('Test Event Name'), findsOneWidget);

    // 4. Verify Date Inputs (just visibility)
    // We don't interact fully to avoid dialogs in this basic check,
    // but the robot uses confirmDatePicker now.
    // Let's just check the finders exist.
    expect(robot.odkdyInput, findsOneWidget);
    expect(robot.dokdyInput, findsOneWidget);
    expect(robot.submitButton, findsOneWidget);
  });
}
