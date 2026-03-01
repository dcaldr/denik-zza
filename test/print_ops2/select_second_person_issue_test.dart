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
    

    // Karel is #7 on the alphabetical list, placing him outside the default 
    // 800x600 test screen bounds. We must explicitly drag the list up.
    final karelFinder = find.text('Karel Čapek');
    
    await dragUntilVisibleRobustly(
      tester,
      finder: karelFinder,
      dragOffset: const Offset(0, -300),
    );

    // Verify Karel Čapek is there after scrolling
    expect(karelFinder, findsWidgets, reason: 'Karel Čapek should be visible after scrolling');

    // 2. Select first person (Karel)
    await tester.tap(karelFinder.first);
    
    // Give it a moment to render the details (PdfPreview spins a CircularProgressIndicator)
    // Avoid pumpAndSettle here because the indeterminate progress indicator causes FakeAsync exhaustion
    await tester.pump(const Duration(seconds: 1));
    
    // 3. Confirm simulation (Stage 3)
    
    // Wrap the SQLite database write in runAsync to break out of the FakeAsync zone. 
    // This allows the real Dart event loop to process microtasks and gracefully settle 
    // the Drift stream read/write locks, completely eliminating the 60s deadlock.
    await tester.runAsync(() async {
      await controller.confirmPrintResult(PrintSimulationResult.success);
    });
    
    // Pump the FakeAsync clock to allow the UI to react to the completed Future
    await tester.pump(const Duration(milliseconds: 500));

    if (!controller.simulatedPrinted) fail('Simulated print did not occur');

    
    // 4. Reset flow (Nový tisk)
    controller.resetFlow();
    
    // Wait robustly for the state machine to reconstruct the UI and show the fresh list
    await pumpUntilFound(tester, find.text('Karel Čapek'), timeout: const Duration(seconds: 15));


    // 5. Try to find Antonín (who should be #1 on the fresh list, so we might need to scroll UP)
    final nextPersonFinder = find.text('Antonín Dvořák');
    
    await dragUntilVisibleRobustly(
      tester,
      finder: nextPersonFinder,
      dragOffset: const Offset(0, 300),
    );


    if (nextPersonFinder.evaluate().isEmpty) {
      fail('Antonín not found - State machine failed to reconstruct UI selection correctly');
    } else {
      await tester.tap(nextPersonFinder.first);
      
      // Explicit pump to bypass PdfPreview spinner hang
      await tester.pump(const Duration(seconds: 1));
    }
  });
}
