import 'package:denik_zza/input/csv_review_models.dart';
import 'package:denik_zza/input/input_parser.dart';
import 'package:denik_zza/screens2/csv_review_variants/table_overview_screen.dart';
import 'package:denik_zza/screens2/csv_review_variants/csv_review_shared.dart';
import 'package:denik_zza/services/csv_import_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('table overview renders rows and supports inline actions',
      (WidgetTester tester) async {
    final TestWidgetsFlutterBinding binding =
        TestWidgetsFlutterBinding.ensureInitialized();
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

    expect(find.byKey(const Key('CsvTableOverview_summary_content')),
        findsOneWidget);
    expect(
      find.byKey(const Key('CsvTableOverview_summary_rejected_count')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('CsvTableOverview_summary_warn_count')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('CsvTableOverview_summary_info_count')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('CsvTableOverview_summary_ok_count')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('CsvTableOverview_summary_total')),
        findsOneWidget);

    expect(find.byKey(const Key('CsvTableOverview_action_approve_all_valid')),
        findsOneWidget);
    final Finder approveSelectedFinder =
        find.byKey(const Key('CsvTableOverview_action_approve_selected'));
    expect(approveSelectedFinder, findsOneWidget);
    final OutlinedButton approveSelectedButton =
        tester.widget<OutlinedButton>(approveSelectedFinder);
    expect(approveSelectedButton.onPressed, isNull);
    expect(find.byKey(const Key('CsvTableOverview_action_reject_toggle')),
        findsOneWidget);

    expect(find.byKey(const Key('CsvTableOverview_table')), findsOneWidget);
    expect(find.text('Duplicitní?'), findsNothing);
    expect(
      find.byKey(const Key('CsvTableOverview_duplicate_indicator_2')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('CsvTableOverview_duplicate_indicator_1')),
      findsNothing,
    );
    expect(find.text('Nemá'), findsWidgets);

    final TextFormField genderField = tester.widget<TextFormField>(
      find.byKey(const Key('CsvTableOverview_cell_1_pohlavi')),
    );
    expect(genderField.controller?.text, equals('Muž'));

    final TextFormField birthField = tester.widget<TextFormField>(
      find.byKey(const Key('CsvTableOverview_cell_1_datum_narozeni')),
    );
    expect(birthField.controller?.text, equals('01.01.2010'));

    final TextFormField eligibleField = tester.widget<TextFormField>(
      find.byKey(const Key('CsvTableOverview_cell_1_zpusobilost')),
    );
    expect(eligibleField.controller?.text, equals('Má'));

    // Worst statuses appear first (warn row above ok row inside the table body).
    final Finder tableFinder = find.byKey(const Key('CsvTableOverview_table'));
    final Offset warnPosition = tester.getTopLeft(
      find.descendant(of: tableFinder, matching: find.text('Varování')).first,
    );
    final Offset okPosition = tester.getTopLeft(
      find.descendant(of: tableFinder, matching: find.text('V pořádku')).first,
    );
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

    final TextField updatedNameField = tester.widget<TextField>(
      find.descendant(
        of: find.byKey(const Key('CsvTableOverview_cell_1_jmeno')),
        matching: find.byType(TextField),
      ),
    );
    expect(updatedNameField.decoration?.suffixIcon, isNull);
    expect(updatedNameField.decoration?.filled, isTrue);

    await tester.enterText(
      find.byKey(const Key('CsvTableOverview_cell_1_pohlavi')),
      'Žena',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(service.lastPayload?['pohlavi'], equals('2'));

    await tester.enterText(
      find.byKey(const Key('CsvTableOverview_cell_1_zpusobilost')),
      'Nemá',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(service.lastPayload?['zpusobilost'], equals('false'));

    await tester.enterText(
      find.byKey(const Key('CsvTableOverview_cell_1_pohlavi')),
      'xx',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    final Finder statusChipFinder =
        find.byKey(const Key('CsvTableOverview_status_2'));
    expect(statusChipFinder, findsOneWidget);
    final Finder statusTooltipFinder = find.ancestor(
      of: statusChipFinder,
      matching: find.byType(Tooltip),
    );
    expect(statusTooltipFinder, findsOneWidget);
    final Tooltip statusTooltip =
        tester.widget<Tooltip>(statusTooltipFinder.first);
    expect(statusTooltip.message, contains('Varování'));
    expect(statusTooltip.message, contains('Chybí potvrzení od lékaře'));
    expect(statusTooltip.triggerMode, TooltipTriggerMode.tap);

    final Finder rowOneStatusChipFinder =
        find.byKey(const Key('CsvTableOverview_status_1'));
    expect(rowOneStatusChipFinder, findsOneWidget);
    final Finder rowOneStatusTooltipFinder = find.ancestor(
      of: rowOneStatusChipFinder,
      matching: find.byType(Tooltip),
    );
    expect(rowOneStatusTooltipFinder, findsOneWidget);
    final Tooltip rowOneStatusTooltip =
        tester.widget<Tooltip>(rowOneStatusTooltipFinder.first);
    expect(rowOneStatusTooltip.message, contains('Varování'));
    expect(rowOneStatusTooltip.message, contains('Neznámá hodnota pohlaví'));
    expect(rowOneStatusTooltip.message, contains('Rodné číslo'));
    expect(
      rowOneStatusTooltip.message,
      isNot(contains('Pohlaví bylo odvozeno z rodného čísla.')),
    );

    final Finder warningIconFinder = find.byKey(
      const Key('CsvTableOverview_field_warning_2_zpusobilost'),
    );
    expect(warningIconFinder, findsOneWidget);
    final Finder fieldTooltipFinder = find.ancestor(
      of: warningIconFinder,
      matching: find.byType(Tooltip),
    );
    expect(fieldTooltipFinder, findsOneWidget);
    final Tooltip fieldTooltip =
        tester.widget<Tooltip>(fieldTooltipFinder.first);
    expect(fieldTooltip.message, contains('Varování'));
    expect(fieldTooltip.message, contains('Chybí potvrzení od lékaře'));
    expect(fieldTooltip.triggerMode, TooltipTriggerMode.manual);

    await tester.tap(
      find.byKey(const Key('CsvTableOverview_cell_2_zpusobilost')),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Varování: Chybí potvrzení od lékaře'), findsOneWidget);

    final Finder genderIconFinder = find.byKey(
      const Key('CsvTableOverview_field_warning_1_pohlavi'),
    );
    expect(genderIconFinder, findsOneWidget);
    final Finder genderTooltipFinder = find.ancestor(
      of: genderIconFinder,
      matching: find.byType(Tooltip),
    );
    expect(genderTooltipFinder, findsOneWidget);
    final Tooltip genderTooltip =
        tester.widget<Tooltip>(genderTooltipFinder.first);
    expect(genderTooltip.message, contains('Neznámá hodnota pohlaví'));
    expect(genderTooltip.message, isNot(contains('Rodné číslo')));
    expect(
      genderTooltip.message,
      isNot(contains('Pohlaví bylo odvozeno z rodného čísla.')),
    );
    expect(genderTooltip.triggerMode, TooltipTriggerMode.manual);

    await tester.tap(
      find.byKey(const Key('CsvTableOverview_cell_1_pohlavi')),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(
      find.text('Varování: Neznámá hodnota pohlaví'),
      findsOneWidget,
    );
  });

  test('controller preserves row index after edits', () async {
    final _MisindexedService service = _MisindexedService();
    final CsvReviewPrototypeController controller =
        CsvReviewPrototypeController(
      filePath: 'ignored.csv',
      service: service,
    );

    await controller.load();

    final CsvReviewRow rowToEdit = controller.rows
        .firstWhere((CsvReviewRow row) => row.originalIndex == 2);
    final Map<String, String?> payload = controller.buildPayload(rowToEdit);
    payload['jmeno'] = 'Karolina';

    await controller.editRow(rowToEdit, payload);

    final List<int> indices =
        controller.rows.map((CsvReviewRow row) => row.originalIndex).toList();
    indices.sort();
    expect(indices, <int>[1, 2]);

    final CsvReviewRow updated = controller.rows
        .firstWhere((CsvReviewRow row) => row.originalIndex == 2);
    expect(updated.fields['jmeno']?.normalizedValue, 'Karolina');

    final int rowOneCount = controller.rows
        .where((CsvReviewRow row) => row.originalIndex == 1)
        .length;
    expect(rowOneCount, 1);
  });
}

class _WidgetFakeService implements CsvReviewService {
  _WidgetFakeService()
      : _rows = <CsvReviewRow>[
          _buildRow(
            1,
            'Alena',
            'Nováková',
            genderMessages: <CsvReviewMessage>[
              CsvReviewMessage(
                severity: CsvReviewMessageSeverity.info,
                message: 'Pohlaví bylo odvozeno z rodného čísla.',
                code: 'gender_inferred_from_rc',
              ),
            ],
          ),
          _buildRow(
            2,
            'Jana',
            'Svobodová',
            status: CsvRowReviewStatus.warn,
            eligible: false,
            messages: <CsvReviewMessage>[
              CsvReviewMessage(
                severity: CsvReviewMessageSeverity.warn,
                message: 'Chybí potvrzení od lékaře',
              ),
            ],
          ),
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
    final String? genderValue = updatedFields['pohlavi'];
    final bool invalidGender =
        genderValue != null && genderValue != '1' && genderValue != '2';
    final CsvReviewMessage genderMessage = CsvReviewMessage(
      severity: CsvReviewMessageSeverity.warn,
      message: 'Neznámá hodnota pohlaví',
      code: 'gender_unrecognized_input',
    );
    final CsvReviewMessage rodneCisloMessage = CsvReviewMessage(
      severity: CsvReviewMessageSeverity.warn,
      message: 'Rodné číslo má neplatný formát.',
      code: 'rc_invalid_format',
    );
    final Map<String, CsvFieldReview> newFields = <String, CsvFieldReview>{};
    existing.fields.forEach((String key, CsvFieldReview field) {
      final String? newValue = updatedFields[key] ?? field.normalizedValue;
      final bool isGenderField = key == 'pohlavi';
      final bool isRodneCisloField = key == 'rodne_cislo';
      final bool emitWarning = isGenderField && invalidGender;
      final bool carryRodneWarning = isRodneCisloField && invalidGender;
      final List<CsvReviewMessage> scopedMessages;
      if (emitWarning) {
        scopedMessages = <CsvReviewMessage>[genderMessage, rodneCisloMessage];
      } else if (carryRodneWarning) {
        scopedMessages = <CsvReviewMessage>[rodneCisloMessage];
      } else {
        scopedMessages = field.messages;
      }
      newFields[key] = CsvFieldReview(
        columnKey: field.columnKey,
        columnName: field.columnName,
        status: emitWarning
            ? CsvFieldReviewStatus.warn
            : (carryRodneWarning ? CsvFieldReviewStatus.warn : field.status),
        originalValue: newValue ?? field.originalValue,
        normalizedValue: newValue,
        inferred: field.inferred,
        messages: scopedMessages,
      );
    });

  final List<CsvReviewMessage> rowMessages = invalidGender
    ? <CsvReviewMessage>[genderMessage, rodneCisloMessage]
    : existing.messages;

    final CsvReviewRow updated = CsvReviewRow(
      originalIndex: existing.originalIndex,
      status: invalidGender ? CsvRowReviewStatus.warn : existing.status,
      messages: rowMessages,
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
          .where(
              (CsvRowDecision decision) => decision == CsvRowDecision.approved)
          .length,
      rejectedCount: decisions.values
          .where(
              (CsvRowDecision decision) => decision == CsvRowDecision.rejected)
          .length,
      savedRowIndices: const <int>[],
      failures: const <CsvFinalizeFailure>[],
    );
  }

  @override
  Future<Map<int, List<CsvDuplicateCandidate>>> findPotentialDuplicates({
    required CsvImportSession session,
  }) async {
    return <int, List<CsvDuplicateCandidate>>{
      2: <CsvDuplicateCandidate>[
        CsvDuplicateCandidate(
          participantId: 42,
          displayName: 'Jan Novák',
          reason: 'Shoda jména a data narození',
        ),
      ],
    };
  }
}

class _MisindexedService implements CsvReviewService {
  _MisindexedService()
      : _rows = <CsvReviewRow>[
          _buildRow(1, 'Alena', 'Nováková'),
          _buildRow(
            2,
            'Jana',
            'Svobodová',
            status: CsvRowReviewStatus.warn,
            messages: <CsvReviewMessage>[
              CsvReviewMessage(
                severity: CsvReviewMessageSeverity.warn,
                message: 'Chybí potvrzení od lékaře',
              ),
            ],
          ),
        ];

  final List<CsvReviewRow> _rows;

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
    final String newName = updatedFields['jmeno'] ?? 'Jana';
    final CsvReviewRow updated = _buildRow(
      1,
      newName,
      'Svobodová',
      status: CsvRowReviewStatus.warn,
    );
    return updated;
  }

  @override
  Future<CsvFinalizeResult> finalizeImport({
    required CsvImportSession session,
    required Map<int, CsvRowDecision> decisions,
  }) async {
    return CsvFinalizeResult(
      approvedCount: 0,
      rejectedCount: 0,
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
  bool eligible = true,
  List<CsvReviewMessage> messages = const <CsvReviewMessage>[],
  List<CsvReviewMessage> rodneCisloMessages = const <CsvReviewMessage>[],
  List<CsvReviewMessage> genderMessages = const <CsvReviewMessage>[],
}) {
  final List<CsvReviewMessage> rowMessages = <CsvReviewMessage>[
    ...messages,
    ...rodneCisloMessages,
    ...genderMessages,
  ];
  final bool genderInferred = genderMessages
      .any((CsvReviewMessage message) => message.code == 'gender_inferred_from_rc');
  final Map<String, CsvDerivedValue> derived = <String, CsvDerivedValue>{
    'datum_narozeni': CsvDerivedValue(
      key: 'datum_narozeni',
      value: '01.01.2010',
      applied: true,
    ),
  };
  if (genderInferred) {
    derived['pohlavi'] = CsvDerivedValue(
      key: 'pohlavi',
      value: '1',
      applied: true,
    );
  }

  return CsvReviewRow(
    originalIndex: index,
    status: status,
    messages: rowMessages,
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
      'rodne_cislo': CsvFieldReview(
        columnKey: 'rodne_cislo',
        columnName: 'Rodné číslo',
        status: rodneCisloMessages.isNotEmpty
            ? CsvFieldReviewStatus.warn
            : CsvFieldReviewStatus.ok,
        originalValue: '101010/0000',
        normalizedValue: '1010100000',
        inferred: false,
        messages: rodneCisloMessages,
      ),
      'pohlavi': CsvFieldReview(
        columnKey: 'pohlavi',
        columnName: 'Pohlaví',
        status: CsvFieldReviewStatus.ok,
        originalValue: '1',
        normalizedValue: '1',
        inferred: genderInferred,
        messages: genderMessages,
      ),
      'datum_narozeni': CsvFieldReview(
        columnKey: 'datum_narozeni',
        columnName: 'Datum narození',
        status: CsvFieldReviewStatus.ok,
        originalValue: '2010-01-01',
        normalizedValue: '2010-01-01',
        inferred: false,
      ),
      'zpusobilost': CsvFieldReview(
        columnKey: 'zpusobilost',
        columnName: 'Způsobilost',
        status:
            messages.isNotEmpty ? CsvFieldReviewStatus.warn : CsvFieldReviewStatus.ok,
        originalValue: eligible ? 'true' : 'false',
        normalizedValue: eligible ? 'true' : 'false',
        inferred: false,
        messages: messages,
      ),
    },
    derived: derived,
  );
}
