import 'package:denik_zza/input/csv_review_models.dart';
import 'package:denik_zza/services/csv_import_service.dart';
import 'package:denik_zza/screens2/csv_review/widgets/bulk_action_bar.dart';
import 'package:denik_zza/screens2/csv_review/widgets/csv_row_edit_dialog.dart';
import 'package:denik_zza/screens2/csv_review/widgets/finalize_card.dart';
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
  CsvRowReviewStatus? _activeStatus;
  late List<_TableFilter> _filters;
  late List<String> _columnOrder;
  late final ScrollController _horizontalScrollController;

  CsvReviewPrototypeController get _controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _filters = <_TableFilter>[
      const _TableFilter(label: 'Vše', status: null, key: 'CsvTableFilter_all'),
      const _TableFilter(label: 'Chyby', status: CsvRowReviewStatus.rejected, key: 'CsvTableFilter_rejected'),
      const _TableFilter(label: 'Varování', status: CsvRowReviewStatus.warn, key: 'CsvTableFilter_warn'),
      const _TableFilter(label: 'Informace', status: CsvRowReviewStatus.info, key: 'CsvTableFilter_info'),
      const _TableFilter(label: 'V pořádku', status: CsvRowReviewStatus.ok, key: 'CsvTableFilter_ok'),
    ];
    _activeStatus = null;
    _columnOrder = _resolveColumnOrder();
    _horizontalScrollController = ScrollController();
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
    super.dispose();
  }

  List<String> _resolveColumnOrder() {
    if (_controller.rows.isEmpty) {
      return const <String>[];
    }
    final CsvReviewRow sample = _controller.rows.first;
    final List<MapEntry<String, CsvFieldReview>> entries =
        sample.fields.entries.toList()
          ..sort((MapEntry<String, CsvFieldReview> a,
                  MapEntry<String, CsvFieldReview> b) =>
              a.value.columnName.compareTo(b.value.columnName));
    return entries
        .map((MapEntry<String, CsvFieldReview> entry) => entry.key)
        .take(6)
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tabulkový přehled CSV'),
        actions: <Widget>[
          IconButton(
            key: const Key('CsvTableOverview_refresh'),
            icon: const Icon(Icons.refresh),
            onPressed: _controller.reload,
            tooltip: 'Znovu načíst soubor',
          ),
        ],
      ),
      body: _controller.session == null
          ? const SizedBox.shrink()
          : Column(
              children: <Widget>[
                _SummaryHeader(controller: _controller),
                _buildFilterRow(context),
                const Divider(height: 1),
                Expanded(
                  child: Scrollbar(
                    controller: _horizontalScrollController,
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      key: const Key('CsvTableOverview_horizontalScroll'),
                      controller: _horizontalScrollController,
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minWidth: 960),
                        child: _buildTable(context),
                      ),
                    ),
                  ),
                ),
              ],
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
                  children: <Widget>[
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        children: _filters.map((_TableFilter filter) {
          final bool selected = _activeStatus == filter.status;
          final int count = filter.status == null
              ? _controller.totalRowCount
              : _controller.groupedRows[filter.status]?.length ?? 0;
          return ChoiceChip(
            key: Key(filter.key),
            label: Text('${filter.label} ($count)'),
            selected: selected,
            onSelected: (bool value) {
              setState(() {
                _activeStatus = value ? filter.status : null;
              });
            },
            selectedColor: theme.colorScheme.primaryContainer,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTable(BuildContext context) {
    final List<CsvReviewRow> rows =
        _controller.rowsForStatus(_activeStatus);
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
      const DataColumn(label: Text('Rozhodnutí')),
      const DataColumn(label: Text('Stav')),
      const DataColumn(label: Text('Duplicitní?')),
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
        final CsvRowDecision decision =
            _controller.decisionForRow(row.originalIndex);
        final bool loading = _controller.isRowLoading(row.originalIndex);
        final bool edited = _controller.isRowEdited(row.originalIndex);
        final bool hasDuplicate =
            _controller.hasDuplicate(row.originalIndex);
        final Color statusAccent = statusColor(
          Theme.of(context),
          row.status,
        );
        return DataRow(
          key: ValueKey<int>(row.originalIndex),
          selected: decision == CsvRowDecision.approved,
          onSelectChanged: loading
              ? null
              : (bool? value) {
                  if (value == null) {
                    return;
                  }
                  _controller.updateDecision(
                    row.originalIndex,
                    value ? CsvRowDecision.approved : CsvRowDecision.none,
                  );
                },
          cells: <DataCell>[
            DataCell(
              DropdownButton<CsvRowDecision>(
                key: Key('CsvTableOverview_decision_${row.originalIndex}'),
                value: decision,
                onChanged: loading
                    ? null
                    : (CsvRowDecision? value) {
                        if (value == null) {
                          return;
                        }
                        _controller.updateDecision(row.originalIndex, value);
                      },
                items: const <DropdownMenuItem<CsvRowDecision>>[
                  DropdownMenuItem(
                    value: CsvRowDecision.none,
                    child: Text('Bez rozhodnutí'),
                  ),
                  DropdownMenuItem(
                    value: CsvRowDecision.approved,
                    child: Text('Přijmout'),
                  ),
                  DropdownMenuItem(
                    value: CsvRowDecision.rejected,
                    child: Text('Zamítnout'),
                  ),
                ],
              ),
            ),
            DataCell(
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
            DataCell(
              hasDuplicate
                  ? Tooltip(
                      message: 'Potenciální duplicitní záznam',
                      child: Icon(
                        Icons.error_outline,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    )
                  : const Icon(Icons.check_circle_outline, color: Colors.green),
            ),
            ..._columnOrder.map(
              (String key) => DataCell(
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 220),
                  child: _EditableCell(
                    row: row,
                    fieldKey: key,
                    controller: _controller,
                    loading: loading,
                    edited: edited,
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
    required this.edited,
  });

  final CsvReviewRow row;
  final String fieldKey;
  final CsvReviewPrototypeController controller;
  final bool loading;
  final bool edited;

  @override
  State<_EditableCell> createState() => _EditableCellState();
}

class _EditableCellState extends State<_EditableCell> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _currentValue);
  }

  @override
  void didUpdateWidget(covariant _EditableCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.row != oldWidget.row || widget.fieldKey != oldWidget.fieldKey) {
      _controller.text = _currentValue;
    }
  }

  String get _currentValue {
    final CsvFieldReview? field = widget.row.fields[widget.fieldKey];
    return field?.normalizedValue ?? field?.originalValue ?? '';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CsvFieldReview? field = widget.row.fields[widget.fieldKey];
    final bool hasWarning =
        field?.status == CsvFieldReviewStatus.warn ||
            field?.status == CsvFieldReviewStatus.bad;
    return TextFormField(
      key: Key('CsvTableOverview_cell_${widget.row.originalIndex}_${widget.fieldKey}'),
      controller: _controller,
      enabled: !widget.loading,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        border: const OutlineInputBorder(),
        suffixIcon: hasWarning
            ? const Icon(Icons.warning_amber_outlined, color: Colors.orange)
            : (widget.edited
                ? const Icon(Icons.edit, color: Colors.blueAccent)
                : null),
      ),
      onFieldSubmitted: (String value) async {
        final Map<String, String?> payload =
            widget.controller.buildPayload(widget.row);
        payload[widget.fieldKey] = value.trim();
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
        payload[widget.fieldKey] = _controller.text.trim();
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

class _SummaryHeader extends StatelessWidget {
  const _SummaryHeader({
    required this.controller,
  });

  final CsvReviewPrototypeController controller;

  @override
  Widget build(BuildContext context) {
    final CsvImportSession? session = controller.session;
    if (session == null) {
      return const SizedBox.shrink();
    }
    return Material(
      elevation: 4,
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        key: const Key('CsvTableOverview_summary'),
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SummarySection(
            review: session.review,
            groupedRows: controller.groupedRows,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: <Widget>[
                ElevatedButton.icon(
                  key: const Key('CsvTableOverview_editDialog'),
                  onPressed: controller.rows.isEmpty
                      ? null
                      : () async {
                          final CsvReviewRow firstRow = controller.rows.first;
                          final Map<String, String?> payload =
                              controller.buildPayload(firstRow);
                          final Map<String, String?>? dialogResult =
                              await showDialog<Map<String, String?>>(
                            context: context,
                            builder: (BuildContext context) => CsvRowEditDialog(
                              row: firstRow,
                            ),
                          );
                          if (dialogResult != null) {
                            try {
                              await controller.editRow(firstRow, dialogResult);
                            } catch (_) {
                              if (!context.mounted) {
                                return;
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Úprava se nepodařila uložit.')),
                              );
                            }
                          } else {
                            controller.editRow(firstRow, payload);
                          }
                        },
                  icon: const Icon(Icons.edit_square),
                  label: const Text('Upravit první řádek'),
                ),
                const SizedBox(width: 12),
                if (controller.duplicateRowCount > 0)
                  Chip(
                    key: const Key('CsvTableOverview_duplicatesChip'),
                    backgroundColor:
                        Theme.of(context).colorScheme.errorContainer,
                    avatar: Icon(
                      Icons.warning,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                    label: Text(
                      'Duplicitní: ${controller.duplicateRowCount}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onErrorContainer,
                          ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
