import 'package:denik_zza/screens2/csv/summary_screen.dart';
import 'package:denik_zza/services/csv_import_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders badges and failure list when result has errors',
      (WidgetTester tester) async {
    final CsvFinalizeResult result = CsvFinalizeResult(
      approvedCount: 3,
      rejectedCount: 1,
      savedRowIndices: <int>[1, 2, 3],
      failures: <CsvFinalizeFailure>[
        CsvFinalizeFailure(originalIndex: 4, message: 'Duplicitní číslo pojištěnce'),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: CsvImportSummaryScreen(
          result: result,
          importFileLabel: 'test.csv',
        ),
      ),
    );

    expect(find.byKey(const Key('CsvSummary_badge_approved')), findsOneWidget);
    expect(find.byKey(const Key('CsvSummary_badge_rejected')), findsOneWidget);
    expect(find.byKey(const Key('CsvSummary_badge_saved')), findsOneWidget);
    expect(find.byKey(const Key('CsvSummary_badge_failed')), findsOneWidget);
    expect(find.byKey(const Key('CsvSummary_failure_4')), findsOneWidget);
    expect(
      find.text('Soubor: test.csv'),
      findsOneWidget,
    );
    expect(
      find.text('Nepodařilo se uložit některé řádky. Zkontrolujte jejich hlášení:'),
      findsOneWidget,
    );
  });

  testWidgets('shows success message when there are no failures',
      (WidgetTester tester) async {
    final CsvFinalizeResult result = CsvFinalizeResult(
      approvedCount: 2,
      rejectedCount: 0,
      savedRowIndices: <int>[1, 2],
      failures: const <CsvFinalizeFailure>[],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: CsvImportSummaryScreen(
          result: result,
          importFileLabel: 'bez_chyb.csv',
        ),
      ),
    );

    expect(
      find.text('Všechny vybrané řádky byly úspěšně uloženy.'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('CsvSummary_failure_1')), findsNothing);
  });

  testWidgets('return button pops routes back to root',
      (WidgetTester tester) async {
    final CsvFinalizeResult result = CsvFinalizeResult(
      approvedCount: 1,
      rejectedCount: 0,
      savedRowIndices: const <int>[1],
      failures: const <CsvFinalizeFailure>[],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (BuildContext context) {
            return Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push<void>(
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) => CsvImportSummaryScreen(
                          result: result,
                          importFileLabel: 'flow.csv',
                        ),
                      ),
                    );
                  },
                  child: const Text('Start flow'),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Start flow'));
    await tester.pumpAndSettle();
    expect(find.byType(CsvImportSummaryScreen), findsOneWidget);

    await tester.tap(find.byKey(const Key('CsvSummary_return_button')));
    await tester.pumpAndSettle();

    expect(find.byType(CsvImportSummaryScreen), findsNothing);
  });
}
