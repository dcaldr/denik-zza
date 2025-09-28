import 'package:denik_zza/input/csv_review_models.dart';
import 'package:denik_zza/input/input_parser.dart';
import 'package:denik_zza/screens2/csv_review/csv_review_screen.dart';
import 'package:denik_zza/services/csv_import_service.dart';
import 'package:denik_zza/services/mock/csv_review_service_mock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CsvReviewScreen', () {
    testWidgets('renders summary counts and unparsed columns', (WidgetTester tester) async {
      final CsvImportSession session = _buildSampleSession();
      final CsvReviewServiceMock mockService = CsvReviewServiceMock.fixed(session: session);

      await tester.pumpWidget(
        MaterialApp(
          home: CsvReviewScreen(
            filePath: 'sample.csv',
            service: mockService,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('CsvReviewScreen_unparsed_columns_tile')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('CsvReviewScreen_summary_rejected_count')), findsOneWidget);
      expect(find.byKey(const Key('CsvReviewScreen_summary_warn_count')), findsOneWidget);
      expect(find.byKey(const Key('CsvReviewScreen_unparsed_column_0')), findsOneWidget);
      expect(find.byKey(const Key('CsvReviewScreen_row_1')), findsOneWidget);
      expect(mockService.loadInvocations, 1);
    });

    testWidgets('switching tabs filters rows by status', (WidgetTester tester) async {
      final CsvImportSession session = _buildSampleSession();
      final CsvReviewServiceMock mockService = CsvReviewServiceMock.fixed(session: session);

      await tester.pumpWidget(
        MaterialApp(
          home: CsvReviewScreen(
            filePath: 'sample.csv',
            service: mockService,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('CsvReviewScreen_tab_warn')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('CsvReviewScreen_row_2')), findsOneWidget);
      expect(find.byKey(const Key('CsvReviewScreen_row_1')), findsNothing);

      await tester.tap(find.byKey(const Key('CsvReviewScreen_tab_ok')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('CsvReviewScreen_row_4')), findsOneWidget);
    });

    testWidgets('shows error placeholder when load fails', (WidgetTester tester) async {
      final CsvReviewServiceMock mockService = CsvReviewServiceMock(
        onLoad: (_) async => throw Exception('boom'),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: CsvReviewScreen(
            filePath: 'sample.csv',
            service: mockService,
          ),
        ),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('CsvReviewScreen_error_text')), findsOneWidget);
      expect(mockService.loadInvocations, 1);
    });

    testWidgets('allows editing row and updates UI', (WidgetTester tester) async {
      final CsvImportSession session = _buildSampleSession();
      final CsvReviewRow updatedRow = CsvReviewRow(
        originalIndex: 1,
        status: CsvRowReviewStatus.rejected,
        messages: <CsvReviewMessage>[
          CsvReviewMessage(
            severity: CsvReviewMessageSeverity.error,
            message: 'Řádek aktualizován',
          ),
        ],
        fields: <String, CsvFieldReview>{
          'jmeno': CsvFieldReview(
            columnKey: 'jmeno',
            columnName: 'Jméno',
            status: CsvFieldReviewStatus.ok,
            originalValue: 'Petr',
            normalizedValue: 'Petr',
            inferred: false,
          ),
          'prijmeni': CsvFieldReview(
            columnKey: 'prijmeni',
            columnName: 'Příjmení',
            status: CsvFieldReviewStatus.ok,
            originalValue: 'Novák',
            normalizedValue: 'Novák',
            inferred: false,
          ),
        },
        derived: <String, CsvDerivedValue>{},
      );

      final CsvReviewServiceMock mockService = CsvReviewServiceMock(
        onLoad: (_) async => session,
        onReparse: (Map<String, String?> payload) async => updatedRow,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: CsvReviewScreen(
            filePath: 'sample.csv',
            service: mockService,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('CsvReviewScreen_row_1_edit_button')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('CsvReviewScreen_edit_field_1_jmeno')),
        'Petr',
      );
      await tester.tap(find.byKey(const Key('CsvReviewScreen_edit_dialog_save')));
      await tester.pumpAndSettle();

      expect(mockService.reparseInvocations, 1);
      expect(mockService.lastReparsePayload?['jmeno'], 'Petr');
      expect(find.byKey(const Key('CsvReviewScreen_row_1_edited_badge')), findsOneWidget);
      expect(find.text('Řádek aktualizován'), findsOneWidget);
    });
  });
}

CsvImportSession _buildSampleSession() {
  final List<CsvReviewRow> rows = <CsvReviewRow>[
    _buildRow(1, CsvRowReviewStatus.rejected, 'Jméno chybí'),
    _buildRow(2, CsvRowReviewStatus.warn, 'Datum bylo dopočítáno'),
    _buildRow(3, CsvRowReviewStatus.info, 'Rodné číslo doplněno'),
    _buildRow(4, CsvRowReviewStatus.ok, 'Bez problémů'),
  ];
  final CsvImportReview review = CsvImportReview(
    unparsedColumns: <String>['neocekavany_sloupec'],
    rows: rows,
  );
  return CsvImportSession(
    review: review,
    personResult: PersonResult(<Answer>[], review: review),
  );
}

CsvReviewRow _buildRow(int index, CsvRowReviewStatus status, String message) {
  final CsvReviewMessageSeverity severity = _severityForStatus(status);
  return CsvReviewRow(
    originalIndex: index,
    status: status,
    messages: <CsvReviewMessage>[
      CsvReviewMessage(severity: severity, message: message),
    ],
    fields: <String, CsvFieldReview>{
      'jmeno': CsvFieldReview(
        columnKey: 'jmeno',
        columnName: 'Jméno',
        status: CsvFieldReviewStatus.ok,
        originalValue: 'Jan',
        normalizedValue: 'Jan',
        inferred: false,
      ),
      'prijmeni': CsvFieldReview(
        columnKey: 'prijmeni',
        columnName: 'Příjmení',
        status: CsvFieldReviewStatus.ok,
        originalValue: 'Novák',
        normalizedValue: 'Novák',
        inferred: false,
      ),
    },
    derived: <String, CsvDerivedValue>{},
  );
}

CsvReviewMessageSeverity _severityForStatus(CsvRowReviewStatus status) {
  switch (status) {
    case CsvRowReviewStatus.rejected:
      return CsvReviewMessageSeverity.error;
    case CsvRowReviewStatus.warn:
      return CsvReviewMessageSeverity.warn;
    case CsvRowReviewStatus.info:
      return CsvReviewMessageSeverity.info;
    case CsvRowReviewStatus.ok:
      return CsvReviewMessageSeverity.info;
  }
}
