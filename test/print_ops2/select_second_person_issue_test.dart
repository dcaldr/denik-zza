import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:denik_zza/print_ops2/person_mode_flow_page.dart';
import 'package:denik_zza/print_ops2/print_center_controller.dart';
import 'package:denik_zza/print_ops2/print_center_service.dart';

import '../setup_templates/hardcoded_setup.dart';
import '../utils/widget_test_helpers.dart';

void main() {
  late PrintCenterService service;
  late PrintCenterController controller;

  setUp(() async {
    // INITIALIZE REAL DRIFT DB TEST DATA (User Rule: Real over mocks for workflows)
    await HardcodedTestSetup.setupTestData();
    service = PrintCenterService();
    controller = PrintCenterController(service);
    controller.init();
  });

  tearDown(() {
    controller.dispose();
  });

  testWidgets('Selecting second person issue test with real Db and functional pure UI bounds', (WidgetTester tester) async {
    // Ensures PdfPreview has defined bounds in headless runs to avoid infinite layout measure loops
    await applyPdfPreviewSurfaceWorkaround(tester);

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

    // Wait robustly for the Drift Database stream to emit participants and UI to rebuild
    await pumpUntilFound(tester, find.text('Antonín Dvořák'), timeout: const Duration(seconds: 15));
    
    print('--- Stage 1 Initial ---');
    print('Participants loaded: ${controller.participants.length}');

    // Karel is #7 on the alphabetical list, placing him outside the default 
    // 800x600 test screen bounds. We must explicitly drag the list up.
    final karelFinder = find.text('Karel Čapek');
    
    // Custom robust scroll loop targeting the actual ListView, as there may be
    // multiple Scrollables in the scaffold.
    print('[VERBOSE] Starting drag loop to find Karel Čapek...');
    for (int i = 0; i < 10; i++) {
      final found = karelFinder.evaluate().isNotEmpty;
      print('[VERBOSE] Drag loop $i to find Karel. found=$found');
      if (found) break;
      // Drag strongly upwards (scroll down) on the generic Scrollable
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -300));
      await tester.pump(const Duration(milliseconds: 100));
    }
    print('[VERBOSE] Drag loop for Karel finished.');

    // Verify Karel Čapek is there after scrolling
    expect(karelFinder, findsWidgets, reason: 'Karel Čapek should be visible after scrolling');

    // 2. Select first person (Karel)
    print('\nSelecting Karel...');
    await tester.tap(karelFinder.first);
    
    // Give it a moment to render the details (PdfPreview spins a CircularProgressIndicator)
    // Avoid pumpAndSettle here because the indeterminate progress indicator causes FakeAsync exhaustion
    await tester.pump(const Duration(seconds: 1));
    
    // 3. Confirm simulation (Stage 3)
    print('\nSimulating print success...');
    
    // Wrap the SQLite database write in runAsync to break out of the FakeAsync zone. 
    // This allows the real Dart event loop to process microtasks and gracefully settle 
    // the Drift stream read/write locks, completely eliminating the 60s deadlock.
    await tester.runAsync(() async {
      await controller.confirmPrintResult(PrintSimulationResult.success);
    });
    
    // Pump the FakeAsync clock to allow the UI to react to the completed Future
    await tester.pump(const Duration(milliseconds: 500));

    if (!controller.simulatedPrinted) fail('Simulated print did not occur');

    print('SimulatedPrinted: ${controller.simulatedPrinted}');
    
    // 4. Reset flow (Nový tisk)
    print('\nResetting flow (Nový tisk)...');
    controller.resetFlow();
    
    // Wait robustly for the state machine to reconstruct the UI and show the fresh list
    await pumpUntilFound(tester, find.text('Karel Čapek'), timeout: const Duration(seconds: 15));

    print('\n--- Stage 1 After Reset ---');
    print('Participants loaded: ${controller.participants.length}');

    // 5. Try to find Antonín (who should be #1 on the fresh list, so we might need to scroll UP)
    final nextPersonFinder = find.text('Antonín Dvořák');
    
    // Custom robust scroll loop UPWARDS (scroll list down to top)
    print('[VERBOSE] Starting drag loop to find Antonín Dvořák...');
    for (int i = 0; i < 10; i++) {
      final found = nextPersonFinder.evaluate().isNotEmpty;
      print('[VERBOSE] Drag loop $i to find Antonín. found=$found');
      if (found) break;
      // Drag strongly downwards (scroll up) on the generic Scrollable
      await tester.drag(find.byType(Scrollable).first, const Offset(0, 300));
      await tester.pump(const Duration(milliseconds: 100));
    }
    print('[VERBOSE] Drag loop for Antonín finished.');

    print('\nFinder found Antonín: ${nextPersonFinder.evaluate().length} widgets');

    if (nextPersonFinder.evaluate().isEmpty) {
      fail('Antonín not found - State machine failed to reconstruct UI selection correctly');
    } else {
      print('\n[SUCCESS] Antonín found! Tapping...');
      await tester.tap(nextPersonFinder.first);
      
      // Explicit pump to bypass PdfPreview spinner hang
      await tester.pump(const Duration(seconds: 1));
      print('Selected: ${controller.selected?.jmeno} ${controller.selected?.prijmeni}');
    }
  });
}
