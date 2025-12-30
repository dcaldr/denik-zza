import 'package:denik_zza/dev/dev_environment.dart';
import 'package:denik_zza/dev/ui/dev_app_builder.dart';
import 'package:denik_zza/screens2/intake_form_improved.dart';
import 'package:flutter/material.dart';

/// Dev main for NewIntakeFormImproved
///
/// Pre-seeded with 10 Czech participants for testing:
/// - Autocomplete selection (type name to search)
/// - Save & arrived workflow
/// - Cancel button behavior
/// - Form validation
///
/// 🚀 Run: flutter run -t lib/dev/dev_intake_form.dart

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DevEnvironment.initialize();

  runApp(buildDevAppWithBanner(
    title: 'Příjímací Formulář',
    bannerMessage: 'Test: Select → Save → Arrived',
    bannerIcon: Icons.person_search,
    home: const NewIntakeFormImproved(),
  ));
}
