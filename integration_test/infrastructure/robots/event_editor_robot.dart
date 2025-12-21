import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'base_robot.dart';

class EventEditorRobot extends BaseRobot {
  EventEditorRobot(super.tester);

  Finder get nameInput => findKey('EventRegistrationForm_nadpis_input');
  Finder get odkdyInput => findKey('EventRegistrationForm_odkdy_input');
  Finder get dokdyInput => findKey('EventRegistrationForm_dokdy_input');
  Finder get submitButton => findKey('EventRegistrationForm_submit_button');

  Future<void> enterEventName(String name) async {
    await enterText(nameInput, name);
    await tester.pumpAndSettle();
  }

  Future<void> enterDates(DateTime odkdy, DateTime dokdy) async {
    // CustomDatePicker allows manual entry and finding the widget finds its descendant EditableText.
    // Tapping the field does NOT open the dialog (only the icon does), so enterText is safer/faster.
    final start =
        '${odkdy.day.toString().padLeft(2, '0')}.${odkdy.month.toString().padLeft(2, '0')}.${odkdy.year}';
    final end =
        '${dokdy.day.toString().padLeft(2, '0')}.${dokdy.month.toString().padLeft(2, '0')}.${dokdy.year}';

    await enterText(odkdyInput, start);
    await enterText(dokdyInput, end);
  }

  Future<void> submit() async {
    await tap(submitButton);
    await tester.pumpAndSettle();
  }
}
