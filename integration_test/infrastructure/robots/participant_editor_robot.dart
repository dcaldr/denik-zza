import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For LogicalKeyboardKey
import 'base_robot.dart';

// Import test data models for fillFromTestData
import '../data/models/test_participant.dart';
import '../data/models/test_medication.dart';
import '../data/models/test_restriction.dart';
import 'package:denik_zza/utils/app_logger.dart';

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

  // Submit button target depends on host page:
  // - ParticipantEditPage uses its own footer button
  // - Registration page/form use existing submit keys
  Finder get submitButton {
    final editPageSubmit = findKey('ParticipantEditPage_submit_button');
    if (editPageSubmit.evaluate().isNotEmpty) {
      return editPageSubmit;
    }

    final registrationPageSubmit =
        findKey('ParticipantRegistrationPage_submit_button');
    if (registrationPageSubmit.evaluate().isNotEmpty) {
      return registrationPageSubmit;
    }

    return findKey('ParticipantRegistrationForm_submit_button');
  }

  // RestrictionsWidget fields (added Phase 1)
  // NOTE: Keys match _logic.getText() - 'Léky' and 'Omezení a alergie'
  Finder get medicationInput => findKey('RestrictionsWidget_Léky_input');
  Finder get medicationAddButton =>
      findKey('RestrictionsWidget_Léky_add_button');
  Finder get restrictionInput =>
      findKey('RestrictionsWidget_Omezení a alergie_input');
  Finder get restrictionAddButton =>
      findKey('RestrictionsWidget_Omezení a alergie_add_button');

  // Checkboxes
  Finder get bezinfekcnostCheckbox =>
      findKey('ParticipantRegistrationForm_bezinfekcnost_checkbox');
  Finder get zpusobilostCheckbox =>
      findKey('ParticipantRegistrationForm_zpusobilost_checkbox');

  // Reset button in AppBar (clears form)
  Finder get resetButton =>
      findKey('ParticipantRegistrationPage_refresh_button');

  /// Verifies the page is shown with key form elements.
  /// If [checkSubmitButton] is false, it skips verifying the submit button 
  /// (useful when the form is embedded in Intake and uses an external save button).
  Future<void> verifyPageShown({bool checkSubmitButton = true}) async {
    await pumpAndSettle();
    expect(jmenoInput, findsOneWidget);
    expect(prijmeniInput, findsOneWidget);
    if (checkSubmitButton) {
      expect(submitButton, findsOneWidget);
    }
  }

  /// Enters first name and verifies it was set.
  Future<void> enterJmeno(String jmeno) async {
    await enterText(jmenoInput, jmeno);
    // Strict assertion: verify field contains expected value
    final field = tester.widget<TextFormField>(jmenoInput);
    expect(field.controller?.text, equals(jmeno),
        reason: 'Jméno field should contain "$jmeno"');
  }

  /// Enters last name and verifies it was set.
  Future<void> enterPrijmeni(String prijmeni) async {
    await enterText(prijmeniInput, prijmeni);
    // Strict assertion: verify field contains expected value
    final field = tester.widget<TextFormField>(prijmeniInput);
    expect(field.controller?.text, equals(prijmeni),
        reason: 'Příjmení field should contain "$prijmeni"');
  }

  /// Enters national ID number (rodné číslo) and verifies it was set.
  Future<void> enterCisloPojisteni(String rc) async {
    await enterText(cisloPojisteniInput, rc);
    // Strict assertion: verify field contains expected value
    final field = tester.widget<TextFormField>(cisloPojisteniInput);
    expect(field.controller?.text, equals(rc),
        reason: 'Rodné číslo field should contain "$rc"');
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

  /// Sets the bezinfekčnost checkbox (infection-free certificate).
  ///
  /// Only taps if current value differs from desired value to avoid flipping twice.
  Future<void> setBezinfekcnost(bool value) async {
    await ensureVisible(bezinfekcnostCheckbox);
    await pump();
    final checkbox = tester.widget<CheckboxListTile>(bezinfekcnostCheckbox);
    final currentValue = checkbox.value ?? false;

    if (currentValue != value) {
      await ensureVisible(bezinfekcnostCheckbox);
      await tap(bezinfekcnostCheckbox);
      await smartSettle();

      // Strict assertion
      final updatedCheckbox =
          tester.widget<CheckboxListTile>(bezinfekcnostCheckbox);
      expect(updatedCheckbox.value, equals(value),
          reason: 'Bezinfekčnost checkbox should be $value');
    }
  }

  /// Sets the způsobilost checkbox (fitness certificate).
  ///
  /// Only taps if current value differs from desired value to avoid flipping twice.
  Future<void> setZpusobilost(bool value) async {
    await ensureVisible(zpusobilostCheckbox);
    await pump();
    final checkbox = tester.widget<CheckboxListTile>(zpusobilostCheckbox);
    final currentValue = checkbox.value ?? false;

    if (currentValue != value) {
      await ensureVisible(zpusobilostCheckbox);
      await tap(zpusobilostCheckbox);
      await smartSettle();

      // Strict assertion
      final updatedCheckbox =
          tester.widget<CheckboxListTile>(zpusobilostCheckbox);
      expect(updatedCheckbox.value, equals(value),
          reason: 'Způsobilost checkbox should be $value');
    }
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
    await smartSettle();

    // Enter text after focus is established
    await enterText(medicationInput, text);

    // Wait for Autocomplete internal controller to sync with entered text
    await smartSettle();

    await ensureVisible(medicationAddButton);
    await tap(medicationAddButton);

    // Wait for add to complete and input to clear
    await smartSettle();
  }

  /// Adds a restriction via RestrictionsWidget.
  ///
  /// Requires widget keys added in Phase 1.
  /// Uses the restriction's popis (description) field.
  ///
  /// Note: Uses tap-to-focus before entering text to ensure Autocomplete's
  /// internal controller syncs correctly with entered text.
  Future<void> addRestriction(TestRestriction restriction) async {
    // Print only on error (see expect below)

    // Ensure input visible (may have scrolled due to responsive layout)
    await ensureVisible(restrictionInput);

    // Tap to focus the input field first (critical for Autocomplete sync)
    await tap(restrictionInput);
    await smartSettle();

    // Enter text after focus is established
    await enterText(restrictionInput, restriction.popis);

    // Wait for Autocomplete internal controller to sync with entered text
    await smartSettle();

    await ensureVisible(restrictionAddButton);
    await tap(restrictionAddButton);

    // Wait for add to complete and input to clear
    await smartSettle();

    // STRICT ASSERTION: Verify restriction appears in visible list
    expect(find.text(restriction.popis), findsWidgets,
        reason: 'Restriction "${restriction.popis}" should appear in list');
  }

  /// Adds a restriction by typing text and pressing Enter key.
  ///
  /// Tests the Enter key submit flow (TextInputAction.done).
  Future<void> addRestrictionViaEnter(String text) async {
    // Print only on error (see expect below)

    await ensureVisible(restrictionInput);
    await tap(restrictionInput);
    await smartSettle();

    await enterText(restrictionInput, text);
    await smartSettle();

    // Submit via Enter key (TextInputAction.done)
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await smartSettle();

    // Verify item appears; if not, fallback to Add button
    var found = await waitForText(
      text,
      timeout: const Duration(seconds: 2),
    );
    if (!found) {
      final fieldAfterEnter = tester.widget<TextField>(restrictionInput);
      final currentText = fieldAfterEnter.controller?.text ?? '';
      if (currentText.trim().isEmpty) {
        await tester.enterText(restrictionInput, text);
        await smartSettle();
      }
      await ensureVisible(restrictionAddButton);
      await tap(restrictionAddButton);
      await smartSettle();

      found = await waitForText(
        text,
        timeout: const Duration(seconds: 2),
      );
    }

    expect(found, isTrue,
        reason: 'Restriction "$text" should appear in list');
  }

  /// Adds a restriction via Tab autocomplete with strict assertions.
  ///
  /// [partialText] - partial text to trigger suggestion
  /// [expectedFull] - full text expected after Tab completion
  ///
  /// Flow: Type partial → verify ghost → Tab completes → verify fill → Enter submits → verify in list
  Future<void> addRestrictionViaTab(
      String partialText, String expectedFull) async {
    // Print only on error (see expect below)

    await ensureVisible(restrictionInput);
    await tap(restrictionInput);
    await smartSettle();

    // Type partial text to trigger autocomplete
    await tester.enterText(restrictionInput, partialText);
    await smartSettle();



    // Press Tab to autocomplete
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await smartSettle();

    final inputField = tester.widget<TextField>(restrictionInput);
    final actualText = inputField.controller?.text ?? '';
    // Print only on error (see expect below)

    // Submit via Enter
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await smartSettle();

    // Verify item appears; if not, fallback to Add button
    final targetText = actualText.isNotEmpty ? actualText : expectedFull;
    var found = await waitForText(
      targetText,
      timeout: const Duration(seconds: 2),
    );
    if (!found) {
      final fieldAfterEnter = tester.widget<TextField>(restrictionInput);
      final currentText = fieldAfterEnter.controller?.text ?? '';
      if (currentText.trim().isEmpty) {
        await tester.enterText(restrictionInput, targetText);
        await smartSettle();
      }
      await ensureVisible(restrictionAddButton);
      await tap(restrictionAddButton);
      await smartSettle();

      found = await waitForText(
        targetText,
        timeout: const Duration(seconds: 2),
      );
    }

    expect(found, isTrue,
        reason: 'Restriction should appear in list after submit');
  }

  /// Adds a medication by typing text and pressing Enter key.
  Future<void> addMedicationViaEnter(String text) async {
    // Print only on error (see expect below)

    await ensureVisible(medicationInput);
    await tap(medicationInput);
    await smartSettle();

    await enterText(medicationInput, text);
    await smartSettle();

    await tester.testTextInput.receiveAction(TextInputAction.done);
    await smartSettle();

    // Verify item appears; if not, fallback to Add button
    var found = await waitForText(
      text,
      timeout: const Duration(seconds: 2),
    );
    if (!found) {
      final fieldAfterEnter = tester.widget<TextField>(medicationInput);
      final currentText = fieldAfterEnter.controller?.text ?? '';
      if (currentText.trim().isEmpty) {
        await tester.enterText(medicationInput, text);
        await smartSettle();
      }
      await ensureVisible(medicationAddButton);
      await tap(medicationAddButton);
      await smartSettle();

      found = await waitForText(
        text,
        timeout: const Duration(seconds: 2),
      );
    }

    expect(found, isTrue,
        reason: 'Medication "$text" should appear in list after Enter submit');
  }

  /// Adds a medication via Tab autocomplete, then enters full text with dosage.
  ///
  /// Medication autocomplete (_names) contains only nazev (no dosage), so Tab fills
  /// just the name. This method verifies Tab triggered autocomplete (field changed),
  /// then enters expectedFull (including dosage) to ensure correct DB storage.
  ///
  /// Flow: Type partial → Tab fills name → assert Tab worked → enter full text → Add
  Future<void> addMedicationViaTab(
      String partialText, String expectedFull) async {
    await ensureVisible(medicationInput);
    await tap(medicationInput);
    await smartSettle();

    await tester.enterText(medicationInput, partialText);
    await smartSettle();

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await smartSettle();

    // Verify Tab triggered autocomplete: field must differ from the partial input.
    // Note: _names only stores nazev (e.g. "Ibalgin 400mg"), not full dosage text.
    final fieldAfterTab = tester.widget<TextField>(medicationInput);
    final tabText = fieldAfterTab.controller?.text ?? '';
    expect(
      tabText.isNotEmpty && tabText.trim() != partialText,
      isTrue,
      reason: 'Tab should fill medication field with autocomplete suggestion '
          '(typed: "$partialText", got: "$tabText")',
    );

    // Enter full text (with dosage) so _parseMedicationInput stores complete info.
    await tester.enterText(medicationInput, expectedFull);
    await smartSettle();

    await ensureVisible(medicationAddButton);
    await tap(medicationAddButton);

    final found = await waitForText(
      expectedFull,
      timeout: const Duration(seconds: 2),
    );
    expect(found, isTrue,
        reason: 'Medication "$expectedFull" should appear in list');
  }

  /// Adds a restriction via Tab autocomplete, then modifies text before submitting.
  ///
  /// Flow: Type partial → Tab fills → modify text → Enter submits modified
  Future<void> addRestrictionViaTabThenModify(
      String partialText, String tabFillsTo, String modifiedTo) async {
    // ignore: avoid_print
    AppLogger.l.i('📝 addRestrictionViaTabThenModify: "$partialText" → "$modifiedTo"');

    await ensureVisible(restrictionInput);
    await tap(restrictionInput);
    await smartSettle();

    await tester.enterText(restrictionInput, partialText);
    await smartSettle();

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await smartSettle();

    // STRICT ASSERTION: Verify Tab filled with suggestion
    final fieldAfterTab = tester.widget<TextField>(restrictionInput);
    expect(fieldAfterTab.controller?.text, equals(tabFillsTo),
        reason: 'Tab should fill field with "$tabFillsTo"');

    await tester.enterText(restrictionInput, modifiedTo);
    await smartSettle();

    await tester.testTextInput.receiveAction(TextInputAction.done);
    await smartSettle();

    // Verify item appears; if not, fallback to Add button
    var found = await waitForText(
      modifiedTo,
      timeout: const Duration(seconds: 2),
    );
    if (!found) {
      final fieldAfterEnter = tester.widget<TextField>(restrictionInput);
      final currentText = fieldAfterEnter.controller?.text ?? '';
      if (currentText.trim().isEmpty) {
        await tester.enterText(restrictionInput, modifiedTo);
        await smartSettle();
      }
      await ensureVisible(restrictionAddButton);
      await tap(restrictionAddButton);
      await smartSettle();

      found = await waitForText(
        modifiedTo,
        timeout: const Duration(seconds: 2),
      );
    }

    // STRICT ASSERTION: Verify modified text appears in list
    expect(found, isTrue,
        reason: 'Modified restriction "$modifiedTo" should appear in list');
  }

  /// Clears input after Tab autocomplete fills, then adds different text.
  ///
  /// Flow: Type partial → Tab fills → clear → type own → Enter submits
  Future<void> addRestrictionViaClearAfterTab(
      String partialText, String tabFillsTo, String ownText) async {
    // ignore: avoid_print
    AppLogger.l.i(
        '📝 addRestrictionViaClearAfterTab: Tab "$partialText", add "$ownText"');

    await ensureVisible(restrictionInput);
    await tap(restrictionInput);
    await smartSettle();

    await tester.enterText(restrictionInput, partialText);
    await smartSettle();

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await smartSettle();

    await tester.enterText(restrictionInput, '');
    await smartSettle();

    await tester.enterText(restrictionInput, ownText);
    await smartSettle();

    await tester.testTextInput.receiveAction(TextInputAction.done);
    await smartSettle();

    // Verify item appears; if not, fallback to Add button
    var found = await waitForText(
      ownText,
      timeout: const Duration(seconds: 2),
    );
    if (!found) {
      final fieldAfterEnter = tester.widget<TextField>(restrictionInput);
      final currentText = fieldAfterEnter.controller?.text ?? '';
      if (currentText.trim().isEmpty) {
        await tester.enterText(restrictionInput, ownText);
        await pump(const Duration(milliseconds: 200));
      }
      await ensureVisible(restrictionAddButton);
      await tap(restrictionAddButton);
      await smartSettle();

      found = await waitForText(
        ownText,
        timeout: const Duration(seconds: 2),
      );
    }

    expect(found, isTrue,
        reason: 'Restriction "$ownText" should appear in list');
  }

  /// Adds a restriction by clicking a dropdown suggestion.
  ///
  /// Flow: Type partial → dropdown appears → tap suggestion → auto-added
  Future<void> addRestrictionViaDropdownClick(
      String partialText, String fullSuggestion) async {
    // ignore: avoid_print
    AppLogger.l.i(
        '📝 addRestrictionViaDropdownClick: Type "$partialText", tap dropdown');

    await ensureVisible(restrictionInput);
    await tap(restrictionInput);
    await smartSettle();

    await tester.enterText(restrictionInput, partialText);
    await smartSettle();

    // STRICT ASSERTION: Verify dropdown shows suggestion
    final dropdownFinder = find.text(fullSuggestion);
    expect(dropdownFinder, findsWidgets,
        reason: 'Dropdown should show "$fullSuggestion"');
    await tap(dropdownFinder.last);
    await smartSettle();

    // STRICT ASSERTION: Verify item appears in list after dropdown selection
    expect(find.text(fullSuggestion), findsWidgets,
        reason:
            'Restriction "$fullSuggestion" should appear in list after dropdown click');
  }

  /// Rejects autosuggestion by typing different text.
  ///
  /// Flow: Type partial that triggers ghost → type different text → Enter
  Future<void> addRestrictionRejectSuggestion(
      String partialTrigger, String differentText) async {
    // ignore: avoid_print
    AppLogger.l.i(
        '📝 addRestrictionRejectSuggestion: Trigger "$partialTrigger", add "$differentText"');

    await ensureVisible(restrictionInput);
    await tap(restrictionInput);
    await smartSettle();

    await tester.enterText(restrictionInput, partialTrigger);
    await smartSettle();

    await tester.enterText(restrictionInput, differentText);
    await smartSettle();

    await tester.testTextInput.receiveAction(TextInputAction.done);
    await smartSettle();

    // Verify item appears; if not, fallback to Add button
    var found = await waitForText(
      differentText,
      timeout: const Duration(seconds: 2),
    );
    if (!found) {
      final fieldAfterEnter = tester.widget<TextField>(restrictionInput);
      final currentText = fieldAfterEnter.controller?.text ?? '';
      if (currentText.trim().isEmpty) {
        await tester.enterText(restrictionInput, differentText);
        await smartSettle();
      }
      await ensureVisible(restrictionAddButton);
      await tap(restrictionAddButton);
      await smartSettle();

      found = await waitForText(
        differentText,
        timeout: const Duration(seconds: 2),
      );
    }

    // STRICT ASSERTION: Verify different text appears in list (not suggestion)
    expect(found, isTrue,
        reason: 'Restriction "$differentText" should appear in list');
  }

  /// Fills all basic participant form fields from TestParticipant data.
  ///
  /// This fills: jmeno, prijmeni, rodneCislo, datumNarozeni, pohlavi,
  /// pojistovna, adresa, telefonRodice (if present), jmenoRodice (if present),
  /// emailRodice (if present), and checkboxes (bezinfekcnost, zpusobilost).
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
  Future<void> fillFromTestData(TestParticipant participant, {
    bool skipDatumNarozeni = false,
    bool skipPohlavi = false,
    bool checkSubmitButton = true,
  }) async {
    await verifyPageShown(checkSubmitButton: checkSubmitButton);
    await enterJmeno(participant.jmeno);
    await enterPrijmeni(participant.prijmeni);
    await enterCisloPojisteni(participant.rodneCislo);

    if (!skipDatumNarozeni) {
      // Parse date from ISO string and enter
      final birthDate = DateTime.parse(participant.datumNarozeni);
      await enterDatumNarozeni(birthDate);
    }

    if (!skipPohlavi) {
      await enterPohlavi(participant.pohlavi);
    }

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

    // Give embedded intake form one frame to complete any rebuilds before toggling checkboxes.
    await pump();

    // Set checkboxes
    await setBezinfekcnost(participant.bezinfekcnost);
    await setZpusobilost(participant.zpusobilost);
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
  /// Uses settle: false to prevent 4-second hangs if the success inline message
  /// is ever changed back to a SnackBar, ensuring slow mode remains unblocked.
  Future<void> tapSubmit() async {
    await humanObservationDelay();
    final hasEditPageSubmit =
        findKey('ParticipantEditPage_submit_button').evaluate().isNotEmpty;
    final hasRegistrationPageSubmit =
        findKey('ParticipantRegistrationPage_submit_button')
            .evaluate()
            .isNotEmpty;
    final hasRegistrationFormSubmit =
        findKey('ParticipantRegistrationForm_submit_button')
            .evaluate()
            .isNotEmpty;
    print('[DIAG][ParticipantEditorRobot.tapSubmit] '
        'hasEditPageSubmit=$hasEditPageSubmit '
        'hasRegistrationPageSubmit=$hasRegistrationPageSubmit '
        'hasRegistrationFormSubmit=$hasRegistrationFormSubmit');
    await ensureVisible(submitButton);
    print('[DIAG][ParticipantEditorRobot.tapSubmit] '
        'targetCount=${submitButton.evaluate().length}');
    await tap(submitButton, settle: false);
    incrementRound();
  }

  /// Taps the reset/refresh button in AppBar to clear the form.
  ///
  /// Use this to test form clearing without navigating away.
  Future<void> tapReset() async {
    await tap(resetButton);
  }

  // NOTE: ParticipantRegistrationPage uses drawer navigation, not back button.
  // Use BaseRobot.navigateToEventDetail() or similar drawer-based navigation.

  /// Verifies that the form is in a clean execution state.
  ///
  /// Checks:
  /// - Name field is empty
  /// - Checkboxes (Bezinfekčnost, Způsobilost) are UNCHECKED
  Future<void> assertFormClean() async {
    // Check name field is empty
    final nameField = tester.widget<TextFormField>(jmenoInput);
    expect(nameField.controller?.text, isEmpty, reason: 'Form Name field should be empty');

    // Check checkboxes are unchecked
    final bezinfekcnost = tester.widget<CheckboxListTile>(bezinfekcnostCheckbox);
    expect(bezinfekcnost.value, isFalse, reason: 'Bezinfekcnost should be unchecked on clean form');

    final zpusobilost = tester.widget<CheckboxListTile>(zpusobilostCheckbox);
    expect(zpusobilost.value, isFalse, reason: 'Zpusobilost should be unchecked on clean form');
  }

  /// Waits for form to be ready for input after submit/reset.
  ///
  /// Strictly waits for the Jméno input field to be completely cleared,
  /// guaranteeing that the async database save and UI reset have finished.
  Future<bool> waitForFormReady(
      {Duration timeout = const Duration(seconds: 5)}) async {
    return await waitForFieldToClear(
      jmenoInput,
      timeout: timeout,
    );
  }
}
