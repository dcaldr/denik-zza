import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

// removed unused import: database.dart
import 'package:denik_zza/print_ops2/person_mode_flow_page.dart';
import 'package:denik_zza/print_ops2/print_center_controller.dart';
import 'package:denik_zza/print_ops2/print_center_service.dart';

import '../setup_templates/hardcoded_setup.dart'; // From test folder

void main() {
  late PrintCenterService service;
  late PrintCenterController controller;

  setUp(() async {
    await HardcodedTestSetup.setupTestData();
    service = PrintCenterService();
    controller = PrintCenterController(service);
    controller.init();
  });

  tearDown(() async {
    controller.dispose();
  });

  testWidgets('Selecting second person issue test', (WidgetTester tester) async {
    // Wait for the stream to emit participants and UI to update
    // We use runAsync to allow real asynchronous operations (like Drift DB isolation streams)
    // to complete outside the test's FakeAsync zone.
    await tester.runAsync(() async {
      await Future.delayed(const Duration(milliseconds: 300));
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChangeNotifierProvider<PrintCenterController>.value(
            value: controller,
            child: const PersonAndModeFlowPage(),
          ),
        ),
      ),
    );

    // Give it a moment to render the participants using standard pump
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    
    // Verify Karel Čapek is actually there
    expect(find.text('Karel Čapek'), findsWidgets, reason: 'Karel Čapek should be loaded in the participant list');

    // Print out current state
    print('--- Stage 1 Initial ---');
    print('Participants loaded: ${controller.participants.length}');
    for (var p in controller.participants) {
      print(' - ${p.jmeno} ${p.prijmeni} (wasPrinted: ${p.wasPrinted})');
    }

    // 2. Select first person (Karel)
    print('\nSelecting Karel...');
    await tester.tap(find.text('Karel Čapek').first);
    
    // Wait for Detail Pane to appear
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    
    // Check if the detail actually loaded 
    if (find.text('Potvrdit a vytisknout').evaluate().isEmpty && find.textContaining('tisk').evaluate().isEmpty) {
        print('Warning: detail page might not be fully loaded, or specific text missing.');
    }

    // 3. Confirm simulation (Stage 3)
    print('\nSimulating print success...');
    // We bypass the actual dialog and inject the success result directly
    await controller.confirmPrintResult(PrintSimulationResult.success);
    
    bool simulated = false;
    for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 100));
        if (controller.simulatedPrinted) {
            simulated = true;
            break;
        }
    }

    if (!simulated) fail('Simulated print did not occur');

    print('SimulatedPrinted: ${controller.simulatedPrinted}');
    
    // 4. Reset flow (Nový tisk)
    print('\nResetting flow (Nový tisk)...');
    controller.resetFlow();
    
    // Allow AnimatedSwitcher to transition back to Stage 1 and UI to load again
    bool resetLoaded = false;
    for (int i = 0; i < 50; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (find.text('Milada Horáková').evaluate().isNotEmpty) {
         resetLoaded = true;
         break;
      }
    }

    if (!resetLoaded) print('Warning: Milada could not be loaded in reset flow.');

    print('\n--- Stage 1 After Reset ---');
    print('Participants loaded: ${controller.participants.length}');
    for (var p in controller.participants) {
      print(' - ${p.jmeno} ${p.prijmeni} (wasPrinted: ${p.wasPrinted})');
    }

    // 5. Try to find Milada
    final miladaFinder = find.text('Milada Horáková');
    print('\nFinder found Milada: ${miladaFinder.evaluate().length} widgets');

    if (miladaFinder.evaluate().isEmpty) {
      print('\n[ERROR] Milada NOT FOUND in widget tree! Dumping subtree:');
      debugDumpApp();
      fail('Milada not found');
    } else {
      print('\n[SUCCESS] Milada found! Tapping...');
      await tester.tap(miladaFinder.first);
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      print('Selected: ${controller.selected?.jmeno} ${controller.selected?.prijmeni}');
    }
  });
}
