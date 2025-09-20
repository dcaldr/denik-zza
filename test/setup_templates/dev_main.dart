import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:denik_zza/screens2/event_list.dart';
import 'hardcoded_setup.dart';
import 'package:denik_zza/database/database_wrapper.dart';

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
    // Set up test database with pre-loaded data using memory database
    // Use default (memory) database type to avoid cross-library enum conflicts
    final db = await HardcodedTestSetup.setupTestData();
    // Route app database access through the injected in-memory DB
    DatabaseWrapper.setTestMode();
    DatabaseWrapper.useTestDriftDatabase(db);
    print('✅ Test data loaded successfully!');
    print('📊 Created: 1 event, 10 participants, 10 medical records');
    
    // Start the app
    runApp(const DevApp());
  } catch (e) {
    print('❌ Error setting up test data: $e');
    // Run app anyway to show error state
    runApp(const DevApp());
  }
}

class DevApp extends StatelessWidget {
  const DevApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Denik ZZA - Development Mode',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // Add visual indicator that this is dev mode
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.orange, // Orange to indicate dev mode
          foregroundColor: Colors.white,
        ),
      ),
      home: const DevHomeWrapper(),
      locale: const Locale('cs', 'CZ'),
      supportedLocales: const [
        Locale('cs', 'CZ'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      debugShowCheckedModeBanner: true, // Keep debug banner to show this is dev
    );
  }
}

/// Wrapper that adds development indicators to the normal app
class DevHomeWrapper extends StatelessWidget {
  const DevHomeWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Development mode indicator banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            color: Colors.orange,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bug_report, size: 16, color: Colors.white),
                SizedBox(width: 4),
                Text(
                  'DEVELOPMENT MODE - Test Data Loaded',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // The actual app
          Expanded(
            child: EventList(),
          ),
        ],
      ),
    );
  }
}
