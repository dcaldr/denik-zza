import 'package:flutter_test/flutter_test.dart';
import 'base_robot.dart';

/// Robot for interacting with [NewRecordPage].
///
/// This robot provides methods to:
/// - Select participants via autocomplete
/// - Fill record title and description
/// - Save/cancel records
/// - Navigate to print flows
///
/// ## Keys Used (from `new_record_page.dart`):
/// - `NewRecordPage_participantAutocomplete`
/// - `NewRecordPage_title_input`
/// - `NewRecordPage_description_input`
/// - `NewRecordPage_poznamka_input`
/// - `NewRecordPage_save_button`
/// - `NewRecordPage_cancel_button`
/// - `NewRecordPage_print_full_button`
/// - `NewRecordPage_print_append_button`
/// - `NewRecordPage_health_info_toggle`
/// - `NewRecordPage_zpusobilost_button`
class NewRecordRobot extends BaseRobot {
  NewRecordRobot(super.tester);

  // Form inputs
  Finder get participantAutocomplete =>
      findKey('NewRecordPage_participantAutocomplete');
  Finder get titleInput => findKey('NewRecordPage_title_input');
  Finder get descriptionInput => findKey('NewRecordPage_description_input');
  Finder get poznamkaInput => findKey('NewRecordPage_poznamka_input');

  // Actions
  Finder get saveButton => findKey('NewRecordPage_save_button');
  Finder get cancelButton => findKey('NewRecordPage_cancel_button');

  // Print buttons
  Finder get printFullButton => findKey('NewRecordPage_print_full_button');
  Finder get printAppendButton => findKey('NewRecordPage_print_append_button');

  // Health info
  Finder get healthInfoToggle => findKey('NewRecordPage_health_info_toggle');
  Finder get zpusobilostButton => findKey('NewRecordPage_zpusobilost_button');

  /// Verifies the page is shown with key form elements.
  Future<void> verifyPageShown() async {
    await pumpAndSettle();
    expect(participantAutocomplete, findsOneWidget);
    expect(titleInput, findsOneWidget);
    expect(descriptionInput, findsOneWidget);
    expect(saveButton, findsOneWidget);
  }

  /// Enters text into the title field.
  Future<void> enterTitle(String title) async {
    await enterText(titleInput, title);
  }

  /// Enters text into the description field.
  Future<void> enterDescription(String description) async {
    await enterText(descriptionInput, description);
  }

  /// Enters text into the poznámka (note) field.
  Future<void> enterNote(String note) async {
    await enterText(poznamkaInput, note);
  }

  /// Taps the save button.
  Future<void> tapSave() async {
    await tap(saveButton);
  }

  /// Taps the cancel button.
  Future<void> tapCancel() async {
    await tap(cancelButton);
  }

  /// Taps the full print button.
  Future<void> tapPrintFull() async {
    await tap(printFullButton);
  }

  /// Taps the append print button.
  Future<void> tapPrintAppend() async {
    await tap(printAppendButton);
  }
}
