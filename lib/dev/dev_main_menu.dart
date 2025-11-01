import 'package:denik_zza/dev/dev_environment.dart';
import 'package:denik_zza/dev/ui/dev_app_builder.dart';
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
/// - Visible dev mode banner
/// 
/// To test different states:
/// - Default: Has event, no participants → Some items enabled
/// - Add participants via menu to enable record operations
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dev environment with test event
  // This ensures menu items requiring an event will be enabled
  await DevEnvironment.initialize();
  
  runApp(buildDevAppWithBanner(
    title: 'Menu Dev - Deník ZZA',
    bannerMessage: 'Menu Testing (In-Memory DB)',
    bannerIcon: Icons.construction,
    home: EventList(),
  ));
}
