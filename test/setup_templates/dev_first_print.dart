import 'package:denik_zza/dev/ui/dev_app_builder.dart';
import 'package:denik_zza/print_ops2/first_print.dart';
import 'package:flutter/material.dart';
import 'hardcoded_setup.dart';
import 'package:denik_zza/utils/app_logger.dart';

/// Development main for FirstPrint wizard
///
/// Quick way to test the printer calibration wizard UI without navigating
/// through the entire app.
///
/// 🚀 **To run:** `flutter run -t test/setup_templates/dev_first_print.dart`

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AppLogger.l.i('🖨️ Starting FirstPrint wizard development mode...');

  try {
    // Use test setup for consistent environment
    await HardcodedTestSetup.setupTestData();
    AppLogger.l.i('✅ Test data loaded successfully!');

    // Start the app directly at FirstPrint wizard
    runApp(buildDevAppWithBanner(
      title: 'FirstPrint Wizard - Dev',
      bannerMessage: 'Printer Calibration Wizard',
      bannerIcon: Icons.print,
      home: const FirstPrint(),
    ));
  } catch (e) {
    AppLogger.l.e('❌ Error setting up test data: $e');
    // Run app anyway to show error state
    runApp(buildDevAppWithBanner(
      title: 'FirstPrint Wizard - Dev (Error)',
      bannerMessage: 'ERROR: Failed to load test data',
      bannerIcon: Icons.error,
      home: const FirstPrint(),
    ));
  }
}
