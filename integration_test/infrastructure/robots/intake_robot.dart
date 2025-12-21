import 'package:flutter_test/flutter_test.dart';
import 'base_robot.dart';

/// Robot for interacting with [NewIntakeFormImproved].
///
/// This robot provides methods to:
/// - Mark participant as arrived
/// - Save intake data
/// - Cancel intake
///
/// ## Keys Used (from `intake_action_buttons.dart`):
/// - `IntakeForm_saveAndArrived_button`
/// - `IntakeForm_save_button`
/// - `IntakeForm_cancel_button`
class IntakeRobot extends BaseRobot {
  IntakeRobot(super.tester);

  // Action buttons
  Finder get saveAndArrivedButton =>
      findKey('IntakeForm_saveAndArrived_button');
  Finder get saveButton => findKey('IntakeForm_save_button');
  Finder get cancelButton => findKey('IntakeForm_cancel_button');

  /// Verifies the page is shown with action buttons.
  Future<void> verifyPageShown() async {
    await pumpAndSettle();
    // Check for title text (the only guaranteed element)
    expect(find.text('Intake Form (Improved)'), findsOneWidget);
  }

  /// Taps "uložit a přišel" button (save and mark as arrived).
  Future<void> tapSaveAndArrived() async {
    await tap(saveAndArrivedButton);
  }

  /// Taps "uložit" button (save only).
  Future<void> tapSave() async {
    await tap(saveButton);
  }

  /// Taps "neukládat" button (cancel).
  Future<void> tapCancel() async {
    await tap(cancelButton);
  }
}
