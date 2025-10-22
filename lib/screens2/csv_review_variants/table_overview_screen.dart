import 'dart:math' as math;

import 'package:denik_zza/input/csv_review_models.dart';
import 'package:denik_zza/services/csv_import_service.dart';
import 'package:denik_zza/screens2/csv_review/widgets/summary_section.dart';
import 'package:flutter/material.dart';

import 'csv_review_shared.dart';

/// Tabular CSV confirmation prototype with sticky summary header and inline
/// editing.
class CsvReviewTableOverviewScreen extends StatelessWidget {
  const CsvReviewTableOverviewScreen({
    super.key,
    required this.filePath,
    this.service,
  });

  final String filePath;
  final CsvReviewService? service;

  @override
  Widget build(BuildContext context) {
    return CsvReviewPrototypeHost(
      filePath: filePath,
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
  late final ScrollController _horizontalScrollController;
  late final ScrollController _verticalScrollController;

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
    _horizontalScrollController = ScrollController();
    _verticalScrollController = ScrollController();
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
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
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
    return Scaffold(
      body: _controller.session == null
          ? const SizedBox.shrink()
          : SafeArea(
              child: Scrollbar(
                controller: _verticalScrollController,
                thumbVisibility: true,
                child: ListView(
                  controller: _verticalScrollController,
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 24 +
                        kBottomNavigationBarHeight +
                        MediaQuery.of(context).viewPadding.bottom,
                  ),
                  children: <Widget>[
                    _buildTitleRow(context),
                    const SizedBox(height: 8),
                    _buildSummaryPanel(context),
                    const SizedBox(height: 8),
                    _buildFilterRow(context),
                    const Divider(height: 16),
                    _buildTableSection(context),
                  ],
                ),
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
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Tabulkový přehled CSV',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
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

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Wrap(
          key: const Key('CsvTableOverview_summary_content'),
          spacing: 16,
          runSpacing: 16,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(Icons.insights_outlined, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  'Shrnutí souboru',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            SummaryBadge(
              key: const Key('CsvTableOverview_summary_rejected_count'),
              label: 'Zamítnuto',
              count: grouped[CsvRowReviewStatus.rejected]?.length ?? 0,
              color: statusColor(theme, CsvRowReviewStatus.rejected),
            ),
            SummaryBadge(
              key: const Key('CsvTableOverview_summary_warn_count'),
              label: 'Varování',
              count: warnCount,
              color: statusColor(theme, CsvRowReviewStatus.warn),
            ),
            SummaryBadge(
              key: const Key('CsvTableOverview_summary_info_count'),
              label: 'Informace',
              count: infoCount,
              color: statusColor(theme, CsvRowReviewStatus.info),
            ),
            SummaryBadge(
              key: const Key('CsvTableOverview_summary_ok_count'),
              label: 'Platné',
              count: validCount,
              color: statusColor(theme, CsvRowReviewStatus.ok),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Celkem řádků: $totalCount',
                key: const Key('CsvTableOverview_summary_total'),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableSection(BuildContext context) {
    final double viewportWidth = MediaQuery.of(context).size.width;
    final double minTableWidth = math.max(960, viewportWidth - 32);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Scrollbar(
        controller: _horizontalScrollController,
        thumbVisibility: true,
        notificationPredicate: (ScrollNotification notification) =>
            notification.metrics.axis == Axis.horizontal,
        child: SingleChildScrollView(
          key: const Key('CsvTableOverview_horizontalScroll'),
          controller: _horizontalScrollController,
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: minTableWidth),
            child: _buildTable(context),
          ),
        ),
      ),
    );
  }

  Widget _buildFooterButtons(BuildContext context) {
    final int selectedCount = _controller.selectedRowCount;
    final bool hasRejections = _controller.hasRejectedDecisions;
    final bool canApproveAllValid = _controller.canApproveAllValid;
    final bool hasRows = _controller.totalRowCount > 0;
    final String approveSelectedLabel = selectedCount > 0
        ? 'Schválit vybrané ($selectedCount)'
        : 'Schválit vybrané';
    final String rejectLabel =
        hasRejections ? 'Zrušit odmítnutí' : 'Odmítnout vše';
    final IconData rejectIcon = hasRejections ? Icons.undo : Icons.block;

    return Wrap(
      alignment: WrapAlignment.end,
      spacing: 12,
      runSpacing: 12,
      children: <Widget>[
        FilledButton.icon(
          key: const Key('CsvTableOverview_action_approve_all_valid'),
          onPressed: canApproveAllValid ? _controller.approveAllValid : null,
          icon: const Icon(Icons.library_add_check),
          label: const Text('Schválit všechny platné'),
        ),
        OutlinedButton.icon(
          key: const Key('CsvTableOverview_action_approve_selected'),
          onPressed: selectedCount == 0 ? null : _controller.approveSelected,
          icon: const Icon(Icons.task_alt),
          label: Text(approveSelectedLabel),
        ),
        FilledButton.icon(
          key: const Key('CsvTableOverview_action_reject_toggle'),
          onPressed: hasRows ? _controller.toggleRejectAll : null,
          icon: Icon(rejectIcon),
          label: Text(rejectLabel),
        ),
      ],
    );
  }

  Widget _buildTable(BuildContext context) {
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

    final List<DataColumn> columns = <DataColumn>[
      const DataColumn(label: Text('Stav')),
      ..._columnOrder.map(
        (String key) => DataColumn(
          label: Text(_fieldLabel(rows.first, key)),
        ),
      ),
    ];

    return DataTable(
      key: const Key('CsvTableOverview_table'),
      columns: columns,
      columnSpacing: 24,
      headingRowColor: MaterialStateProperty.all<Color>(
        Theme.of(context).colorScheme.surfaceVariant,
      ),
      rows: rows.map((CsvReviewRow row) {
        final bool loading = _controller.isRowLoading(row.originalIndex);
        final bool hasDuplicate = _controller.hasDuplicate(row.originalIndex);
        final bool isSelected = _controller.isRowSelected(row.originalIndex);
        final Color statusAccent = statusColor(
          Theme.of(context),
          row.status,
        );
        return DataRow(
          key: ValueKey<int>(row.originalIndex),
          selected: isSelected,
          onSelectChanged: loading
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusAccent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusLabel(row.status),
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(color: statusAccent),
                ),
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

  String _fieldLabel(CsvReviewRow row, String key) {
    return row.fields[key]?.columnName ?? key;
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

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _displayValue);
  }

  @override
  void didUpdateWidget(covariant _EditableCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.row != oldWidget.row || widget.fieldKey != oldWidget.fieldKey) {
      _controller
        ..text = _displayValue
        ..selection = TextSelection.collapsed(offset: _controller.text.length);
    }
  }

  CsvFieldReview? get _field => widget.row.fields[widget.fieldKey];

  String get _displayValue => formatCsvFieldDisplay(widget.fieldKey, _field);

  String _normalizeForPayload(String value) {
    return normalizeCsvFieldInput(widget.fieldKey, value, _field);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CsvFieldReview? field = _field;
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
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        border: baseBorder,
        enabledBorder: showChangeHighlight ? highlightBorder : baseBorder,
        focusedBorder: showChangeHighlight ? highlightBorder : null,
        filled: showChangeHighlight,
    fillColor:
      showChangeHighlight ? vividHighlight.withOpacity(0.16) : null,
        suffixIcon: hasWarning
            ? const Icon(Icons.warning_amber_outlined, color: Colors.orange)
            : null,
      ),
      onFieldSubmitted: (String value) async {
        final Map<String, String?> payload =
            widget.controller.buildPayload(widget.row);
        payload[widget.fieldKey] = _normalizeForPayload(value);
        try {
          await widget.controller.editRow(widget.row, payload);
        } catch (_) {
          if (!mounted) {
            return;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Úpravu se nepodařilo uložit.')),
          );
        }
      },
      onTapOutside: (PointerDownEvent _) async {
        final Map<String, String?> payload =
            widget.controller.buildPayload(widget.row);
        payload[widget.fieldKey] = _normalizeForPayload(_controller.text);
        try {
          await widget.controller.editRow(widget.row, payload);
        } catch (_) {
          if (!mounted) {
            return;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Úpravu se nepodařilo uložit.')),
          );
        }
      },
      onTap: () async {
        if (field == null) {
          return;
        }
        if (field.messages.isNotEmpty) {
          await showDialog<void>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: Text(field.columnName),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: field.messages
                    .map(
                      (CsvReviewMessage message) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(message.message),
                      ),
                    )
                    .toList(),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Zavřít'),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
