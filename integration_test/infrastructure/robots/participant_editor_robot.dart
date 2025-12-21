import 'package:flutter_test/flutter_test.dart';
import 'base_robot.dart';

/// Robot for interacting with [ParticipantRegistrationForm].
///
/// This robot provides methods to:
/// - Fill participant registration form fields
/// - Submit the form
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

  /// Taps the submit button.
  Future<void> tapSubmit() async {
    await tap(submitButton);
  }
}
