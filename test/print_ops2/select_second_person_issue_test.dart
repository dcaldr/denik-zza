import 'package:denik_zza/database/database_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

// ...existing code...
import 'package:denik_zza/database/drift_database/database.dart';
import 'package:denik_zza/print_ops2/person_mode_flow_page.dart';
import 'package:denik_zza/print_ops2/print_center_controller.dart';
// ...existing code...

import 'package:denik_zza/print_ops2/print_center_service.dart';

import '../setup_templates/hardcoded_setup.dart'; // From test folder

void main() {
  late AppDatabase database;
  late PrintCenterService service;
  late PrintCenterController controller;

  setUp(() async {
    database = await HardcodedTestSetup.setupTestData();
    service = PrintCenterService();
    controller = PrintCenterController(service);
    controller.init();
  });

  tearDown(() async {
    controller.dispose();
    await database.close();
    await DatabaseWrapper.dispose();
  });

  testWidgets('Selecting second person issue test', (WidgetTester tester) async {
    // 1. Pump the page
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

    // Wait for the stream to emit participants and UI to update
    for (int i = 0; i < 50; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (!controller.loadingParticipants && controller.participants.isNotEmpty) break;
    }
    
    // Print out current state
    print('--- Stage 1 Initial ---');
    print('Participants loaded: ${controller.participants.length}');
    for (var p in controller.participants) {
      print(' - ${p.jmeno} ${p.prijmeni} (wasPrinted: ${p.wasPrinted})');
    }

    // 2. Select first person (Karel)
    print('\nSelecting Karel...');
    await tester.tap(find.text('Karel Čapek').first);
    for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
        if (controller.selected != null && !controller.loadingDetail) break;
    }

    // 3. Confirm simulation (Stage 3)
    print('\nSimulating print success...');
    // We bypass the actual dialog and inject the success result directly
    await controller.confirmPrintResult(PrintSimulationResult.success);
    
    for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
        if (controller.simulatedPrinted) break;
    }

    print('SimulatedPrinted: ${controller.simulatedPrinted}');
    
    // 4. Reset flow (Nový tisk)
    print('\nResetting flow (Nový tisk)...');
    controller.resetFlow();
    
    // Allow AnimatedSwitcher to transition back to Stage 1
    for (int i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }

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
