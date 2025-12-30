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

  // Person search - find by hint text 'Vyhledat osobu'
  Finder get personSearchInput => find.widgetWithText(TextField, 'Vyhledat osobu');

  /// Selects a participant from autocomplete by name.
  ///
  /// Types the first name to trigger dropdown, waits for suggestion to appear,
  /// then taps the full name suggestion.
  /// [fullName] should be in format "Jméno Příjmení" (e.g., "Karel Čapek")
  Future<void> selectParticipant(String fullName) async {
    // Wait for loading to complete (spinner disappears)
    // Use pump() not pumpAndSettle() because CircularProgressIndicator is infinite animation
    final loadingKey = findKey('IntakeForm_loading');
    for (int i = 0; i < 50; i++) {
      await pump(const Duration(milliseconds: 100));
      if (loadingKey.evaluate().isEmpty) break;
    }
    await pumpAndSettle();

    // Extract first name + first char of surname for unique matching
    // (avoids collision when multiple people share first name, e.g., "Jan Hus" vs "Jan Neruda")
    final parts = fullName.split(' ');
    final firstName = parts.first;
    final searchQuery = parts.length > 1 
        ? '$firstName ${parts[1][0]}'  // e.g., "Jan H" 
        : firstName;
    
    // Find and tap the search field (by hint text)
    await tap(personSearchInput);
    
    // Type search query to trigger suggestions (more unique than just first name)
    await tester.enterText(personSearchInput, searchQuery);
    
    // Wait for dropdown to appear with retries (increased for slow machines)
    Finder suggestion = find.text(fullName);
    for (int attempt = 0; attempt < 20; attempt++) {
      await pumpAndSettle();
      if (suggestion.evaluate().length > 1) {
        // Found at least 2 (input + dropdown), break
        break;
      }
      // Pump more frames to allow async to complete
      await pump();
    }
    
    // Tap the suggestion (use .last to get dropdown, not input)
    await tester.tap(suggestion.last);
    await pumpAndSettle();
    
    // Dismiss keyboard/dropdown by tapping elsewhere (the page title)
    try {
      await tester.tap(find.text('Intake Form (Improved)'));
      await pumpAndSettle();
    } catch (_) {
      // Title might not exist, that's ok
    }
  }

  /// Modifies the note (poznámka) field.
  ///
  /// Used for testing note modification during intake.
  Future<void> modifyNote(String note) async {
    await enterText(findKey('ParticipantRegistrationForm_poznamka_input'), note);
  }
}
