import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:denik_zza/main.dart' as app;
import 'package:denik_zza/database/database_wrapper.dart';
import 'dart:io';

void log(String message) {
  final file = File('debug_trace_sanity.txt');
  file.writeAsStringSync('$message\n', mode: FileMode.append);
  print(message);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Simple sanity check: Does the app launch and show the main screen?
  // No complex seeding, just pure launch.
  testWidgets('Sanity Check: App Launches and Shows Home Screen',
      (tester) async {
    File('debug_trace_sanity.txt').writeAsStringSync('Starting Sanity Check\n');
    log('DEBUG: Sanity Check Starting');

    // Ensure DB is ready (even if empty)
    log('DEBUG: Calling DatabaseWrapper.getDatabase()');
    try {
      DatabaseWrapper.getDatabase();
      log('DEBUG: DB Initialized');
    } catch (e) {
      log('DEBUG: DB Init Failed: $e');
      rethrow;
    }

    log('DEBUG: Calling app.main()');
    try {
      app.main();
      log('DEBUG: App Main Called');
    } catch (e) {
      log('DEBUG: App Main Failed: $e');
      rethrow;
    }

    log('DEBUG: PumpAndSettle Starting');
    await tester.pumpAndSettle();
    log('DEBUG: App Pumped');

    // Verify Title "Všechny akce"
    log('DEBUG: Checking for Title');
    expect(find.text('Všechny akce'), findsOneWidget);
    log('DEBUG: Title Found');

    // Verify we are at least on a screen with a Scaffold
    log('DEBUG: Checking for ListView');
    expect(find.byType(ListView), findsOneWidget); // EventList uses ListView
    log('DEBUG: Sanity Check Complete');
  });
}
