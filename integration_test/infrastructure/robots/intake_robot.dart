import 'package:flutter/material.dart';
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
/// - `IntakeBottomRow_save_button`
/// - `IntakeForm_cancel_button`
class IntakeRobot extends BaseRobot {
  IntakeRobot(super.tester);

  // Action buttons
  Finder get saveAndArrivedButton =>
      findKey('IntakeForm_saveAndArrived_button');
  Finder get saveButton => findKey('IntakeBottomRow_save_button');
  Finder get cancelButton => findKey('IntakeForm_cancel_button');

  /// Verifies the page is shown with action buttons.
  Future<void> verifyPageShown() async {
    await pumpAndSettle();
    // Check for title text (the only guaranteed element)
    expect(find.text('Intake Form (Improved)'), findsOneWidget);
  }

  /// Taps "uložit a přišel" button (save and mark as arrived).
  ///
  /// Uses settle:false because save triggers a CenterToast animation
  /// (~1.2s) that blocks pumpAndSettle unnecessarily. Callers must
  /// follow with waitForKey() for synchronization.
  Future<void> tapSaveAndArrived() async {
    await tap(saveAndArrivedButton, settle: false);
  }

  /// Taps "uložit" button (save only).
  ///
  /// Uses settle:false — same rationale as [tapSaveAndArrived].
  Future<void> tapSave() async {
    await tap(saveButton, settle: false);
  }

  /// Taps "neukládat" button (cancel).
  ///
  /// Uses settle:false — cancel resets the form which callers
  /// synchronize via waitForKey.
  Future<void> tapCancel() async {
    await tap(cancelButton, settle: false);
  }

  // Person search - find by hint text 'Vyhledat osobu'
  Finder get personSearchInput => find.widgetWithText(TextField, 'Vyhledat osobu');

  /// Selects a participant from autocomplete by name.
  ///
  /// Types the first name to trigger dropdown, waits for suggestion to appear,
  /// then taps the full name suggestion.
  /// [fullName] should be in format "Jméno Příjmení" (e.g., "Karel Čapek")
  Future<void> selectParticipant(String fullName) async {
    // Wait for search field to be ready (spinner gone, field visible).
    final searchReady = await waitForKey(
      'IntakeForm_personSearch_input',
      timeout: const Duration(seconds: 5),
    );
    if (!searchReady) {
      throw StateError('IntakeRobot: Search field not found within timeout');
    }

    // Extract first name + first char of surname for unique matching
    final parts = fullName.split(' ');
    final firstName = parts.first;
    final searchQuery = parts.length > 1
        ? '$firstName ${parts[1][0]}'  // e.g., "Jan H"
        : firstName;

    // Tap and type into the search field
    final searchField = personSearchInput;
    await tap(searchField, settle: false);
    await tester.enterText(searchField, searchQuery);

    // Wait for dropdown suggestion — event-based, not fixed delay.
    var dropdownFound = await waitForAnyText(
      fullName,
      timeout: const Duration(seconds: 3),
      pollInterval: const Duration(milliseconds: 50),
    );

    // Retry once: cancel/reset can refresh availablePersons asynchronously.
    // Re-focus with empty query (shows all options when data is ready), then retry.
    if (!dropdownFound) {
      await tester.enterText(searchField, '');
      await pump(const Duration(milliseconds: 50));
      dropdownFound = await waitForAnyText(
        fullName,
        timeout: const Duration(seconds: 5),
        pollInterval: const Duration(milliseconds: 50),
      );
    }

    if (!dropdownFound) {
      throw StateError('IntakeRobot: No dropdown suggestion found for "$fullName"');
    }

    // Tap the suggestion (use .last to get dropdown, not any input echo).
    await tester.tap(find.text(fullName).last);

    // Wait for form to populate with selected person's data (event-based).
    final lastName = parts.length > 1 ? parts.last : firstName;
    await waitForText(
      lastName,
      timeout: const Duration(seconds: 3),
      pollInterval: const Duration(milliseconds: 50),
    );
  }

  /// Modifies the note (poznámka) field.
  ///
  /// Used for testing note modification during intake.
  Future<void> modifyNote(String note) async {
    await enterText(findKey('ParticipantRegistrationForm_poznamka_input'), note);
  }
}
