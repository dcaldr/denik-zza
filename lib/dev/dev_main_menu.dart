import 'package:denik_zza/dev/dev_environment.dart';
import 'package:denik_zza/screens2/event_list.dart';
import 'package:flutter/material.dart';

/// Development entry point for testing AppDrawer menu
/// 
/// Run with:
/// ```bash
/// flutter run -t lib/dev/dev_main_menu.dart
/// ```
/// 
/// Features:
/// - Shows EventList with AppDrawer
/// - Pre-initialized with test event (menu items will be enabled)
/// - Test state-based menu enabling/disabling
/// - All Czech UI text
/// 
/// To test different states:
/// - Default: Has event, no participants → Some items enabled
/// - Add participants via menu to enable record operations
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dev environment with test event
  // This ensures menu items requiring an event will be enabled
  await DevEnvironment.initialize();
  
  runApp(const MenuDevApp());
}

class MenuDevApp extends StatelessWidget {
  const MenuDevApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Menu Dev - Deník ZZA',
      debugShowCheckedModeBanner: true,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // Orange AppBar to indicate dev mode
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
        ),
      ),
      // Note: Czech locale already initialized by DevEnvironment.initialize()
      // No need for locale/localizationsDelegates here
      home: const DevMenuWrapper(),
    );
  }
}

/// Wrapper that adds development indicators to the app
class DevMenuWrapper extends StatelessWidget {
  const DevMenuWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Orange dev mode banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            color: Colors.orange,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.menu, size: 16, color: Colors.white),
                SizedBox(width: 4),
                Text(
                  'DEV MODE - Menu Testing (In-Memory DB)',
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
