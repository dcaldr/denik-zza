import 'package:denik_zza/dev/ui/dev_app_builder.dart';
import 'package:denik_zza/screens2/event_list.dart';
import 'package:flutter/material.dart';
import 'hardcoded_setup.dart';

/// Development main that uses hardcoded test data
/// 
/// This provides a pre-populated app environment for development and testing.
/// Features:
/// - Pre-loaded test event "Test Test Test"
/// - 10 Czech participants with cultural references
/// - Medical records with Easter eggs
/// - Auto-created insurance companies
/// - Uses in-memory database for fast iterations
/// 
/// 🎯 **Perfect for:**
/// - UI development and testing
/// - Feature demonstrations
/// - Quick manual testing without setup
/// - Screenshots and documentation
/// 
/// 🚀 **To run:** `flutter run -t test/setup_templates/dev_main.dart`

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🚀 Starting development app with hardcoded test data...');
  
  try {
    // Use rich test setup with 10 participants + records
    await HardcodedTestSetup.setupTestData();
    print('✅ Test data loaded successfully!');
    print('📊 Created: 1 event, 10 participants, 10 medical records');
    
    // Start the app with unified dev UI
    runApp(buildDevAppWithBanner(
      title: 'Deník ZZA - Development Mode',
      bannerMessage: 'Test Data Loaded (10 participants + records)',
      bannerIcon: Icons.bug_report,
      home: EventList(),
    ));
  } catch (e) {
    print('❌ Error setting up test data: $e');
    // Run app anyway to show error state
    runApp(buildDevAppWithBanner(
      title: 'Deník ZZA - Development Mode (Error)',
      bannerMessage: 'ERROR: Failed to load test data',
      bannerIcon: Icons.error,
      home: EventList(),
    ));
  }
}
