import 'package:denik_zza/input/csv_review_models.dart';
import 'package:denik_zza/input/input_parser.dart';
import 'package:denik_zza/screens2/csv/table_overview_screen.dart';
import 'package:denik_zza/screens2/csv/csv_review_shared.dart';
import 'package:denik_zza/services/csv_import_service.dart';
import 'package:denik_zza/services/models/csv_import_payload.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils/csv_test_builders.dart';

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
    expect(find.byKey(const Key('CsvTableOverview_summary_note')), findsOneWidget);
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
    expect(
      find.byKey(const Key('CsvTableOverview_unparsed_columns')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('CsvReviewScreen_unparsed_columns_tile')),
      findsOneWidget,
    );
    await tester.tap(
      find.byKey(const Key('CsvReviewScreen_unparsed_columns_tile')),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('CsvReviewScreen_unparsed_column_0')),
      findsOneWidget,
    );
    expect(find.text('neocekavany sloupec'), findsOneWidget);

    // New simplified button structure
    expect(find.byKey(const Key('CsvTableOverview_action_select_all_valid')),
        findsOneWidget);
    expect(find.byKey(const Key('CsvTableOverview_action_deselect_all')),
        findsOneWidget);
    // Header checkbox exists (may be duplicated due to sticky header implementation)
    expect(find.byKey(const Key('CsvTableOverview_header_checkbox')),
        findsAtLeastNWidgets(1));

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

    // Worst statuses appear first (rejected row above warn row in the table body).
    final Offset rejectedPosition = tester.getTopLeft(
      find.byKey(const Key('CsvTableOverview_status_1')),
    );
    final Offset warnPosition = tester.getTopLeft(
      find.byKey(const Key('CsvTableOverview_status_2')),
    );
    expect(rejectedPosition.dy, lessThan(warnPosition.dy));

    // `Chyba` rows should be disabled for selection in the table before edits.
    final Finder rejectedRowCheckbox = find.byKey(
      const Key('CsvTableOverview_select_checkbox_1'),
    );
    expect(rejectedRowCheckbox, findsOneWidget);
    Checkbox disabledCheckbox =
        tester.widget<Checkbox>(rejectedRowCheckbox);
    expect(disabledCheckbox.onChanged, isNull);
    expect(disabledCheckbox.value, isFalse);
    await tester.tap(rejectedRowCheckbox);
    await tester.pumpAndSettle();
    disabledCheckbox = tester.widget<Checkbox>(rejectedRowCheckbox);
    expect(disabledCheckbox.value, isFalse);

    final Finder rejectedToggle =
        find.byKey(const Key('CsvTableOverview_summary_rejected_toggle'));
    await tester.tap(rejectedToggle);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(
      find.text('Zamítnuté řádky nelze vybrat. Opravte chyby a zkuste to znovu.'),
      findsOneWidget,
    );

  final Finder warnToggle =
    find.byKey(const Key('CsvTableOverview_summary_warn_toggle'));
  final Finder infoToggle =
    find.byKey(const Key('CsvTableOverview_summary_info_toggle'));
  final Finder okToggle =
    find.byKey(const Key('CsvTableOverview_summary_ok_toggle'));
  final Finder totalToggle =
    find.byKey(const Key('CsvTableOverview_summary_total_toggle'));
  final Finder warnCheckboxFinder =
    find.byKey(const Key('CsvTableOverview_select_checkbox_2'));
  final Finder infoCheckboxFinder =
    find.byKey(const Key('CsvTableOverview_select_checkbox_3'));
  final Finder okCheckboxFinder =
    find.byKey(const Key('CsvTableOverview_select_checkbox_4'));

  Checkbox warnCheckbox = tester.widget<Checkbox>(warnCheckboxFinder);
  expect(warnCheckbox.value, isFalse);
  await tester.tap(warnToggle);
  await tester.pumpAndSettle();
  warnCheckbox = tester.widget<Checkbox>(warnCheckboxFinder);
  expect(warnCheckbox.value, isTrue);
  await tester.tap(warnToggle);
  await tester.pumpAndSettle();
  warnCheckbox = tester.widget<Checkbox>(warnCheckboxFinder);
  expect(warnCheckbox.value, isFalse);

  Checkbox infoCheckbox = tester.widget<Checkbox>(infoCheckboxFinder);
  expect(infoCheckbox.value, isFalse);
  await tester.tap(infoToggle);
  await tester.pumpAndSettle();
  infoCheckbox = tester.widget<Checkbox>(infoCheckboxFinder);
  expect(infoCheckbox.value, isTrue);
  await tester.tap(infoToggle);
  await tester.pumpAndSettle();
  infoCheckbox = tester.widget<Checkbox>(infoCheckboxFinder);
  expect(infoCheckbox.value, isFalse);

  Checkbox okCheckbox = tester.widget<Checkbox>(okCheckboxFinder);
  expect(warnCheckbox.value, isFalse);
  expect(infoCheckbox.value, isFalse);
  expect(okCheckbox.value, isFalse);
  await tester.tap(okToggle);
  await tester.pumpAndSettle();
  warnCheckbox = tester.widget<Checkbox>(warnCheckboxFinder);
  infoCheckbox = tester.widget<Checkbox>(infoCheckboxFinder);
  okCheckbox = tester.widget<Checkbox>(okCheckboxFinder);
  expect(warnCheckbox.value, isTrue);
  expect(infoCheckbox.value, isTrue);
  expect(okCheckbox.value, isTrue);
  await tester.tap(okToggle);
  await tester.pumpAndSettle();
  warnCheckbox = tester.widget<Checkbox>(warnCheckboxFinder);
  infoCheckbox = tester.widget<Checkbox>(infoCheckboxFinder);
  okCheckbox = tester.widget<Checkbox>(okCheckboxFinder);
  expect(warnCheckbox.value, isFalse);
  expect(infoCheckbox.value, isFalse);
  expect(okCheckbox.value, isFalse);

  await tester.tap(totalToggle);
  await tester.pumpAndSettle();
  warnCheckbox = tester.widget<Checkbox>(warnCheckboxFinder);
  infoCheckbox = tester.widget<Checkbox>(infoCheckboxFinder);
  okCheckbox = tester.widget<Checkbox>(okCheckboxFinder);
  Checkbox rejectedCheckboxAfterTotal =
    tester.widget<Checkbox>(rejectedRowCheckbox);
  expect(warnCheckbox.value, isTrue);
  expect(infoCheckbox.value, isTrue);
  expect(okCheckbox.value, isTrue);
  expect(rejectedCheckboxAfterTotal.value, isFalse);

  await tester.tap(totalToggle);
  await tester.pumpAndSettle();
  warnCheckbox = tester.widget<Checkbox>(warnCheckboxFinder);
  infoCheckbox = tester.widget<Checkbox>(infoCheckboxFinder);
  okCheckbox = tester.widget<Checkbox>(okCheckboxFinder);
  expect(warnCheckbox.value, isFalse);
  expect(infoCheckbox.value, isFalse);
  expect(okCheckbox.value, isFalse);

    service.markRejectedRowForRepair();
    await tester.enterText(
      find.byKey(const Key('CsvTableOverview_cell_1_jmeno')),
      'Alena opravena',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    Checkbox repairedCheckbox = tester.widget<Checkbox>(rejectedRowCheckbox);
    expect(repairedCheckbox.onChanged, isNotNull);
    await tester.tap(rejectedRowCheckbox);
    await tester.pumpAndSettle();
    repairedCheckbox = tester.widget<Checkbox>(rejectedRowCheckbox);
    expect(repairedCheckbox.value, isTrue);
    await tester.tap(rejectedRowCheckbox);
    await tester.pumpAndSettle();
    repairedCheckbox = tester.widget<Checkbox>(rejectedRowCheckbox);
    expect(repairedCheckbox.value, isFalse);

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

  testWidgets('header remains visible during body scroll',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CsvReviewTableOverviewScreen(
          filePath: 'ignored.csv',
          service: _WidgetFakeService(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final Finder headerFinder =
        find.byKey(const Key('CsvTableOverview_sticky_header'));
    expect(headerFinder, findsOneWidget);

  final double initialTop = tester.getTopLeft(headerFinder).dy;
  expect(initialTop, greaterThanOrEqualTo(0));

  final Finder tableHeaderFinder =
    find.byKey(const Key('CsvTableOverview_table_header'));
  expect(tableHeaderFinder, findsOneWidget);
  final double initialTableHeaderTop =
    tester.getTopLeft(tableHeaderFinder).dy;
  expect(initialTableHeaderTop, greaterThan(initialTop));

    final Finder scrollableBodyFinder =
        find.byKey(const Key('CsvTableOverview_scrollable_body'));
    expect(scrollableBodyFinder, findsOneWidget);

    await tester.drag(
      scrollableBodyFinder,
      const Offset(0, -400),
      warnIfMissed: false,
    );
    await tester.pumpAndSettle();

    final double scrolledTop = tester.getTopLeft(headerFinder).dy;
    expect(scrolledTop, closeTo(initialTop, 0.1));

  final double scrolledTableHeaderTop =
    tester.getTopLeft(tableHeaderFinder).dy;
  expect(scrolledTableHeaderTop, closeTo(initialTableHeaderTop, 0.1));
  });

  testWidgets('header keeps column labels when filter yields no rows',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CsvReviewTableOverviewScreen(
          filePath: 'ignored.csv',
          service: _NoWarnRowsService(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('CsvTableFilter_warn')));
    await tester.pumpAndSettle();

    expect(
      find.text('Žádné řádky pro vybraný filtr.'),
      findsOneWidget,
    );

    final Finder headerFinder =
        find.byKey(const Key('CsvTableOverview_table_header'));
    expect(headerFinder, findsOneWidget);
    expect(
      find.descendant(
        of: headerFinder,
        matching: find.text('Jméno'),
      ),
      findsOneWidget,
    );
  });

  test('controller preserves row index after edits', () async {
    final _MisindexedService service = _MisindexedService();
    final CsvReviewPrototypeController controller =
        CsvReviewPrototypeController.fromPath(
      path: 'ignored.csv',
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

  // ============================================================================
  // SCROLLBAR VISIBILITY AND FUNCTIONALITY TESTS
  // See docs/nested-scrollbars-solution.md for implementation details
  // ============================================================================

  testWidgets('both vertical and horizontal scrollbars are present',
      (WidgetTester tester) async {
    final TestWidgetsFlutterBinding binding =
        TestWidgetsFlutterBinding.ensureInitialized();
    binding.window.physicalSizeTestValue = const Size(1200, 800);
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

    // Find both Scrollbar widgets in the widget tree
    final Finder scrollbarFinder = find.byType(Scrollbar);
    
    // Should find exactly 2 Scrollbar widgets: vertical (outer) and horizontal (inner)
    expect(scrollbarFinder, findsNWidgets(2),
        reason: 'Should have both vertical and horizontal Scrollbars');

    // Verify the vertical scroll widget exists
    expect(find.byKey(const Key('CsvTableOverview_scrollable_body')),
        findsOneWidget,
        reason: 'Vertical ListView should exist');
  });

  testWidgets('horizontal scrollbar remains accessible when scrolling vertically',
      (WidgetTester tester) async {
    final TestWidgetsFlutterBinding binding =
        TestWidgetsFlutterBinding.ensureInitialized();
    // Large enough viewport to avoid overflow but test scrolling
    binding.window.physicalSizeTestValue = const Size(1200, 800);
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

    // Verify both scrollbars exist before scrolling
    expect(find.byType(Scrollbar), findsNWidgets(2));

    // Find the vertical ListView
    final Finder listViewFinder =
        find.byKey(const Key('CsvTableOverview_scrollable_body'));
    expect(listViewFinder, findsOneWidget);

    // Verify both scrollbars still exist - the key implementation detail
    // is that horizontal scrollbar is OUTSIDE the vertical scroll area
    expect(find.byType(Scrollbar), findsNWidgets(2),
        reason:
            'Both scrollbars should remain present (horizontal is outside vertical scroll)');
  });

  testWidgets('horizontal scroll works and synchronizes with header',
      (WidgetTester tester) async {
    final TestWidgetsFlutterBinding binding =
        TestWidgetsFlutterBinding.ensureInitialized();
    // Wide table requires horizontal scrolling
    binding.window.physicalSizeTestValue = const Size(600, 800);
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

    // Find the horizontal scroll widget
    final Finder horizontalScrollFinder =
        find.byKey(const Key('CsvTableOverview_horizontalScroll'));
    expect(horizontalScrollFinder, findsOneWidget);

    // Find the sticky header's horizontal scroll
    final Finder headerScrollFinder =
        find.byKey(const Key('CsvTableOverview_table_header_horizontal'));
    expect(headerScrollFinder, findsOneWidget);

    // Scroll horizontally on the table body
    await tester.drag(horizontalScrollFinder, const Offset(-200, 0));
    await tester.pumpAndSettle();

    // Get the scroll controllers to verify synchronization
    final SingleChildScrollView bodyScroll =
        tester.widget(horizontalScrollFinder);
    final SingleChildScrollView headerScroll =
        tester.widget(headerScrollFinder);

    // Verify both use controllers (they should be synchronized via listeners)
    expect(bodyScroll.controller, isNotNull,
        reason: 'Body should have a ScrollController');
    expect(headerScroll.controller, isNotNull,
        reason: 'Header should have a ScrollController');

    // The controllers should be different objects but synchronized
    expect(bodyScroll.controller != headerScroll.controller, isTrue,
        reason:
            'Body and header should have separate controllers (synchronized via listeners)');
  });

  testWidgets('vertical scroll works independently of horizontal scroll',
      (WidgetTester tester) async {
    final TestWidgetsFlutterBinding binding =
        TestWidgetsFlutterBinding.ensureInitialized();
    binding.window.physicalSizeTestValue = const Size(1200, 800);
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

    // Find the vertical ListView
    final Finder listViewFinder =
        find.byKey(const Key('CsvTableOverview_scrollable_body'));
    expect(listViewFinder, findsOneWidget);

    // Verify both scrollbars exist and are independent
    // This test confirms the notificationPredicate implementation works
    expect(find.byType(Scrollbar), findsNWidgets(2),
        reason:
            'Both scrollbars should exist independently thanks to notificationPredicate');
  });

  testWidgets('scrollbars use notificationPredicate correctly',
      (WidgetTester tester) async {
    final TestWidgetsFlutterBinding binding =
        TestWidgetsFlutterBinding.ensureInitialized();
    binding.window.physicalSizeTestValue = const Size(800, 600);
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

    // Find both Scrollbar widgets
    final List<Scrollbar> scrollbars = tester.widgetList<Scrollbar>(
      find.byType(Scrollbar),
    ).toList();

    expect(scrollbars.length, equals(2),
        reason: 'Should have exactly 2 Scrollbar widgets');

    // One scrollbar should have a notificationPredicate (the horizontal one)
    // This is the key to making both scrollbars visible simultaneously
    final bool hasNotificationPredicate = scrollbars.any(
      (Scrollbar sb) => sb.notificationPredicate != null,
    );

    expect(hasNotificationPredicate, isTrue,
        reason:
            'At least one Scrollbar should have notificationPredicate set (see docs/nested-scrollbars-solution.md)');

    // Both scrollbars should have thumbVisibility enabled
    final int visibleThumbs = scrollbars
        .where((Scrollbar sb) => sb.thumbVisibility == true)
        .length;

    expect(visibleThumbs, equals(2),
        reason: 'Both scrollbars should have thumbVisibility: true');
  });
}

class _WidgetFakeService implements CsvImportService {
  _WidgetFakeService()
      : _rows = <CsvReviewRow>[
          _buildRow(
            1,
            'Alena',
            'Nováková',
            status: CsvRowReviewStatus.rejected,
            messages: <CsvReviewMessage>[
              CsvReviewMessage(
                severity: CsvReviewMessageSeverity.error,
                message: 'Řádek nelze importovat',
                code: 'row_unimportable',
              ),
            ],
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
          _buildRow(
            3,
            'Petr',
            'Krátký',
            status: CsvRowReviewStatus.info,
          ),
          _buildRow(
            4,
            'Eva',
            'Veselá',
            status: CsvRowReviewStatus.ok,
          ),
        ];

  final List<CsvReviewRow> _rows;
  Map<String, String?>? lastPayload;
  bool repairRejectedOnNextEdit = false;

  void markRejectedRowForRepair() {
    repairRejectedOnNextEdit = true;
  }

  @override
  Future<CsvImportSession> loadCsv(String path) async {
    return CsvImportSession(
      review: CsvImportReview(
  unparsedColumns: const <String>['neocekavany sloupec'],
        rows: _rows,
      ),
      personResult: PersonResult(<Answer>[]),
    );
  }

  @override
  Future<CsvImportSession> loadCsvFromPayload(CsvImportPayload payload) {
    if (payload.path != null && payload.path!.isNotEmpty) {
      return loadCsv(payload.path!);
    }
    throw UnsupportedError('In-memory payloads are not supported in this widget test.');
  }
  @override
  Future<CsvReviewRow> reparseRow(Map<String, String?> updatedFields) async {
    lastPayload = Map<String, String?>.from(updatedFields);
    final CsvReviewRow existing = _rows.first;
    if (existing.originalIndex == 1 && repairRejectedOnNextEdit) {
      repairRejectedOnNextEdit = false;
      final String newFirstName =
          updatedFields['jmeno'] ?? existing.fields['jmeno']?.normalizedValue ?? 'Alena';
      final String newLastName =
          updatedFields['prijmeni'] ?? existing.fields['prijmeni']?.normalizedValue ?? 'Nováková';
      final CsvReviewRow repaired = _buildRow(
        1,
        newFirstName,
        newLastName,
        status: CsvRowReviewStatus.ok,
      );
      _rows[0] = repaired;
      return repaired;
    }
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

class _NoWarnRowsService implements CsvImportService {
  _NoWarnRowsService()
      : _rows = <CsvReviewRow>[
          _buildRow(1, 'Petr', 'Svoboda', status: CsvRowReviewStatus.ok),
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
  Future<CsvImportSession> loadCsvFromPayload(CsvImportPayload payload) {
    if (payload.path != null && payload.path!.isNotEmpty) {
      return loadCsv(payload.path!);
    }
    throw UnsupportedError('In-memory payloads are not supported in this widget test.');
  }

  @override
  Future<CsvReviewRow> reparseRow(Map<String, String?> updatedFields) async {
    final CsvReviewRow current = _rows.first;
    final Map<String, CsvFieldReview> updatedFieldsMap =
        Map<String, CsvFieldReview>.from(current.fields);
    updatedFields.forEach((String key, String? value) {
      final CsvFieldReview? original = updatedFieldsMap[key];
      if (original == null) {
        return;
      }
      updatedFieldsMap[key] = CsvFieldReview(
        columnKey: original.columnKey,
        columnName: original.columnName,
        status: original.status,
        originalValue: value ?? original.originalValue,
        normalizedValue: value ?? original.normalizedValue,
        inferred: original.inferred,
        messages: original.messages,
      );
    });
    final CsvReviewRow updated = CsvReviewRow(
      originalIndex: current.originalIndex,
      status: current.status,
      messages: current.messages,
      fields: updatedFieldsMap,
      derived: current.derived,
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

class _MisindexedService implements CsvImportService {
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
  Future<CsvImportSession> loadCsvFromPayload(CsvImportPayload payload) {
    if (payload.path != null && payload.path!.isNotEmpty) {
      return loadCsv(payload.path!);
    }
    throw UnsupportedError('In-memory payloads are not supported in this widget test.');
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

/// Convenience wrapper around CsvReviewRowBuilder for this test file.
/// 
/// Uses positional parameters for backward compatibility with existing test code.
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
  return CsvReviewRowBuilder.build(
    index: index,
    firstName: firstName,
    lastName: lastName,
    status: status,
    eligible: eligible,
    messages: messages,
    rodneCisloMessages: rodneCisloMessages,
    genderMessages: genderMessages,
  );
}
