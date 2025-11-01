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
      title: 'Menu Dev',
      debugShowCheckedModeBanner: true,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // Orange dev mode indicator
        bannerTheme: const MaterialBannerThemeData(
          backgroundColor: Colors.orange,
        ),
      ),
      locale: const Locale('cs', 'CZ'),
      home: Banner(
        message: 'MENU DEV',
        location: BannerLocation.topEnd,
        child: EventList(),
      ),
    );
  }
}
