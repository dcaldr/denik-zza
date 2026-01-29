import 'package:denik_zza/dev/ui/dev_app_builder.dart';
import 'package:denik_zza/screens2/new_record/new_record_page.dart';
import 'package:denik_zza/database/database_wrapper.dart';
import 'package:flutter/material.dart';
import 'hardcoded_setup.dart';
import 'package:denik_zza/utils/app_logger.dart';

/// Development entry point for testing NewRecordPage (Nový záznam úrazu)
///
/// This provides a pre-configured environment with:
/// - Test event "Test Test Test" created and selected
/// - 10 Czech participants with cultural references
/// - First participant pre-selected in the form
///
/// 🎯 **Perfect for:**
/// - Testing NewRecordPage UI and functionality
/// - Developing record creation features
/// - Testing with pre-selected participant and rich data
///
/// 🚀 **To run:** `flutter run -t test/setup_templates/dev_new_record.dart`

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AppLogger.l.i('🚀 Starting NewRecordPage dev environment...');

  try {
    // Use rich test setup with 10 participants + records (standardized setup)
    await HardcodedTestSetup.setupTestData();
    AppLogger.l.i('✅ Test data loaded successfully!');
    AppLogger.l.i('📊 Created: 1 event, 10 participants, 10 medical records');

    // Get the first participant to pre-select using DatabaseWrapper
    final db = DatabaseWrapper.getDatabase();
    final participants = await db.getParticipantsByCurrentEvent();
    final firstParticipant =
        participants.isNotEmpty ? participants.first : null;

    if (firstParticipant != null) {
      AppLogger.l.i(
          '✅ Pre-selected participant: ${firstParticipant.jmeno} ${firstParticipant.prijmeni}');
    } else {
      AppLogger.l.w('⚠️ No participants found - search will be empty');
    }

    // Start the app with NewRecordPage and pre-selected participant
    runApp(buildDevAppWithBanner(
      title: 'Nový záznam úrazu - Dev Mode',
      bannerMessage: 'Test Data Loaded (10 participants + pre-selected)',
      bannerIcon: Icons.medical_services,
      home: NewRecordPage(participant: firstParticipant),
    ));
  } catch (e) {
    AppLogger.l.e('❌ Error setting up dev environment: $e');
    // Run app anyway to show error state
    runApp(buildDevAppWithBanner(
      title: 'Nový záznam úrazu - Dev Mode (Error)',
      bannerMessage: 'ERROR: Failed to load test data',
      bannerIcon: Icons.error,
      home: const NewRecordPage(),
    ));
  }
}
