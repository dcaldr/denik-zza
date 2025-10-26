import 'dart:math' as math;

import 'package:denik_zza/input/csv_review_models.dart';
import 'package:denik_zza/screens2/widgets/app_drawer.dart';
import 'package:denik_zza/services/csv_import_service.dart';
import 'package:denik_zza/services/models/csv_import_payload.dart';
import 'package:denik_zza/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:logger/logger.dart';

import 'csv_review_shared.dart';
import 'summary_screen.dart';
import 'widgets/summary_section.dart';
import 'widgets/unparsed_columns_section.dart';

/// Tabular CSV confirmation prototype with sticky summary header and inline
/// editing.
class CsvReviewTableOverviewScreen extends StatelessWidget {
  const CsvReviewTableOverviewScreen({
    super.key,
    this.filePath,
    this.payload,
    this.service,
  }) : assert(
          filePath != null || payload != null,
          'Either filePath or payload must be provided.',
        );

  final String? filePath;
  final CsvImportPayload? payload;
  final CsvImportService? service;

  @override
  Widget build(BuildContext context) {
    return CsvReviewPrototypeHost(
      filePath: filePath,
      payload: payload,
      service: service,
      builder: (BuildContext context, CsvReviewPrototypeController controller) {
        return _TableOverviewScaffold(controller: controller);
      },
    );
  }
}

class _TableOverviewScaffold extends StatefulWidget {
  const _TableOverviewScaffold({
    required this.controller,
  });

  final CsvReviewPrototypeController controller;

  @override
  State<_TableOverviewScaffold> createState() => _TableOverviewScaffoldState();
}

class _TableOverviewScaffoldState extends State<_TableOverviewScaffold> {
  // TODO: Split this scaffold into smaller widgets once table interactions stabilize.
  static const double _tableHeaderHeight = 56.0;
  static const double _tableHeaderGap = 8.0;
  static const List<String> _preferredFieldOrder = <String>[
    'jmeno',
    'prijmeni',
    'cislo_pojisteni',
    'rodne_cislo',
    'datum_narozeni',
    'pohlavi',
    'pojistovna',
    'adresa',
    'jmeno_rodice',
    'email_rodice',
    'telefon_rodice',
    'zpusobilost',
    'bezinfekcnost',
    'poznamka',
  ];

  CsvRowReviewStatus? _activeStatus;
  late List<_TableFilter> _filters;
  late List<String> _columnOrder;
  String? _duplicateIndicatorFieldKey;
  late final ScrollController _headerScrollController;
  late final ScrollController _bodyScrollController;
  late final ScrollController _verticalScrollController;
  final GlobalKey _tableBodyKey = GlobalKey();
  double? _tableBodyWidth;
  List<double>? _columnPixelWidths;
  final GlobalKey<TooltipState> _rejectedSummaryTooltipKey =
      GlobalKey<TooltipState>();
  final Logger _logger = AppLogger.l;

  CsvReviewPrototypeController get _controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _filters = <_TableFilter>[
      const _TableFilter(label: 'Vše', status: null, key: 'CsvTableFilter_all'),
      const _TableFilter(
          label: 'Chyby',
          status: CsvRowReviewStatus.rejected,
          key: 'CsvTableFilter_rejected'),
      const _TableFilter(
          label: 'Varování',
          status: CsvRowReviewStatus.warn,
          key: 'CsvTableFilter_warn'),
      const _TableFilter(
          label: 'Informace',
          status: CsvRowReviewStatus.info,
          key: 'CsvTableFilter_info'),
      const _TableFilter(
          label: 'V pořádku',
          status: CsvRowReviewStatus.ok,
          key: 'CsvTableFilter_ok'),
    ];
    _activeStatus = null;
    _columnOrder = _resolveColumnOrder();
    
    // Separate controllers for header and body to enable visible scrollbar
    _headerScrollController = ScrollController();
    _bodyScrollController = ScrollController();
    _verticalScrollController = ScrollController();
    
    // Synchronize scrolling between header and body
    _bodyScrollController.addListener(_syncBodyToHeader);
    _headerScrollController.addListener(_syncHeaderToBody);
  }

  void _syncBodyToHeader() {
    if (_bodyScrollController.hasClients && _headerScrollController.hasClients) {
      if (_headerScrollController.offset != _bodyScrollController.offset) {
        _headerScrollController.jumpTo(_bodyScrollController.offset);
      }
    }
  }

  void _syncHeaderToBody() {
    if (_headerScrollController.hasClients && _bodyScrollController.hasClients) {
      if (_bodyScrollController.offset != _headerScrollController.offset) {
        _bodyScrollController.jumpTo(_headerScrollController.offset);
      }
    }
  }

  @override
  void didUpdateWidget(covariant _TableOverviewScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.controller, widget.controller)) {
      _columnOrder = _resolveColumnOrder();
    }
  }

  @override
  void dispose() {
    _bodyScrollController.removeListener(_syncBodyToHeader);
    _headerScrollController.removeListener(_syncHeaderToBody);
    _headerScrollController.dispose();
    _bodyScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  void _scheduleTableWidthMeasurement() {
    // Mirror body table sizing after layout so the overlay header stays aligned.
    // TODO: Replace RenderTable traversal with a stable width source once DataTable offers API hooks.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final RenderBox? renderBox =
          _tableBodyKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox == null) {
        return;
      }
      final double measuredWidth = renderBox.size.width;
      RenderTable? renderTable;
      void findTable(RenderObject child) {
        if (renderTable != null) {
          return;
        }
        if (child is RenderTable) {
          renderTable = child;
          return;
        }
        if (child is RenderBox) {
          child.visitChildren(findTable);
        }
      }

      renderBox.visitChildren(findTable);
      List<double>? measuredColumns;
      if (renderTable != null) {
        final Map<int, double> widthMap = <int, double>{};
        renderTable!.visitChildren((RenderObject child) {
          if (child is! RenderBox) {
            return;
          }
          final TableCellParentData parentData =
              child.parentData! as TableCellParentData;
          if (parentData.y == 0 && parentData.x != null) {
            widthMap[parentData.x!] = child.size.width;
          }
        });
        if (widthMap.isNotEmpty) {
          measuredColumns = List<double>.generate(
            renderTable!.columns,
            (int column) => widthMap[column] ?? widthMap.values.last,
          );
        }
      }

      final bool widthChanged = _tableBodyWidth == null ||
          (_tableBodyWidth! - measuredWidth).abs() >= 0.5;
      final bool columnsChanged = measuredColumns != null &&
          (_columnPixelWidths == null ||
              !_areColumnWidthsEqual(_columnPixelWidths!, measuredColumns));
      if (!widthChanged && !columnsChanged) {
        return;
      }
      setState(() {
        _tableBodyWidth = measuredWidth;
        if (measuredColumns != null) {
          _columnPixelWidths = measuredColumns;
        }
      });
    });
  }

  bool _areColumnWidthsEqual(List<double> a, List<double> b) {
    if (identical(a, b)) {
      return true;
    }
    if (a.length != b.length) {
      return false;
    }
    for (int i = 0; i < a.length; i++) {
      if ((a[i] - b[i]).abs() >= 0.5) {
        return false;
      }
    }
    return true;
  }

  List<String> _resolveColumnOrder() {
    if (_controller.rows.isEmpty) {
      _duplicateIndicatorFieldKey = null;
      return const <String>[];
    }
    final CsvReviewRow sample = _controller.rows.first;
    final List<String> orderedKeys = <String>[];
    final Set<String> remaining = <String>{
      for (final String key in sample.fields.keys) key,
    };

    for (final String preferred in _preferredFieldOrder) {
      if (remaining.remove(preferred)) {
        orderedKeys.add(preferred);
      }
    }

    for (final String key in sample.fields.keys) {
      if (!orderedKeys.contains(key)) {
        orderedKeys.add(key);
      }
    }

    _duplicateIndicatorFieldKey = _resolveDuplicateIndicatorHost(orderedKeys);
    return List<String>.unmodifiable(orderedKeys);
  }

  String? _resolveDuplicateIndicatorHost(List<String> orderedKeys) {
    if (orderedKeys.isEmpty) {
      return null;
    }
    if (orderedKeys.contains('jmeno')) {
      return 'jmeno';
    }
    if (orderedKeys.contains('prijmeni')) {
      return 'prijmeni';
    }
    return orderedKeys.first;
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double bottomListPadding =
        24 + kBottomNavigationBarHeight + mediaQuery.viewPadding.bottom;
    final double viewportWidth = mediaQuery.size.width;
    final double minTableWidth = math.max(960, viewportWidth - 32);
    final double headerOverlayHeight = _tableHeaderHeight + 1;
    final double listTopPadding = headerOverlayHeight + _tableHeaderGap;

    if (_controller.rows.isNotEmpty) {
      _scheduleTableWidthMeasurement();
    } else if (_tableBodyWidth != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        setState(() {
          _tableBodyWidth = null;
        });
      });
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tabulkový přehled CSV'),
      ),
      drawer: const AppDrawer(),
      body: _controller.session == null
          ? const SizedBox.shrink()
          : SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // Keep the control header outside the scrollable body so it remains
                  // visible while rows scroll. Flutter recommends pinning persistent
                  // headers (see SliverPersistentHeader docs) and this layout achieves
                  // the same effect without introducing slivers for our dynamic wrap.
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      key: const Key('CsvTableOverview_sticky_header'),
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        _buildTitleRow(context),
                        const SizedBox(height: 2),
                        _buildSummaryPanel(context),
                        _buildUnparsedColumnsSection(),
                        const SizedBox(height: 2),
                        _buildFilterRow(context),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(height: 4),
                  ),
                  Expanded(
                    child: Stack(
                      children: <Widget>[
                        Scrollbar(
                          controller: _verticalScrollController,
                          thumbVisibility: true,
                          child: Scrollbar(
                            controller: _bodyScrollController,
                            thumbVisibility: true,
                            notificationPredicate: (notif) => notif.depth == 1,
                            child: ListView(
                              key: const Key('CsvTableOverview_scrollable_body'),
                              controller: _verticalScrollController,
                              padding: EdgeInsets.only(
                                left: 16,
                                right: 16,
                                top: listTopPadding,
                                bottom: bottomListPadding,
                              ),
                              children: <Widget>[
                                _buildTableBodySection(context, minTableWidth),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 16,
                          right: 16,
                          top: 0,
                          child: _buildStickyTableHeader(
                            context: context,
                            minTableWidth: minTableWidth,
                            height: headerOverlayHeight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: _controller.session == null
          ? null
          : Material(
              elevation: 8,
              color: Theme.of(context).colorScheme.surface,
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    /*
                        // Legacy footer preserved for potential rollback during prototyping.
                        BulkActionBar(
                          key: const Key('CsvTableOverview_bulkActions'),
                          approvedCount: _controller.approvedCount,
                          rejectedCount: _controller.rejectedCount,
                          onApproveOk: _controller.bulkApproveOk,
                          onApproveUpToInfo: _controller.bulkApproveUpToInfo,
                          onClearApprovals: _controller.bulkClearApprovals,
                          onRejectAll: _controller.bulkRejectAll,
                          onRejectOnlyRejected: _controller.bulkRejectOnlyRejected,
                        ),
                        FinalizeCard(
                          key: const Key('CsvTableOverview_finalize'),
                          approvedCount: _controller.approvedCount,
                          rejectedCount: _controller.rejectedCount,
                          undecidedCount: _controller.undecidedCount,
                          duplicateCount: _controller.duplicateRowCount,
                          isFinalizing: _controller.isFinalizing,
                          onFinalize: () async {
                            await _controller.finalizeImport();
                          },
                        ),
                        */
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: _buildFooterButtons(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildUnparsedColumnsSection() {
    final List<String> unparsed =
        _controller.session?.review.unparsedColumns ?? const <String>[];
    if (unparsed.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: UnparsedColumnsSection(
        key: const Key('CsvTableOverview_unparsed_columns'),
        unparsedColumns: unparsed,
      ),
    );
  }

  Widget _buildFilterRow(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: _filters.map((_TableFilter filter) {
          final bool selected = _activeStatus == filter.status;
          final int count = filter.status == null
              ? _controller.totalRowCount
              : _controller.groupedRows[filter.status]?.length ?? 0;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              key: Key(filter.key),
              label: Text('${filter.label} ($count)'),
              selected: selected,
              onSelected: (bool value) {
                setState(() {
                  _activeStatus = value ? filter.status : null;
                });
              },
              selectedColor: theme.colorScheme.primaryContainer,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTitleRow(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String? fileLabel = _controller.importFileLabel;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (fileLabel != null && fileLabel.isNotEmpty) ...<Widget>[
                Text(
                  'Soubor: $fileLabel',
                  key: const Key('CsvTableOverview_file_label'),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
              ],
              Text(
                'Rychle prohlédněte importované záznamy a upravte je na jednom místě.',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        IconButton(
          key: const Key('CsvTableOverview_refresh'),
          onPressed: _controller.reload,
          icon: const Icon(Icons.refresh),
          tooltip: 'Znovu načíst soubor',
        ),
      ],
    );
  }

  Widget _buildSummaryPanel(BuildContext context) {
    final Map<CsvRowReviewStatus, List<CsvReviewRow>> grouped =
        _controller.groupedRows;
    final ThemeData theme = Theme.of(context);
    final int totalCount = _controller.session?.review.rows.length ?? 0;
    final int warnCount = grouped[CsvRowReviewStatus.warn]?.length ?? 0;
    final int infoCount = grouped[CsvRowReviewStatus.info]?.length ?? 0;
    final int okCount = grouped[CsvRowReviewStatus.ok]?.length ?? 0;
    final int validCount = warnCount + infoCount + okCount;

    final BorderRadius badgeRadius = BorderRadius.circular(8);
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Wrap(
          key: const Key('CsvTableOverview_summary_content'),
          spacing: 16,
          runSpacing: 16,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(Icons.insights_outlined,
                        color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    Text(
                      'Shrnutí souboru',
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Dočasné výběry kategorií upravují pouze označení řádků.',
                  key: const Key('CsvTableOverview_summary_note'),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            Tooltip(
              key: _rejectedSummaryTooltipKey,
              message:
                  'Zamítnuté řádky nelze vybrat. Opravte chyby a zkuste to znovu.',
              child: InkWell(
                key: const Key('CsvTableOverview_summary_rejected_toggle'),
                borderRadius: badgeRadius,
                onTap: () {
                  _rejectedSummaryTooltipKey.currentState
                      ?.ensureTooltipVisible();
                },
                onLongPress: () {
                  _rejectedSummaryTooltipKey.currentState
                      ?.ensureTooltipVisible();
                },
                child: SummaryBadge(
                  key: const Key('CsvTableOverview_summary_rejected_count'),
                  label: 'Zamítnuto',
                  count: grouped[CsvRowReviewStatus.rejected]?.length ?? 0,
                  color: statusColor(theme, CsvRowReviewStatus.rejected),
                ),
              ),
            ),
            InkWell(
              key: const Key('CsvTableOverview_summary_warn_toggle'),
              borderRadius: badgeRadius,
              onTap: () => _handleSummaryStatusTap(CsvRowReviewStatus.warn),
              child: SummaryBadge(
                key: const Key('CsvTableOverview_summary_warn_count'),
                label: 'Varování',
                count: warnCount,
                color: statusColor(theme, CsvRowReviewStatus.warn),
              ),
            ),
            InkWell(
              key: const Key('CsvTableOverview_summary_info_toggle'),
              borderRadius: badgeRadius,
              onTap: () => _handleSummaryStatusTap(CsvRowReviewStatus.info),
              child: SummaryBadge(
                key: const Key('CsvTableOverview_summary_info_count'),
                label: 'Informace',
                count: infoCount,
                color: statusColor(theme, CsvRowReviewStatus.info),
              ),
            ),
            InkWell(
              key: const Key('CsvTableOverview_summary_ok_toggle'),
              borderRadius: badgeRadius,
              onTap: _handleSummaryValidTap,
              child: SummaryBadge(
                key: const Key('CsvTableOverview_summary_ok_count'),
                // "V pořádku" = perfect records with no issues
                // Avoids ambiguity with "Schválit všechny platné" button
                // which approves all non-rejected rows (warn+info+ok)
                label: 'V pořádku',
                count: validCount,
                color: statusColor(theme, CsvRowReviewStatus.ok),
              ),
            ),
            InkWell(
              key: const Key('CsvTableOverview_summary_total_toggle'),
              borderRadius: badgeRadius,
              onTap: _handleSummaryTotalTap,
              child: Container(
                key: const Key('CsvTableOverview_summary_total'),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant,
                  borderRadius: badgeRadius,
                ),
                child: Text(
                  'Celkem řádků: $totalCount',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSummaryStatusTap(CsvRowReviewStatus status) {
    final List<CsvReviewRow> rows =
        _controller.groupedRows[status] ?? const <CsvReviewRow>[];
    if (rows.isEmpty) {
      return;
    }
    final List<int> indices = rows
        .where((CsvReviewRow row) => row.status != CsvRowReviewStatus.rejected)
        .map((CsvReviewRow row) => row.originalIndex)
        .toList();
    if (indices.isEmpty) {
      return;
    }
    final bool allSelected = indices.every(_controller.isRowSelected);
    _controller.setRowsSelected(indices, !allSelected);
  }

  void _handleSummaryValidTap() {
    final Set<int> indexSet = <int>{};
    for (final CsvRowReviewStatus status in <CsvRowReviewStatus>{
      CsvRowReviewStatus.warn,
      CsvRowReviewStatus.info,
      CsvRowReviewStatus.ok,
    }) {
      final List<CsvReviewRow> rows =
          _controller.groupedRows[status] ?? const <CsvReviewRow>[];
      for (final CsvReviewRow row in rows) {
        if (row.status == CsvRowReviewStatus.rejected) {
          continue;
        }
        indexSet.add(row.originalIndex);
      }
    }
    if (indexSet.isEmpty) {
      return;
    }
    final List<int> indices = indexSet.toList()..sort();
    final bool allSelected = indices.every(_controller.isRowSelected);
    _controller.setRowsSelected(indices, !allSelected);
  }

  void _handleSummaryTotalTap() {
    final List<int> indices = _controller.rows
        .where((CsvReviewRow row) => row.status != CsvRowReviewStatus.rejected)
        .map((CsvReviewRow row) => row.originalIndex)
        .toList();
    if (indices.isEmpty) {
      return;
    }
    final bool allSelected = indices.every(_controller.isRowSelected);
    _controller.setRowsSelected(indices, !allSelected);
  }

  Widget _buildStickyTableHeader({
    required BuildContext context,
    required double minTableWidth,
    required double height,
  }) {
    final List<CsvReviewRow> rows = _controller.rowsForStatus(_activeStatus);
    final ThemeData theme = Theme.of(context);
    final List<double>? columnWidths = _columnPixelWidths;
    final List<CsvReviewRow> headerSourceRows = rows.isNotEmpty
        ? rows
        : (_controller.rows.isNotEmpty
            ? <CsvReviewRow>[_controller.rows.first]
            : const <CsvReviewRow>[]);
    final List<DataColumn> currentColumns =
        _buildDataColumns(context, headerSourceRows);
    final double targetWidth =
        math.max(_tableBodyWidth ?? minTableWidth, minTableWidth);
    final List<double>? measuredHeaderWidths =
        columnWidths != null && columnWidths.length == currentColumns.length
            ? columnWidths
            : null;
    final List<double> effectiveColumnWidths = measuredHeaderWidths ??
        _fallbackHeaderColumnWidths(context, currentColumns, targetWidth);
    final double computedWidth = effectiveColumnWidths.isNotEmpty
        ? effectiveColumnWidths.fold<double>(
            0, (double sum, double value) => sum + value)
        : targetWidth;
    final Widget headerRow = currentColumns.isEmpty
        ? const SizedBox.shrink()
        : _buildMeasuredHeaderRow(
            context,
            currentColumns,
            effectiveColumnWidths.isEmpty
                ? List<double>.filled(
                    currentColumns.length,
                    computedWidth / currentColumns.length,
                    growable: false,
                  )
                : effectiveColumnWidths,
          );

    return SizedBox(
      height: height,
      child: Container(
        color: theme.colorScheme.surface,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              height: _tableHeaderHeight,
              child: SingleChildScrollView(
                key: const Key('CsvTableOverview_table_header_horizontal'),
                controller: _headerScrollController,
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: computedWidth,
                  child: headerRow,
                ),
              ),
            ),
            Divider(
              height: 1,
              thickness: 1,
              color: theme.dividerColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableBodySection(BuildContext context, double minTableWidth) {
    final List<CsvReviewRow> rows = _controller.rowsForStatus(_activeStatus);
    if (rows.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Text(
            'Žádné řádky pro vybraný filtr.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SingleChildScrollView(
        key: const Key('CsvTableOverview_horizontalScroll'),
        controller: _bodyScrollController,
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          key: _tableBodyKey,
          constraints: BoxConstraints(minWidth: minTableWidth),
          child: _buildDataTable(context, rows),
        ),
      ),
    );
  }

  Widget _buildMeasuredHeaderRow(
    BuildContext context,
    List<DataColumn> columns,
    List<double> columnWidths,
  ) {
    final ThemeData theme = Theme.of(context);
    final List<Widget> cells = <Widget>[];
    for (int i = 0; i < columns.length; i++) {
      final double width =
          i < columnWidths.length ? columnWidths[i] : columnWidths.last;
      final Widget label = columns[i].label;
      final AlignmentGeometry alignment =
          i == 0 ? Alignment.center : AlignmentDirectional.centerStart;
      cells.add(
        SizedBox(
          width: width,
          child: Align(
            alignment: alignment,
            child: DefaultTextStyle.merge(
              style: theme.textTheme.titleSmall,
              child: label,
            ),
          ),
        ),
      );
    }

    return ColoredBox(
      key: const Key('CsvTableOverview_table_header'),
      color: theme.colorScheme.surfaceVariant,
      child: SizedBox(
        height: _tableHeaderHeight,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: cells,
        ),
      ),
    );
  }

  List<double> _fallbackHeaderColumnWidths(
    BuildContext context,
    List<DataColumn> columns,
    double targetWidth,
  ) {
    if (columns.isEmpty) {
      return const <double>[];
    }
    final double resolvedTargetWidth =
        targetWidth <= 0 ? columns.length * 120.0 : targetWidth;
    final TextStyle headerStyle =
        Theme.of(context).textTheme.titleSmall ?? const TextStyle(fontSize: 14);
    final List<double> baseWidths = <double>[];
    for (int i = 0; i < columns.length; i++) {
      final double intrinsic = _measureHeaderLabelWidth(
        columns[i].label,
        headerStyle,
      );
      final double padding = i <= 1 ? 24.0 : 40.0;
      double baseWidth = intrinsic + padding;
      if (i == 0) {
        baseWidth = 56.0;
      } else if (i == 1) {
        baseWidth = math.max(128.0, baseWidth);
      } else {
        baseWidth = math.max(128.0, baseWidth);
      }
      baseWidths.add(baseWidth);
    }

    final double baseTotal =
        baseWidths.fold<double>(0, (double sum, double value) => sum + value);
    if (baseTotal == 0) {
      return List<double>.filled(
        columns.length,
        resolvedTargetWidth / columns.length,
        growable: false,
      );
    }

    if ((baseTotal - resolvedTargetWidth).abs() <= 0.5) {
      return baseWidths;
    }

    final List<double> result = List<double>.from(baseWidths, growable: false);
    if (baseTotal < resolvedTargetWidth) {
      final double extra = resolvedTargetWidth - baseTotal;
      final int adjustableCount =
          result.length <= 1 ? result.length : result.length - 1;
      if (adjustableCount == 0) {
        result[0] += extra;
        return result;
      }
      final double adjustableBase = result
          .skip(1)
          .fold<double>(0, (double sum, double value) => sum + value);
      for (int i = 1; i < result.length; i++) {
        final double share = adjustableBase == 0
            ? extra / adjustableCount
            : extra * (result[i] / adjustableBase);
        result[i] += share;
      }
      return result;
    }

    final double scale = resolvedTargetWidth / baseTotal;
    for (int i = 0; i < result.length; i++) {
      final double minimum = i == 0 ? 48.0 : 96.0;
      result[i] = math.max(minimum, result[i] * scale);
    }

    final double scaledTotal =
        result.fold<double>(0, (double sum, double value) => sum + value);
    if (scaledTotal < resolvedTargetWidth) {
      final double deficit = resolvedTargetWidth - scaledTotal;
      final double increment = deficit / result.length;
      for (int i = 0; i < result.length; i++) {
        result[i] += increment;
      }
    }
    return result;
  }

  double _measureHeaderLabelWidth(Widget label, TextStyle fallbackStyle) {
    if (label is SizedBox && label.width != null) {
      return label.width!;
    }
    if (label is Text) {
      final InlineSpan innerSpan = label.textSpan ??
          TextSpan(text: label.data ?? '', style: label.style);
      final TextSpan wrappedSpan = TextSpan(
        style: fallbackStyle,
        children: <InlineSpan>[innerSpan],
      );
      final TextPainter painter = TextPainter(
        text: wrappedSpan,
        maxLines: 1,
        textDirection: TextDirection.ltr,
      )..layout();
      return painter.width;
    }
    return 128.0;
  }

  Widget _buildFooterButtons(BuildContext context) {
    final int selectedCount = _controller.selectedRowCount;
    final bool hasRows = _controller.totalRowCount > 0;
    final bool isFinalizing = _controller.isFinalizing;
    final String finalizeLabel = selectedCount > 0
        ? 'Dokončit import ($selectedCount)'
        : 'Dokončit import';

    return Wrap(
      alignment: WrapAlignment.end,
      spacing: 12,
      runSpacing: 12,
      children: <Widget>[
        FilledButton.icon(
          key: const Key('CsvTableOverview_action_select_all_valid'),
          onPressed: hasRows ? _controller.selectAllValid : null,
          icon: const Icon(Icons.checklist),
          label: const Text('Označit všechny platné'),
        ),
        FilledButton.icon(
          key: const Key('CsvTableOverview_action_deselect_all'),
          onPressed: selectedCount > 0 ? _controller.deselectAll : null,
          icon: const Icon(Icons.clear_all),
          label: const Text('Odznačit vše'),
        ),
        FilledButton(
          key: const Key('CsvTableOverview_action_finalize'),
          onPressed: !hasRows || selectedCount == 0 || isFinalizing
              ? null
              : () => _handleFinalizePressed(context),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (isFinalizing) ...<Widget>[
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
                const SizedBox(width: 8),
                const Text('Dokončuji…'),
              ] else ...<Widget>[
                const Icon(Icons.cloud_upload),
                const SizedBox(width: 8),
                Text(finalizeLabel),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handleFinalizePressed(BuildContext context) async {
    _logger.d('Finalize button pressed - selectedCount: ${_controller.selectedRowCount}, isFinalizing: ${_controller.isFinalizing}');
    
    if (_controller.selectedRowCount == 0 || _controller.isFinalizing) {
      _logger.w('Finalize aborted - selectedCount is 0 or already finalizing');
      return;
    }

    try {
      _logger.i(
        '$csvImportFlowLogTag: Finalize requested (selected=${_controller.selectedRowCount}, fileLabel=${_controller.importFileLabel ?? 'CSV soubor'}).',
      );
      final CsvFinalizeResult? result = await _controller.finalizeImport();
      _logger.d('Finalize result received: savedCount=${result?.savedCount}, failedCount=${result?.failedCount}');
      
      if (!mounted) {
        _logger.w('Widget not mounted after finalize');
        return;
      }
      if (result == null) {
        _logger.w(
          '$csvImportFlowLogTag: Finalize returned null result; keeping user on table overview.',
        );
        if (!mounted) return;
        const SnackBar message = SnackBar(
          content: Text('Import nelze dokončit. Zkuste to prosím znovu.'),
        );
        ScaffoldMessenger.of(context).showSnackBar(message);
        return;
      }

      final String label =
          _controller.importFileLabel?.trim().isNotEmpty == true
              ? _controller.importFileLabel!
              : 'CSV soubor';

      _logger.i(
        '$csvImportFlowLogTag: Finalize succeeded (saved=${result.savedCount}, failed=${result.failedCount}). Opening summary.',
      );
      
      if (!mounted) return;
      _logger.d('About to navigate to summary screen...');
      await CsvImportSummaryScreen.openAfterFinalize(
        context: context,
        result: result,
        importFileLabel: label,
      );
      _logger.d('Navigation completed');
    } on Object catch (error, stackTrace) {
      _logger.e(
        '$csvImportFlowLogTag: Finalize import failed.',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      const SnackBar message = SnackBar(
        content: Text('Dokončení importu selhalo. Zkuste to prosím znovu.'),
      );
      ScaffoldMessenger.of(context).showSnackBar(message);
    }
  }

  Widget _buildDataTable(BuildContext context, List<CsvReviewRow> rows) {
    final List<DataColumn> columns = _buildDataColumns(
      context,
      rows,
      includeSelectAllCheckbox: false,
    );

    return DataTable(
      key: const Key('CsvTableOverview_table'),
      columns: columns,
      showCheckboxColumn: false,
      columnSpacing: 24,
      horizontalMargin: 24,
      headingRowHeight: 0,
      rows: rows.map((CsvReviewRow row) {
        final bool loading = _controller.isRowLoading(row.originalIndex);
        final bool hasDuplicate = _controller.hasDuplicate(row.originalIndex);
        final bool isSelected = _controller.isRowSelected(row.originalIndex);
        final bool isRejected = row.status == CsvRowReviewStatus.rejected;
        final Color statusAccent = statusColor(
          Theme.of(context),
          row.status,
        );
        return DataRow(
          key: ValueKey<int>(row.originalIndex),
          selected: isSelected,
          onSelectChanged: loading || isRejected
              ? null
              : (bool? value) {
                  if (value == null) {
                    return;
                  }
                  _controller.toggleRowSelection(
                    row.originalIndex,
                    value,
                  );
                },
          cells: <DataCell>[
            DataCell(
              Center(
                child: Checkbox(
                  key: Key(
                      'CsvTableOverview_select_checkbox_${row.originalIndex}'),
                  value: isSelected,
                  onChanged: loading || isRejected
                      ? null
                      : (bool? value) {
                          if (value == null) {
                            return;
                          }
                          _controller.toggleRowSelection(
                            row.originalIndex,
                            value,
                          );
                        },
                ),
              ),
            ),
            DataCell(
              _StatusCell(
                row: row,
                statusAccent: statusAccent,
              ),
            ),
            ..._columnOrder.map(
              (String key) => DataCell(
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 220),
                  child: _buildFieldCell(
                    context: context,
                    row: row,
                    fieldKey: key,
                    loading: loading,
                    isEdited: _controller.isCellEdited(row.originalIndex, key),
                    hasDuplicate: hasDuplicate,
                  ),
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  List<DataColumn> _buildDataColumns(
    BuildContext context,
    List<CsvReviewRow> rows, {
    bool includeSelectAllCheckbox = true,
  }) {
    final CsvReviewRow? sample = rows.isNotEmpty ? rows.first : null;
    final int selectedCount = _controller.selectedRowCount;
    final int totalValidRows = _controller.validRowCount;
    final bool allSelected = selectedCount > 0 && selectedCount == totalValidRows;
    
    return <DataColumn>[
      DataColumn(
        label: includeSelectAllCheckbox
            ? Checkbox(
                key: const Key('CsvTableOverview_header_checkbox'),
                tristate: true,
                value: selectedCount == 0 ? false : (allSelected ? true : null),
                onChanged: (bool? value) {
                  if (value == true || value == null) {
                    _controller.selectAllValid();
                  } else {
                    _controller.deselectAll();
                  }
                },
              )
            : const SizedBox.shrink(),
      ),
      const DataColumn(label: Text('Stav')),
      ..._columnOrder.map(
        (String key) => DataColumn(
          label: Text(sample?.fields[key]?.columnName ?? key),
        ),
      ),
    ];
  }

  Widget _buildFieldCell({
    required BuildContext context,
    required CsvReviewRow row,
    required String fieldKey,
    required bool loading,
    required bool isEdited,
    required bool hasDuplicate,
  }) {
    final Widget cell = _EditableCell(
      row: row,
      fieldKey: fieldKey,
      controller: _controller,
      loading: loading,
      isEdited: isEdited,
    );

    final bool isDuplicateHost =
        hasDuplicate && fieldKey == _duplicateIndicatorFieldKey;
    if (!isDuplicateHost) {
      return cell;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Expanded(child: cell),
        const SizedBox(width: 8),
        Tooltip(
          message: 'Potenciální duplicitní záznam',
          child: Icon(
            Icons.warning_amber_rounded,
            key: Key(
                'CsvTableOverview_duplicate_indicator_${row.originalIndex}'),
            color: Theme.of(context).colorScheme.error,
            size: 18,
          ),
        ),
      ],
    );
  }
}

class _TableFilter {
  const _TableFilter({
    required this.label,
    required this.status,
    required this.key,
  });

  final String label;
  final CsvRowReviewStatus? status;
  final String key;
}

class _StatusCell extends StatelessWidget {
  const _StatusCell({
    required this.row,
    required this.statusAccent,
  });

  final CsvReviewRow row;
  final Color statusAccent;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final BorderRadius borderRadius = BorderRadius.circular(12);
    final bool hasMessages = row.messages.isNotEmpty;
    final Widget chip = Container(
      key: Key('CsvTableOverview_status_${row.originalIndex}'),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusAccent.withOpacity(0.15),
        borderRadius: borderRadius,
      ),
      child: Text(
        statusLabel(row.status),
        style: theme.textTheme.labelMedium?.copyWith(color: statusAccent),
      ),
    );

    if (!hasMessages) {
      return chip;
    }

    final String tooltipMessage = row.messages
        .map(
          (CsvReviewMessage message) =>
              '${_severityLabel(message.severity)}: ${message.message}',
        )
        .join('\n');

    return Tooltip(
      message: tooltipMessage,
      triggerMode: TooltipTriggerMode.tap,
      child: chip,
    );
  }
}

String _severityLabel(CsvReviewMessageSeverity severity) {
  switch (severity) {
    case CsvReviewMessageSeverity.info:
      return 'Informace';
    case CsvReviewMessageSeverity.warn:
      return 'Varování';
    case CsvReviewMessageSeverity.error:
      return 'Chyba';
  }
}

class _EditableCell extends StatefulWidget {
  const _EditableCell({
    required this.row,
    required this.fieldKey,
    required this.controller,
    required this.loading,
    required this.isEdited,
  });

  final CsvReviewRow row;
  final String fieldKey;
  final CsvReviewPrototypeController controller;
  final bool loading;
  final bool isEdited;

  @override
  State<_EditableCell> createState() => _EditableCellState();
}

class _EditableCellState extends State<_EditableCell> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  GlobalKey<TooltipState> _warningTooltipKey = GlobalKey<TooltipState>();
  bool _warningTooltipVisible = false;
  // TODO: Avoid rebuilding entire payload maps once controller exposes targeted update APIs.

  List<CsvReviewMessage> _scopedMessages(
    CsvFieldReview? field,
    String fieldKey,
  ) {
    if (field == null || field.messages.isEmpty) {
      return const <CsvReviewMessage>[];
    }
    return field.messages.where((CsvReviewMessage message) {
      final String? code = message.code;
      if (code == null || code.isEmpty) {
        return true;
      }
      if (code.startsWith('rc_')) {
        return fieldKey == 'rodne_cislo';
      }
      if (code.startsWith('gender_') || code == 'gender_unrecognized_input') {
        return fieldKey == 'pohlavi';
      }
      if (code.startsWith('birthdate_')) {
        return fieldKey == 'datum_narozeni';
      }
      if (code.contains('_jmeno')) {
        return fieldKey == 'jmeno';
      }
      if (code.contains('_prijmeni')) {
        return fieldKey == 'prijmeni';
      }
      if (code.startsWith('email_')) {
        return fieldKey.startsWith('email');
      }
      return true;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _displayValue);
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(covariant _EditableCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.row != oldWidget.row || widget.fieldKey != oldWidget.fieldKey) {
      _controller
        ..text = _displayValue
        ..selection = TextSelection.collapsed(offset: _controller.text.length);
    }

    if (_focusNode.hasFocus) {
      final CsvFieldReview? previousField =
          oldWidget.row.fields[oldWidget.fieldKey];
      final CsvFieldReview? currentField = _field;
      final List<CsvReviewMessage> previousMessages =
          _scopedMessages(previousField, oldWidget.fieldKey);
      final List<CsvReviewMessage> currentMessages =
          _scopedMessages(currentField, widget.fieldKey);
      final bool hadMessages = previousMessages.isNotEmpty;
      final bool hasMessages = currentMessages.isNotEmpty;
      if (hasMessages) {
        _setWarningTooltipVisibility(true);
      } else if (hadMessages && !hasMessages) {
        _setWarningTooltipVisibility(false);
      }
    }
  }

  void _handleFocusChange() {
    final CsvFieldReview? field = _field;
    final List<CsvReviewMessage> scopedMessages =
        _scopedMessages(field, widget.fieldKey);
    if (_focusNode.hasFocus && scopedMessages.isNotEmpty) {
      _setWarningTooltipVisibility(true);
    } else {
      _setWarningTooltipVisibility(false);
    }
  }

  void _setWarningTooltipVisibility(bool visible) {
    if (_warningTooltipVisible == visible) {
      if (visible) {
        _scheduleWarningTooltipShow();
      }
      return;
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _warningTooltipVisible = visible;
      if (!visible) {
        _warningTooltipKey = GlobalKey<TooltipState>();
      }
    });
    if (visible) {
      _scheduleWarningTooltipShow();
    }
  }

  void _scheduleWarningTooltipShow() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _warningTooltipKey.currentState?.ensureTooltipVisible();
    });
  }

  CsvFieldReview? get _field => widget.row.fields[widget.fieldKey];

  String get _displayValue => formatCsvFieldDisplay(widget.fieldKey, _field);

  String _normalizeForPayload(String value) {
    return normalizeCsvFieldInput(widget.fieldKey, value, _field);
  }

  Future<void> _persistIfChanged(BuildContext context, String userValue) async {
    final String normalizedValue = _normalizeForPayload(userValue);
    final String previousValue = _field?.normalizedValue ?? '';
    if (previousValue == normalizedValue) {
      return;
    }
    final Map<String, String?> payload =
        widget.controller.buildPayload(widget.row);
    payload[widget.fieldKey] = normalizedValue;
    try {
      await widget.controller.editRow(widget.row, payload);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Úpravu se nepodařilo uložit.')),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode
      ..removeListener(_handleFocusChange)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CsvFieldReview? field = _field;
    final List<CsvReviewMessage> scopedMessages =
        _scopedMessages(field, widget.fieldKey);
    final bool hasWarning = field?.status == CsvFieldReviewStatus.warn ||
        field?.status == CsvFieldReviewStatus.bad;
    final bool showChangeHighlight = widget.isEdited;
    // Use a vivid blue so edited cells pop during prototype QA passes.
    const Color vividHighlight = Color(0xFF1E88E5);
    final OutlineInputBorder baseBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(4),
    );
    final OutlineInputBorder highlightBorder = baseBorder.copyWith(
      borderSide: BorderSide(
        color: vividHighlight,
        width: 1.4,
      ),
    );
    return TextFormField(
      key: Key(
          'CsvTableOverview_cell_${widget.row.originalIndex}_${widget.fieldKey}'),
      controller: _controller,
      enabled: !widget.loading,
      focusNode: _focusNode,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        border: baseBorder,
        enabledBorder: showChangeHighlight ? highlightBorder : baseBorder,
        focusedBorder: showChangeHighlight ? highlightBorder : null,
        filled: showChangeHighlight,
        fillColor:
            showChangeHighlight ? vividHighlight.withOpacity(0.16) : null,
        suffixIcon: hasWarning && scopedMessages.isNotEmpty
            ? _FieldWarningIcon(
                iconKey: Key(
                    'CsvTableOverview_field_warning_${widget.row.originalIndex}_${widget.fieldKey}'),
                tooltipStateKey: _warningTooltipKey,
                messages: scopedMessages,
              )
            : null,
      ),
      onFieldSubmitted: (String value) async {
        await _persistIfChanged(context, value);
      },
      onTapOutside: (PointerDownEvent _) async {
        await _persistIfChanged(context, _controller.text);
      },
    );
  }
}

class _FieldWarningIcon extends StatelessWidget {
  const _FieldWarningIcon({
    required this.iconKey,
    required this.tooltipStateKey,
    required this.messages,
  });

  final Key iconKey;
  final GlobalKey<TooltipState> tooltipStateKey;
  final List<CsvReviewMessage> messages;

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return Icon(
        Icons.warning_amber_outlined,
        key: iconKey,
        color: Colors.orange,
      );
    }
    final Widget icon = Icon(
      Icons.warning_amber_outlined,
      key: iconKey,
      color: Colors.orange,
    );
    final String tooltipMessage = messages
        .map((CsvReviewMessage message) =>
            '${_severityLabel(message.severity)}: ${message.message}')
        .join('\n');
    return Tooltip(
      key: tooltipStateKey,
      message: tooltipMessage,
      triggerMode: TooltipTriggerMode.manual,
      waitDuration: Duration.zero,
      showDuration: const Duration(days: 1),
      preferBelow: false,
      child: icon,
    );
  }
}
