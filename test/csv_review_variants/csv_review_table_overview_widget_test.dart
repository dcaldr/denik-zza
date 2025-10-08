import 'package:denik_zza/input/csv_review_models.dart';
import 'package:denik_zza/input/input_parser.dart';
import 'package:denik_zza/screens2/csv_review_variants/card_gallery_screen.dart';
import 'package:denik_zza/screens2/csv_review_variants/checklist_screen.dart';
import 'package:denik_zza/screens2/csv_review_variants/split_workspace_screen.dart';
import 'package:denik_zza/screens2/csv_review_variants/table_overview_screen.dart';
import 'package:denik_zza/services/csv_import_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('table overview renders rows and supports inline actions', (WidgetTester tester) async {
    final TestWidgetsFlutterBinding binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.window.physicalSizeTestValue = const Size(1600, 1200);
    binding.window.devicePixelRatioTestValue = 1.0;
    addTearDown(() {
      binding.window.clearPhysicalSizeTestValue();
      binding.window.clearDevicePixelRatioTestValue();
    });

    final _WidgetFakeService service = _WidgetFakeService();

    await tester.pumpWidget(
      MaterialApp(
        home: CsvReviewTableOverviewScreen(
          filePath: 'ignored.csv',
          service: service,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byKey(const Key('CsvTableOverview_table')), findsOneWidget);

    final TextFormField genderField = tester.widget<TextFormField>(
      find.byKey(const Key('CsvTableOverview_cell_1_pohlavi')),
    );
    expect(genderField.controller?.text, equals('Muž'));

    final TextFormField birthField = tester.widget<TextFormField>(
      find.byKey(const Key('CsvTableOverview_cell_1_datum_narozeni')),
    );
    expect(birthField.controller?.text, equals('01.01.2010'));

    // Worst statuses appear first (warn row above ok row).
    final Offset warnPosition = tester.getTopLeft(find.text('Varování'));
    final Offset okPosition = tester.getTopLeft(find.text('V pořádku'));
    expect(warnPosition.dy, lessThan(okPosition.dy));

    // Edit cell inline and ensure service receives payload.
    await tester.tap(find.byKey(const Key('CsvTableOverview_cell_1_jmeno')));
    await tester.enterText(
      find.byKey(const Key('CsvTableOverview_cell_1_jmeno')),
      'Karolina',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(service.lastPayload?['jmeno'], equals('Karolina'));

    await tester.enterText(
      find.byKey(const Key('CsvTableOverview_cell_1_pohlavi')),
      'Žena',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(service.lastPayload?['pohlavi'], equals('2'));
  });

  testWidgets('card gallery renders grouped sections', (WidgetTester tester) async {
    final TestWidgetsFlutterBinding binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.window.physicalSizeTestValue = const Size(1600, 1200);
    binding.window.devicePixelRatioTestValue = 1.0;
    addTearDown(() {
      binding.window.clearPhysicalSizeTestValue();
      binding.window.clearDevicePixelRatioTestValue();
    });

    final _WidgetFakeService service = _WidgetFakeService();

    await tester.pumpWidget(
      MaterialApp(
        home: CsvReviewCardGalleryScreen(
          filePath: 'ignored.csv',
          service: service,
        ),
      ),
    );

    await tester.pumpAndSettle();

  expect(find.text('Galerie záznamů CSV'), findsOneWidget);
  expect(find.byKey(const Key('CsvCardGallery_refresh')), findsOneWidget);
  expect(find.textContaining('Soubor obsahuje'), findsOneWidget);
  });

  testWidgets('checklist shows step cards', (WidgetTester tester) async {
    final TestWidgetsFlutterBinding binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.window.physicalSizeTestValue = const Size(1600, 1200);
    binding.window.devicePixelRatioTestValue = 1.0;
    addTearDown(() {
      binding.window.clearPhysicalSizeTestValue();
      binding.window.clearDevicePixelRatioTestValue();
    });

    final _WidgetFakeService service = _WidgetFakeService();

    await tester.pumpWidget(
      MaterialApp(
        home: CsvReviewChecklistScreen(
          filePath: 'ignored.csv',
          service: service,
        ),
      ),
    );

    await tester.pumpAndSettle();

  expect(find.text('Kontrolní seznam importu CSV'), findsOneWidget);
  expect(find.byType(NavigationRail), findsOneWidget);
  expect(find.textContaining('Souhrn'), findsOneWidget);
  });

  testWidgets('split workspace shows list and detail', (WidgetTester tester) async {
    final TestWidgetsFlutterBinding binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.window.physicalSizeTestValue = const Size(1600, 1200);
    binding.window.devicePixelRatioTestValue = 1.0;
    addTearDown(() {
      binding.window.clearPhysicalSizeTestValue();
      binding.window.clearDevicePixelRatioTestValue();
    });

    final _WidgetFakeService service = _WidgetFakeService();

    await tester.pumpWidget(
      MaterialApp(
        home: CsvReviewSplitWorkspaceScreen(
          filePath: 'ignored.csv',
          service: service,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Dvou-panelový přehled CSV'), findsOneWidget);
    expect(find.byKey(const Key('CsvSplitWorkspace_rowList')), findsOneWidget);
    expect(find.byType(TabBar), findsOneWidget);
  });
}

class _WidgetFakeService implements CsvReviewService {
  _WidgetFakeService()
      : _rows = <CsvReviewRow>[
          _buildRow(1, 'Alena', 'Nováková'),
          _buildRow(2, 'Jana', 'Svobodová', status: CsvRowReviewStatus.warn),
        ];

  final List<CsvReviewRow> _rows;
  Map<String, String?>? lastPayload;

  @override
  Future<CsvImportSession> loadCsv(String path) async {
    return CsvImportSession(
      review: CsvImportReview(
        unparsedColumns: const <String>[],
        rows: _rows,
      ),
      personResult: PersonResult(<Answer>[]),
    );
  }

  @override
  Future<CsvReviewRow> reparseRow(Map<String, String?> updatedFields) async {
    lastPayload = Map<String, String?>.from(updatedFields);
    final CsvReviewRow existing = _rows.first;
    final Map<String, CsvFieldReview> newFields = existing.fields.map(
      (String key, CsvFieldReview field) => MapEntry<String, CsvFieldReview>(
        key,
        CsvFieldReview(
          columnKey: field.columnKey,
          columnName: field.columnName,
          status: field.status,
          originalValue: updatedFields[key] ?? field.originalValue,
          normalizedValue: updatedFields[key] ?? field.normalizedValue,
          inferred: field.inferred,
          messages: field.messages,
        ),
      ),
    );
    final CsvReviewRow updated = CsvReviewRow(
      originalIndex: existing.originalIndex,
      status: existing.status,
      messages: existing.messages,
      fields: newFields,
      derived: existing.derived,
    );
    _rows[0] = updated;
    return updated;
  }

  @override
  Future<CsvFinalizeResult> finalizeImport({
    required CsvImportSession session,
    required Map<int, CsvRowDecision> decisions,
  }) async {
    return CsvFinalizeResult(
      approvedCount: decisions.values
          .where((CsvRowDecision decision) => decision == CsvRowDecision.approved)
          .length,
      rejectedCount: decisions.values
          .where((CsvRowDecision decision) => decision == CsvRowDecision.rejected)
          .length,
      savedRowIndices: const <int>[],
      failures: const <CsvFinalizeFailure>[],
    );
  }

  @override
  Future<Map<int, List<CsvDuplicateCandidate>>> findPotentialDuplicates({
    required CsvImportSession session,
  }) async {
    return const <int, List<CsvDuplicateCandidate>>{};
  }
}

CsvReviewRow _buildRow(
  int index,
  String firstName,
  String lastName, {
  CsvRowReviewStatus status = CsvRowReviewStatus.ok,
}) {
  return CsvReviewRow(
    originalIndex: index,
    status: status,
    messages: const <CsvReviewMessage>[],
    fields: <String, CsvFieldReview>{
      'jmeno': CsvFieldReview(
        columnKey: 'jmeno',
        columnName: 'Jméno',
        status: CsvFieldReviewStatus.ok,
        originalValue: firstName,
        normalizedValue: firstName,
        inferred: false,
      ),
      'prijmeni': CsvFieldReview(
        columnKey: 'prijmeni',
        columnName: 'Příjmení',
        status: CsvFieldReviewStatus.ok,
        originalValue: lastName,
        normalizedValue: lastName,
        inferred: false,
      ),
      'pohlavi': CsvFieldReview(
        columnKey: 'pohlavi',
        columnName: 'Pohlaví',
        status: CsvFieldReviewStatus.ok,
        originalValue: '1',
        normalizedValue: '1',
        inferred: false,
      ),
      'datum_narozeni': CsvFieldReview(
        columnKey: 'datum_narozeni',
        columnName: 'Datum narození',
        status: CsvFieldReviewStatus.ok,
        originalValue: '2010-01-01',
        normalizedValue: '2010-01-01',
        inferred: false,
      ),
    },
    derived: <String, CsvDerivedValue>{
      'datum_narozeni': CsvDerivedValue(
        key: 'datum_narozeni',
        value: '01.01.2010',
        applied: true,
      ),
    },
  );
}
