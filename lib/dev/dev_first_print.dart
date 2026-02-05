import 'package:denik_zza/dev/dev_environment.dart';
import 'package:denik_zza/dev/ui/dev_app_builder.dart';
import 'package:denik_zza/print_ops2/first_print.dart';
import 'package:flutter/material.dart';

/// Development entry point for FirstPrint wizard testing.
///
/// Launches the first-time print setup wizard with dev environment.
/// Use this to test the calibration and first-print flow.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DevEnvironment.initialize();

  runApp(buildDevAppWithBanner(
    title: 'First Print Dev',
    bannerMessage: 'First Print Wizard',
    bannerIcon: Icons.print,
    home: const FirstPrint(),
  ));
}
