import 'package:flutter_test/flutter_test.dart';
import 'base_robot.dart';

// Import test data models for createRecordFromTestData
import '../data/models/test_record.dart';

/// Robot for interacting with [NewRecordPage].
///
/// This robot provides methods to:
/// - Select participants via autocomplete
/// - Fill record title and description
/// - Save/cancel records
/// - Navigate to print flows
/// - Create records from TestRecord data (E2E helper)
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

  /// Selects a participant by name via autocomplete.
  ///
  /// Calls the unified BaseRobot method to handle typing, dropdown polling,
  /// and tapping the matching suggestion.
  ///
  /// [fullName] should be in format "Jméno Příjmení" (e.g., "Karel Čapek")
  Future<void> selectParticipant(String fullName) async {
    await selectAutocompleteItem(participantAutocomplete, fullName);
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
  /// Uses settle: false to prevent 4-second hangs on the success SnackBar
  /// during slow mode, and to maintain consistency in fast mode.
  Future<void> tapSave() async {
    await humanObservationDelay();
    await tap(saveButton, settle: false);
    incrementRound();
  }

  /// Taps the cancel button.
  Future<void> tapCancel() async {
    await tap(cancelButton, settle: false);
  }

  /// Taps the full print button.
  Future<void> tapPrintFull() async {
    await tap(printFullButton);
  }

  /// Taps the append print button.
  Future<void> tapPrintAppend() async {
    await tap(printAppendButton);
  }

  /// Creates a medical record for a participant using TestRecord data.
  ///
  /// Convenience method that:
  /// 1. Selects participant by name
  /// 2. Fills title and description from TestRecord
  /// 3. Saves the record
  ///
  /// Example:
  /// ```dart
  /// await robot.createRecordFromTestData(
  ///   'Karel Čapek',
  ///   TestRecord(nazev: 'Bolest hlavy', popis: 'Podán Ibalgin'),
  /// );
  /// ```
  Future<void> createRecordFromTestData(
    String participantFullName,
    TestRecord record,
  ) async {
    await selectParticipant(participantFullName);
    await enterTitle(record.nazev);
    await enterDescription(record.popis);

    if (record.poznamka != null) {
      await enterNote(record.poznamka!);
    }

    await tapSave();
  }

  /// Waits for form to be ready for input after submit/cancel.
  ///
  /// Strictly waits for the Title field to be completely cleared.
  /// Note: We do not wait for the Autocomplete field to clear because
  /// NewRecordPage intentionally preserves the selected participant
  /// after saving to allow entering multiple records rapidly.
  Future<bool> waitForFormReady({
    Duration timeout = const Duration(seconds: 5),
  }) async {
    return await waitForFieldToClear(
      titleInput,
      timeout: timeout,
    );
  }
}
