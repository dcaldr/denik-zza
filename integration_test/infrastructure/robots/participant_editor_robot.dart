import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'base_robot.dart';

// Import test data models for fillFromTestData
import '../data/models/test_participant.dart';
import '../data/models/test_medication.dart';
import '../data/models/test_restriction.dart';

/// Robot for interacting with [ParticipantRegistrationForm].
///
/// This robot provides methods to:
/// - Fill participant registration form fields (all fields)
/// - Add medications and restrictions via RestrictionsWidget
/// - Submit the form
/// - Bulk fill from TestParticipant data
///
/// ## Keys Used (from `participant_registration_form.dart`):
/// - `ParticipantRegistrationForm_jmeno_input`
/// - `ParticipantRegistrationForm_prijmeni_input`
/// - `ParticipantRegistrationForm_cisloPojisteni_input`
/// - `ParticipantRegistrationForm_datumNarozeni_input`
/// - `ParticipantRegistrationForm_pohlavi_input`
/// - `ParticipantRegistrationForm_zdravotniPojistovna_input`
/// - `ParticipantRegistrationForm_adresa_input`
/// - `ParticipantRegistrationForm_jmenoRodice_input`
/// - `ParticipantRegistrationForm_emailRodice_input`
/// - `ParticipantRegistrationForm_telefonRodice_input`
/// - `ParticipantRegistrationForm_poznamka_input`
/// - `ParticipantRegistrationForm_submit_button`
///
/// ## RestrictionsWidget Keys (from `restrictions_widget.dart`):
/// - `RestrictionsWidget_Léky_input` - Medication autocomplete
/// - `RestrictionsWidget_Léky_add_button` - Add medication button
/// - `RestrictionsWidget_Omezení_input` - Restriction autocomplete
/// - `RestrictionsWidget_Omezení_add_button` - Add restriction button
class ParticipantEditorRobot extends BaseRobot {
  ParticipantEditorRobot(super.tester);

  // Name fields
  Finder get jmenoInput => findKey('ParticipantRegistrationForm_jmeno_input');
  Finder get prijmeniInput =>
      findKey('ParticipantRegistrationForm_prijmeni_input');

  // ID & Insurance
  Finder get cisloPojisteniInput =>
      findKey('ParticipantRegistrationForm_cisloPojisteni_input');
  Finder get datumNarozeniInput =>
      findKey('ParticipantRegistrationForm_datumNarozeni_input');
  Finder get pohlaviInput =>
      findKey('ParticipantRegistrationForm_pohlavi_input');
  Finder get zdravotniPojistovnaInput =>
      findKey('ParticipantRegistrationForm_zdravotniPojistovna_input');
  Finder get adresaInput => findKey('ParticipantRegistrationForm_adresa_input');

  // Parent contact
  Finder get jmenoRodiceInput =>
      findKey('ParticipantRegistrationForm_jmenoRodice_input');
  Finder get emailRodiceInput =>
      findKey('ParticipantRegistrationForm_emailRodice_input');
  Finder get telefonRodiceInput =>
      findKey('ParticipantRegistrationForm_telefonRodice_input');

  // Note
  Finder get poznamkaInput =>
      findKey('ParticipantRegistrationForm_poznamka_input');

  // Submit
  Finder get submitButton =>
      findKey('ParticipantRegistrationForm_submit_button');

  // RestrictionsWidget fields (added Phase 1)
  // NOTE: Keys match _logic.getText() - 'Léky' and 'Omezení a alergie'
  Finder get medicationInput => findKey('RestrictionsWidget_Léky_input');
  Finder get medicationAddButton =>
      findKey('RestrictionsWidget_Léky_add_button');
  Finder get restrictionInput =>
      findKey('RestrictionsWidget_Omezení a alergie_input');
  Finder get restrictionAddButton =>
      findKey('RestrictionsWidget_Omezení a alergie_add_button');

  // Reset button in AppBar (clears form)
  Finder get resetButton =>
      findKey('ParticipantRegistrationPage_refresh_button');

  /// Verifies the page is shown with key form elements.
  Future<void> verifyPageShown() async {
    await pumpAndSettle();
    expect(jmenoInput, findsOneWidget);
    expect(prijmeniInput, findsOneWidget);
    expect(submitButton, findsOneWidget);
  }

  /// Enters first name.
  Future<void> enterJmeno(String jmeno) async {
    await enterText(jmenoInput, jmeno);
  }

  /// Enters last name.
  Future<void> enterPrijmeni(String prijmeni) async {
    await enterText(prijmeniInput, prijmeni);
  }

  /// Enters national ID number (rodné číslo).
  Future<void> enterCisloPojisteni(String rc) async {
    await enterText(cisloPojisteniInput, rc);
  }

  /// Enters birth date in DD.MM.YYYY format.
  ///
  /// Uses the CustomDatePicker widget which accepts direct text entry.
  /// [date] will be formatted automatically to Czech date format.
  Future<void> enterDatumNarozeni(DateTime date) async {
    final formatted =
        '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
    await enterText(datumNarozeniInput, formatted);
  }

  /// Enters gender value.
  ///
  /// Gender field is a TEXT input (not dropdown).
  /// [pohlavi] should be 1 for male or 2 for female.
  /// [useFullWord] if true uses 'muž'/'žena', if false uses 'M'/'Ž'.
  /// Defaults to true to test full word input.
  Future<void> enterPohlavi(int pohlavi, {bool useFullWord = true}) async {
    // Gender field accepts: "M", "Ž", "muž", "žena"
    // Test coverage: use full words by default, can override to test abbreviations
    String text;
    if (useFullWord) {
      text = pohlavi == 1 ? 'muž' : 'žena';
    } else {
      text = pohlavi == 1 ? 'M' : 'Ž';
    }
    await enterText(pohlaviInput, text);
  }

  /// Enters health insurance company name.
  ///
  /// Insurance field is a TEXT input (not dropdown).
  Future<void> enterZdravotniPojistovna(String pojistovna) async {
    await enterText(zdravotniPojistovnaInput, pojistovna);
  }

  /// Enters address.
  Future<void> enterAdresa(String adresa) async {
    await enterText(adresaInput, adresa);
  }

  /// Enters parent phone number.
  Future<void> enterTelefonRodice(String telefon) async {
    await enterText(telefonRodiceInput, telefon);
  }

  /// Enters parent name (optional field).
  Future<void> enterJmenoRodice(String jmeno) async {
    await enterText(jmenoRodiceInput, jmeno);
  }

  /// Enters parent email (optional field).
  Future<void> enterEmailRodice(String email) async {
    await enterText(emailRodiceInput, email);
  }

  /// Enters note/poznámka (optional multiline field).
  Future<void> enterPoznamka(String poznamka) async {
    await enterText(poznamkaInput, poznamka);
  }

  /// Adds a medication via RestrictionsWidget.
  ///
  /// Requires widget keys added in Phase 1.
  /// Formats medication as "Název (dávkování, kdy)" if fields present.
  Future<void> addMedication(TestMedication medication) async {
    // Format: "Název léku" or "Název léku (dávkování, kdy)"
    String text = medication.nazev;
    final parts = <String>[];
    if (medication.davkovani != null) parts.add(medication.davkovani!);
    if (medication.kdy != null) parts.add(medication.kdy!);
    if (parts.isNotEmpty) {
      text = '$text (${parts.join(', ')})';
    }

    // Ensure input visible (may have scrolled due to responsive layout)
    await ensureVisible(medicationInput);

    // Tap to focus the input field first (critical for Autocomplete sync)
    await tap(medicationInput);
    await pump(const Duration(milliseconds: 100));

    // Enter text after focus is established
    await enterText(medicationInput, text);

    // Wait for Autocomplete internal controller to sync with entered text
    await pump(const Duration(milliseconds: 300));

    await ensureVisible(medicationAddButton);
    await tap(medicationAddButton);

    // Wait for add to complete and input to clear
    await pump(const Duration(milliseconds: 300));
  }

  /// Adds a restriction via RestrictionsWidget.
  ///
  /// Requires widget keys added in Phase 1.
  /// Uses the restriction's popis (description) field.
  ///
  /// Note: Uses tap-to-focus before entering text to ensure Autocomplete's
  /// internal controller syncs correctly with entered text.
  Future<void> addRestriction(TestRestriction restriction) async {
    // DEBUG: Trace restriction adding
    // ignore: avoid_print
    print('📝 addRestriction: Adding "${restriction.popis}"');

    // Ensure input visible (may have scrolled due to responsive layout)
    await ensureVisible(restrictionInput);

    // Tap to focus the input field first (critical for Autocomplete sync)
    await tap(restrictionInput);
    await pump(const Duration(milliseconds: 100));

    // Enter text after focus is established
    await enterText(restrictionInput, restriction.popis);

    // Wait for Autocomplete internal controller to sync with entered text
    await pump(const Duration(milliseconds: 300));

    await ensureVisible(restrictionAddButton);
    await tap(restrictionAddButton);

    // Wait for add to complete and input to clear
    await pump(const Duration(milliseconds: 300));

    // DEBUG: Confirm add button was tapped
    // ignore: avoid_print
    print('📝 addRestriction: Tapped add button for "${restriction.popis}"');
  }

  /// Fills all basic participant form fields from TestParticipant data.
  ///
  /// This fills: jmeno, prijmeni, rodneCislo, datumNarozeni, pohlavi,
  /// pojistovna, adresa, telefonRodice (if present), jmenoRodice (if present),
  /// emailRodice (if present).
  ///
  /// **Does NOT add medications/restrictions** - call [addMedication] and
  /// [addRestriction] separately after this method.
  ///
  /// Example usage:
  /// ```dart
  /// await robot.fillFromTestData(participant);
  /// for (final med in participant.leky) {
  ///   await robot.addMedication(med);
  /// }
  /// for (final res in participant.omezeni) {
  ///   await robot.addRestriction(res);
  /// }
  /// await robot.tapSubmit();
  /// ```
  Future<void> fillFromTestData(TestParticipant participant) async {
    await enterJmeno(participant.jmeno);
    await enterPrijmeni(participant.prijmeni);
    await enterCisloPojisteni(participant.rodneCislo);

    // Parse date from ISO string and enter
    final birthDate = DateTime.parse(participant.datumNarozeni);
    await enterDatumNarozeni(birthDate);

    await enterPohlavi(participant.pohlavi);
    await enterZdravotniPojistovna(participant.pojistovna);

    if (participant.adresa != null) {
      await enterAdresa(participant.adresa!);
    }

    if (participant.telefonRodice != null) {
      await enterTelefonRodice(participant.telefonRodice!);
    }

    if (participant.jmenoRodice != null) {
      await enterJmenoRodice(participant.jmenoRodice!);
    }

    if (participant.emailRodice != null) {
      await enterEmailRodice(participant.emailRodice!);
    }
  }

  /// Fills complete participant data including medications and restrictions.
  ///
  /// Convenience method that calls [fillFromTestData], then adds all
  /// medications and restrictions from TestParticipant.
  Future<void> fillCompleteFromTestData(TestParticipant participant) async {
    await fillFromTestData(participant);

    for (final medication in participant.leky) {
      await addMedication(medication);
    }

    for (final restriction in participant.omezeni) {
      await addRestriction(restriction);
    }
  }

  /// Taps the submit button.
  ///
  /// Uses ensureVisible to handle cases where button may be off-screen
  /// due to responsive layout (restrictions section expansion).
  Future<void> tapSubmit() async {
    await ensureVisible(submitButton);
    await tap(submitButton);
  }

  /// Taps the reset/refresh button in AppBar to clear the form.
  ///
  /// Use this to test form clearing without navigating away.
  Future<void> tapReset() async {
    await tap(resetButton);
  }

  // NOTE: ParticipantRegistrationPage uses drawer navigation, not back button.
  // Use BaseRobot.navigateToEventDetail() or similar drawer-based navigation.

  /// Waits for form to be ready for input after submit/reset.
  ///
  /// Uses waitForKey (safe for infinite animations) instead of pumpAndSettle.
  Future<bool> waitForFormReady(
      {Duration timeout = const Duration(seconds: 5)}) async {
    return await waitForKey(
      'ParticipantRegistrationForm_jmeno_input',
      timeout: timeout,
    );
  }
}
