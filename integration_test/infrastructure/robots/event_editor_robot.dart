import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'base_robot.dart';

class EventEditorRobot extends BaseRobot {
  EventEditorRobot(super.tester);

  Finder get nameInput => findKey('EventRegistrationForm_name_input');
  Finder get odkdyInput => findKey('EventRegistrationForm_odkdy_input');
  Finder get dokdyInput => findKey('EventRegistrationForm_dokdy_input');
  Finder get submitButton => findKey('EventRegistrationForm_submit_button');

  Future<void> enterEventName(String name) async {
    await enterText(nameInput, name);
    await tester.pumpAndSettle();
  }

  Future<void> enterDates(DateTime odkdy, DateTime dokdy) async {
    // 1. Strings for dates (formatted as the inputs likely expect, or use DatePicker)
    // The form uses ActionDateInput which might be read-only text field triggering a dialog.
    // Let's assume we tap them and use the internal DatePicker logic, OR if they are text fields, type it.
    // Looking at common flutter patterns:
    // If it's a date picker, we tap the field, find the 'OK' or 'Save' on the dialog.

    // For now, let's try tapping and selecting 'OK' (simplest default).
    // Or if the form allows direct text entry (less likely for DatePicker).

    // Strategy: Tap field -> wait for dialog -> tap 'OK' (which picks today).
    // If we need specific dates, we need to scroll the picker. This is complex.
    // ALTERNATIVE: Use `tester.widget<TextFormField>(finder).controller.text = ...`?
    // Fragile.

    // Let's look at EventRegistrationForm setup again.
    // It calls `_openDatePicker`.
    // We can interact with the dialog.

    // Simplifying for "Step 2": Just accept default dates (Today) if possible?
    // Tap From -> OK. Tap To -> OK.

    await tap(odkdyInput);
    await tester.pumpAndSettle();
    await confirmDatePicker();

    await tap(dokdyInput);
    await tester.pumpAndSettle();
    await confirmDatePicker();
  }

  Future<void> submit() async {
    await tap(submitButton);
    await tester.pumpAndSettle();
  }
}
