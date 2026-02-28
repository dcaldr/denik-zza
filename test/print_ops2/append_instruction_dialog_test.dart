import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:denik_zza/print_ops2/widgets/append_instruction_dialog.dart';
import 'package:denik_zza/print_ops2/print_center_controller.dart';
import 'package:denik_zza/print_ops2/models/append_analysis.dart';
import 'package:denik_zza/print_ops2/print_center_service.dart';
import 'package:denik_zza/database/database_wrapper.dart';
import 'package:denik_zza/database/drift_database/database.dart';



class FakePrintCenterController extends PrintCenterController {
  FakePrintCenterController() : super(PrintCenterService());

  AppendAnalysis? _analysis;
  bool? _printerPage1OnTop;
  String? _error;

  @override
  AppendAnalysis? get appendAnalysis => _analysis;

  @override
  bool? get printerPage1OnTop => _printerPage1OnTop;
  
  @override
  String? get analysisError => _error;

  @override
  Future<void> analyzeAppendScenario() async {
    // No-op: state is set manually via setScenario
  }

  void setScenario({
    required AppendAnalysis analysis,
    bool? printerPage1OnTop,
    String? error,
  }) {
    _analysis = analysis;
    _printerPage1OnTop = printerPage1OnTop;
    _error = error;
    notifyListeners();
  }
}

void main() {
  late FakePrintCenterController mockController;

  setUp(() {
    DatabaseWrapper.useTestDriftDatabase(AppDatabase.testInMemory());
    mockController = FakePrintCenterController();
  });
  
  tearDown(() async {
    await DatabaseWrapper.dispose();
  });

  Future<void> showDialogInTest(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Center(
              child: ElevatedButton(
                child: const Text('Show Dialog'),
                onPressed: () {
                  showDialog<bool>(
                    context: context,
                    builder: (_) => AppendInstructionDialog(
                      controller: mockController,
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Show Dialog'));
    
    // Pump to process tap and show dialog
    await tester.pump(); 
    
    // Pump to start animations
    await tester.pump();
    
    // Pump to allow analysis to complete
    await tester.pump(const Duration(milliseconds: 100)); 

    // Force another pump to ensure setState build happens
    await tester.pump();
  }

  testWidgets('Scenario: First Print (Baseline=0)', (tester) async {
    mockController.setScenario(
      analysis: AppendAnalysis(
        baselinePages: 0,
        pagesAfterFirst: 1,
        finalPages: 1,
        reusedLastPage: false,
        insertionPage: 1,
        hideHeaderOnPage: -1,
      ),
    );

    await showDialogInTest(tester);

    expect(find.text('Vložte 1 prázdných listů.'), findsOneWidget);

    // Actually Logic: if (page1Callback == null) -> Show warning.
    // In Mock, default is null. So it SHOULD show warning.
    
    expect(find.text('Tiskárna není kalibrována! Pořadí stránek nemusí odpovídat.'), findsOneWidget);
  });

  testWidgets('Scenario: Fits on Last (Normal Order)', (tester) async {
    mockController.setScenario(
      analysis: AppendAnalysis(
        baselinePages: 3,
        pagesAfterFirst: 3,
        finalPages: 3,
        reusedLastPage: true,
        insertionPage: 3,
        hideHeaderOnPage: 3, // hide header on reused page
      ),
      printerPage1OnTop: true, // Normal order
    );

    await showDialogInTest(tester);

    expect(find.text('Stránka 3 (existující)*'), findsOneWidget);
    expect(find.text('Tiskárna není kalibrována! Pořadí stránek nemusí odpovídat.'), findsNothing);
  });

   testWidgets('Scenario: Fits on Last (Reverse Order)', (tester) async {
    mockController.setScenario(
      analysis: AppendAnalysis(
        baselinePages: 3,
        pagesAfterFirst: 3,
        finalPages: 3,
        reusedLastPage: true, // Reuse page 3
        insertionPage: 3,
        hideHeaderOnPage: 3, 
      ),
      printerPage1OnTop: false, // Reverse order
    );

    await showDialogInTest(tester);

    // Matches fit on last logic
    expect(find.text('Stránka 3 (existující)*'), findsOneWidget);
  });

  testWidgets('Scenario: Overflows New Pages (Normal Order)', (tester) async {
    mockController.setScenario(
      analysis: AppendAnalysis(
        baselinePages: 2,
        pagesAfterFirst: 2, // First new fit on 2
        finalPages: 4,      // But more added to 3, 4
        reusedLastPage: true,
        insertionPage: 2,
        hideHeaderOnPage: 2,
      ),
      printerPage1OnTop: true,
    );

    await showDialogInTest(tester);

    // Expect: Page 2 (existing) THEN 2 x blank
    final existingFinder = find.text('Stránka 2 (existující)*');
    final blankFinder = find.text('2 x prázdný list');

    expect(existingFinder, findsOneWidget);
    expect(blankFinder, findsOneWidget);

    // Verify order: existing first
    final existingParams = tester.getTopLeft(existingFinder).dy;
    final blankParams = tester.getTopLeft(blankFinder).dy;
    expect(existingParams, lessThan(blankParams), reason: 'Existing should be above blank in normal order');
  });

  testWidgets('Scenario: Overflows New Pages (Reverse Order)', (tester) async {
    mockController.setScenario(
      analysis: AppendAnalysis(
        baselinePages: 2,
        pagesAfterFirst: 2, 
        finalPages: 4,      
        reusedLastPage: true,
        insertionPage: 2,
        hideHeaderOnPage: 2,
      ),
      printerPage1OnTop: false, // Reverse
    );

    await showDialogInTest(tester);

    // Expect: 2 x blank THEN Page 2 (existing)
    final existingFinder = find.text('Stránka 2 (existující)*');
    final blankFinder = find.text('2 x prázdný list');

    expect(existingFinder, findsOneWidget);
    expect(blankFinder, findsOneWidget);

    // Verify order: blank first
    final existingParams = tester.getTopLeft(existingFinder).dy;
    final blankParams = tester.getTopLeft(blankFinder).dy;
    expect(blankParams, lessThan(existingParams), reason: 'Blank should be above existing in reverse order');
  });

  testWidgets('Scenario: All New Pages (No Reuse)', (tester) async {
    mockController.setScenario(
      analysis: AppendAnalysis(
        baselinePages: 2,
        pagesAfterFirst: 3, // Starts on new page 3
        finalPages: 3,
        reusedLastPage: false,
        insertionPage: 3,
        hideHeaderOnPage: -1,
      ),
      printerPage1OnTop: true,
    );

    await showDialogInTest(tester);


    // Actually logic for this scenario: 
    // if reusedLastPage=false (allNewPages), we just ask for finalPages count of blank sheets?
    // Wait, check implementation:
    // case _AppendScenario.allNewPages:
    //    if (scenario == _AppendScenario.allNewPages) {
    //        pagesToLoad.add('${a.finalPages} x prázdný list');
    //    }
    // This seems like a bug or simplification in the implementation? 
    // If baseline is 2, and we print to 3... shouldn't we insert 1 blank page (page 3)?
    // The instructions usually say "Insert X blank sheets" to the printer tray.
    // If I have 2 printed, and I want to print page 3... I put 1 sheet in.
    // 
    // Implementation says:
    // final newPagesCount = a.finalPages - (a.reusedLastPage ? a.baselinePages : a.baselinePages);
    // -> 3 - 2 = 1.
    // So logic `if (newPagesCount > 0)` adds `1 x prázdný list`.
    // The `else if (scenario == allNewPages)` block is fallback.
    // 
    // Let's verify what `newPagesCount` evaluates to.
    // 3 - 2 = 1.
    // So it should say '1 x prázdný list'.
    
    expect(find.text('1 x prázdný list'), findsOneWidget);
  });
}
