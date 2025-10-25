import 'package:denik_zza/input/csv_review_models.dart';
import 'package:denik_zza/input/input_parser.dart';
import 'package:denik_zza/screens2/csv_review/csv_review_screen.dart';
import 'package:denik_zza/services/csv_import_service.dart';
import 'package:denik_zza/services/mock/csv_review_service_mock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pumpReviewScreen(
  WidgetTester tester, {
  required CsvImportService service,
  String filePath = 'sample.csv',
}) async {
  final TestWidgetsFlutterBinding binding = TestWidgetsFlutterBinding.ensureInitialized();
  binding.window.physicalSizeTestValue = const Size(1280, 2000);
  binding.window.devicePixelRatioTestValue = 1.0;
  addTearDown(() {
    binding.window.clearPhysicalSizeTestValue();
    binding.window.clearDevicePixelRatioTestValue();
  });

  await tester.pumpWidget(
    MaterialApp(
      home: CsvReviewScreen(
        filePath: filePath,
        service: service,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('CsvReviewScreen', () {
    testWidgets('renders summary counts and unparsed columns', (WidgetTester tester) async {
      final CsvImportSession session = _buildSampleSession();
      final CsvReviewServiceMock mockService = CsvReviewServiceMock.fixed(session: session);

      await _pumpReviewScreen(tester, service: mockService);
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

      await _pumpReviewScreen(tester, service: mockService);

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

      await _pumpReviewScreen(tester, service: mockService);

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

      await _pumpReviewScreen(tester, service: mockService);

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

    testWidgets('supports inline editing for simple fields', (WidgetTester tester) async {
      final CsvImportSession session = _buildSampleSession();
      final CsvReviewRow updatedRow = CsvReviewRow(
        originalIndex: 1,
        status: CsvRowReviewStatus.warn,
        messages: <CsvReviewMessage>[
          CsvReviewMessage(
            severity: CsvReviewMessageSeverity.warn,
            message: 'Jméno upraveno',
          ),
        ],
        fields: <String, CsvFieldReview>{
          'jmeno': CsvFieldReview(
            columnKey: 'jmeno',
            columnName: 'Jméno',
            status: CsvFieldReviewStatus.ok,
            originalValue: 'Jana',
            normalizedValue: 'Jana',
            inferred: false,
          ),
          'prijmeni': session.review.rows.first.fields['prijmeni']!,
        },
        derived: <String, CsvDerivedValue>{},
      );

      final CsvReviewServiceMock mockService = CsvReviewServiceMock(
        onLoad: (_) async => session,
        onReparse: (Map<String, String?> payload) async => updatedRow,
      );

      await _pumpReviewScreen(tester, service: mockService);

      await tester.tap(find.byKey(const Key('CsvReviewScreen_row_1_fields_tile')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('CsvReviewScreen_inline_field_jmeno_edit_button')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('CsvReviewScreen_inline_field_jmeno_input')),
        'Jana',
      );

      await tester.tap(find.byKey(const Key('CsvReviewScreen_inline_field_jmeno_save')));
      await tester.pumpAndSettle();

      expect(mockService.reparseInvocations, 1);
      expect(mockService.lastReparsePayload?['jmeno'], 'Jana');
      await tester.tap(find.byKey(const Key('CsvReviewScreen_tab_warn')));
      await tester.pumpAndSettle();
      expect(find.text('Jméno upraveno'), findsOneWidget);
    });

    testWidgets('bulk approve presets decisions and counters', (WidgetTester tester) async {
      final CsvImportSession session = _buildSampleSession();
      final CsvReviewServiceMock mockService = CsvReviewServiceMock.fixed(session: session);

      await _pumpReviewScreen(tester, service: mockService);

      await tester.tap(find.byKey(const Key('CsvReviewScreen_bulk_approve_info')));
      await tester.pumpAndSettle();

      final Chip approvedChip = tester.widget<Chip>(
        find.byKey(const Key('CsvReviewScreen_bulk_approved_count')),
      );
      expect((approvedChip.label as Text).data, 'Schváleno: 2');

      await tester.tap(find.byKey(const Key('CsvReviewScreen_tab_info')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('CsvReviewScreen_row_3_decision_chip')), findsOneWidget);

      await tester.tap(find.byKey(const Key('CsvReviewScreen_tab_ok')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('CsvReviewScreen_row_4_decision_chip')), findsOneWidget);

      await tester.tap(find.byKey(const Key('CsvReviewScreen_tab_warn')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('CsvReviewScreen_row_2_decision_chip')), findsNothing);

      await tester.tap(find.byKey(const Key('CsvReviewScreen_bulk_clear_approvals')));
      await tester.pumpAndSettle();

      final Chip clearedChip = tester.widget<Chip>(
        find.byKey(const Key('CsvReviewScreen_bulk_approved_count')),
      );
      expect((clearedChip.label as Text).data, 'Schváleno: 0');

      await tester.tap(find.byKey(const Key('CsvReviewScreen_tab_info')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('CsvReviewScreen_row_3_decision_chip')), findsNothing);
    });

    testWidgets('finalize flow confirms decisions and reloads data', (WidgetTester tester) async {
      final CsvImportSession session = _buildSampleSession();
      final CsvFinalizeResult finalizeResult = CsvFinalizeResult(
        approvedCount: 2,
        rejectedCount: 1,
        savedRowIndices: const <int>[3, 4],
        failures: <CsvFinalizeFailure>[
          CsvFinalizeFailure(originalIndex: 2, message: 'Duplicitní záznam'),
        ],
      );
      final CsvReviewServiceMock mockService = CsvReviewServiceMock.fixed(
        session: session,
        finalizeResult: finalizeResult,
      );

      await _pumpReviewScreen(tester, service: mockService);

      final FilledButton finalizeButtonInitial = tester.widget<FilledButton>(
        find.byKey(const Key('CsvReviewScreen_finalize_button')),
      );
      expect(finalizeButtonInitial.onPressed, isNull);

      await tester.tap(find.byKey(const Key('CsvReviewScreen_bulk_approve_info')));
      await tester.pumpAndSettle();

      final FilledButton finalizeButtonEnabled = tester.widget<FilledButton>(
        find.byKey(const Key('CsvReviewScreen_finalize_button')),
      );
      expect(finalizeButtonEnabled.onPressed, isNotNull);

      await tester.tap(find.byKey(const Key('CsvReviewScreen_finalize_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('CsvReviewScreen_finalize_confirm_dialog')), findsOneWidget);
      expect(find.text('Schválíte: 2 řádků'), findsOneWidget);

      await tester.tap(find.byKey(const Key('CsvReviewScreen_finalize_confirm_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      expect(mockService.finalizeInvocations, 1);
      expect(mockService.lastFinalizeDecisions?[3], CsvRowDecision.approved);
      expect(mockService.lastFinalizeDecisions?[4], CsvRowDecision.approved);

      expect(find.byKey(const Key('CsvReviewScreen_finalize_summary_dialog')), findsOneWidget);
      expect(find.text('Uloženo: 2'), findsOneWidget);
      expect(find.text('Nepodařilo se uložit: 1'), findsOneWidget);

      await tester.tap(find.byKey(const Key('CsvReviewScreen_finalize_summary_close')));
      await tester.pumpAndSettle();

      expect(mockService.loadInvocations, 2);
    });

    testWidgets('shows duplicate warnings and skips bulk auto approvals', (WidgetTester tester) async {
      final CsvImportSession session = _buildSampleSession();
      final CsvDuplicateCandidate duplicate = CsvDuplicateCandidate(
        participantId: 42,
        displayName: 'Jan Novák (01.05.2010)',
        reason: 'Stejné rodné číslo',
      );
      final Map<int, List<CsvDuplicateCandidate>> duplicates = <int, List<CsvDuplicateCandidate>>{
        3: <CsvDuplicateCandidate>[duplicate],
      };
      final CsvReviewServiceMock mockService = CsvReviewServiceMock.fixed(
        session: session,
        duplicateMatches: duplicates,
      );

      await _pumpReviewScreen(tester, service: mockService);

      expect(mockService.findDuplicateInvocations, 1);
      await tester.tap(find.byKey(const Key('CsvReviewScreen_tab_info')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('CsvReviewScreen_row_3_duplicate_badge')), findsOneWidget);
      expect(find.textContaining('Možní duplicitní účastníci'), findsOneWidget);
      expect(find.text('• Jan Novák (01.05.2010) – Stejné rodné číslo'), findsOneWidget);
      expect(find.byKey(const Key('CsvReviewScreen_finalize_duplicates_count')), findsOneWidget);

      await tester.tap(find.byKey(const Key('CsvReviewScreen_bulk_approve_info')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('CsvReviewScreen_row_3_decision_chip')), findsNothing);
      final Chip approvedChip = tester.widget<Chip>(
        find.byKey(const Key('CsvReviewScreen_bulk_approved_count')),
      );
      expect((approvedChip.label as Text).data, 'Schváleno: 1');
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
