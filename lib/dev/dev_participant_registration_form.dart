import 'package:denik_zza/dev/dev_environment.dart';
import 'package:denik_zza/dev/ui/dev_app_builder.dart';
import 'package:denik_zza/screens2/participant_registration_form.dart';
import 'package:flutter/material.dart';

// Dev main for ParticipantRegistrationPage
//
// This provides a pre-configured environment for testing:
// - Refresh button (clears form without submitting)
// - Restrictions autosuggest (dropdown + tab completion)
// - Form validation (required fields: Jméno, Příjmení)
// - Form clearing after successful submit
// - DB persistence verification
//
// 🎯 Perfect for:
// - Testing new UI features
// - Testing form validation
// - Testing restrictions/medications entry
//
// 🚀 To run: flutter run -t lib/dev/dev_participant_registration_form.dart

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DevEnvironment.initialize();

  runApp(buildDevAppWithBanner(
    title: 'Registrace Účastníka',
    bannerMessage: 'Test: Refresh, Autosuggest, Validation',
    bannerIcon: Icons.person_add,
    home: const ParticipantRegistrationPage(),
  ));
}
