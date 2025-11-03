/// Dev main for ParticipantRegistrationForm
/// 
/// Run with: flutter run -t lib/dev/dev_participant_registration_form.dart

import 'package:denik_zza/dev/dev_environment.dart';
import 'package:denik_zza/dev/ui/dev_app_builder.dart';
import 'package:denik_zza/screens2/participant_registration_form.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DevEnvironment.initialize();
  
  runApp(buildDevAppWithBanner(
    title: 'Registrace Účastníka',
    bannerMessage: 'Dev Mode',
    bannerIcon: Icons.person_add,
    home: const ParticipantRegistrationPage(),
  ));
}
