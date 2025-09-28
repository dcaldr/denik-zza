import 'package:denik_zza/input/csv_review_models.dart';
import 'package:denik_zza/services/csv_import_service.dart';
import 'package:denik_zza/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import 'widgets/bulk_action_bar.dart';
import 'widgets/csv_review_row_card.dart';
import 'widgets/csv_row_edit_dialog.dart';
import 'widgets/error_placeholder.dart';
import 'widgets/finalize_card.dart';
import 'widgets/summary_section.dart';
import 'widgets/unparsed_columns_section.dart';

/// Screen that allows the operator to review parsed CSV rows and confirm import decisions.
class CsvReviewScreen extends StatefulWidget {
  CsvReviewScreen({
    super.key,
    required this.filePath,
    CsvReviewService? service,
  }) : service = service ?? CsvImportService();

  final String filePath;
  final CsvReviewService service;

  @override
  State<CsvReviewScreen> createState() => _CsvReviewScreenState();
}

class _CsvReviewScreenState extends State<CsvReviewScreen> {
  final Logger _logger = AppLogger.l;

  bool _isLoading = true;
  Object? _loadError;
  bool _isFinalizing = false;
  CsvImportSession? _session;
  List<CsvReviewRow> _rows = <CsvReviewRow>[];
  Map<CsvRowReviewStatus, List<CsvReviewRow>> _groupedRows =
      _emptyGroupedRows();
  Map<int, CsvRowDecision> _decisions = <int, CsvRowDecision>{};
  Set<int> _editedRows = <int>{};
  Set<int> _loadingRows = <int>{};
  Map<int, List<CsvDuplicateCandidate>> _duplicateMatches =
      <int, List<CsvDuplicateCandidate>>{};
  String _activeFilterKey = _statusFilters.first.key;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    Map<int, List<CsvDuplicateCandidate>> _cloneDuplicateMatches(
      Map<int, List<CsvDuplicateCandidate>> source,
    ) {
      return source.map(
        (int key, List<CsvDuplicateCandidate> value) =>
            MapEntry<int, List<CsvDuplicateCandidate>>(
                key, List<CsvDuplicateCandidate>.from(value)),
      );
    }

    try {
      final CsvImportSession session =
          await widget.service.loadCsv(widget.filePath);
      Map<int, List<CsvDuplicateCandidate>> duplicates =
          <int, List<CsvDuplicateCandidate>>{};
      try {
        duplicates =
            await widget.service.findPotentialDuplicates(session: session);
      } catch (error, stackTrace) {
        _logger.w(
          'Duplicate detection failed for CSV review session.',
          error: error,
          stackTrace: stackTrace,
        );
      }

      if (!mounted) {
        return;
      }

      final List<CsvReviewRow> rows =
          List<CsvReviewRow>.from(session.review.rows)
            ..sort((CsvReviewRow a, CsvReviewRow b) =>
                a.originalIndex.compareTo(b.originalIndex));

      setState(() {
        _session = session;
        _rows = rows;
        _groupedRows = _groupRows(rows);
        _decisions = <int, CsvRowDecision>{};
        _editedRows = <int>{};
        _loadingRows = <int>{};
        _duplicateMatches = _cloneDuplicateMatches(duplicates);
        _activeFilterKey = _statusFilters.first.key;
        _isLoading = false;
        _isFinalizing = false;
      });
    } catch (error, stackTrace) {
      _logger.e('Failed to load CSV review session.',
          error: error, stackTrace: stackTrace);
      if (!mounted) {
        return;
      }
      setState(() {
        _session = null;
        _rows = <CsvReviewRow>[];
        _groupedRows = _emptyGroupedRows();
        _decisions = <int, CsvRowDecision>{};
        _duplicateMatches = <int, List<CsvDuplicateCandidate>>{};
        _isLoading = false;
        _loadError = error;
      });
    }
  }

  Map<CsvRowReviewStatus, List<CsvReviewRow>> _groupRows(
      List<CsvReviewRow> rows) {
    final Map<CsvRowReviewStatus, List<CsvReviewRow>> grouped =
        _emptyGroupedRows();
    for (final CsvReviewRow row in rows) {
      grouped[row.status]!.add(row);
    }
    return grouped;
  }

  List<CsvReviewRow> get _filteredRows {
    final _StatusFilter filter = _statusFilters.firstWhere(
        (_StatusFilter candidate) => candidate.key == _activeFilterKey);
    if (filter.status == null) {
      return List<CsvReviewRow>.unmodifiable(_rows);
    }
    return List<CsvReviewRow>.unmodifiable(_groupedRows[filter.status]!);
  }

  int get _approvedCount => _decisions.values
      .where((CsvRowDecision decision) => decision == CsvRowDecision.approved)
      .length;

  int get _rejectedCount => _decisions.values
      .where((CsvRowDecision decision) => decision == CsvRowDecision.rejected)
      .length;

  int get _undecidedCount => _rows.length - _approvedCount - _rejectedCount;

  int get _duplicateRowCount => _duplicateMatches.entries
      .where((MapEntry<int, List<CsvDuplicateCandidate>> entry) =>
          entry.value.isNotEmpty)
      .length;

  bool _hasDuplicate(int rowIndex) =>
      _duplicateMatches[rowIndex]?.isNotEmpty ?? false;

  CsvRowDecision _decisionForRow(int rowIndex) =>
      _decisions[rowIndex] ?? CsvRowDecision.none;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kontrola importu CSV'),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _loadError != null
                ? ErrorPlaceholder(onRetry: _loadSession)
                : _session == null
                    ? const SizedBox.shrink()
                    : _buildLoadedContent(),
      ),
    );
  }

  Widget _buildLoadedContent() {
    final List<Widget> children = <Widget>[
      SummarySection(
        review: _session!.review,
        groupedRows: _groupedRows,
      ),
      BulkActionBar(
        approvedCount: _approvedCount,
        rejectedCount: _rejectedCount,
        onApproveOk: _handleBulkApproveOk,
        onApproveUpToInfo: _handleBulkApproveInfo,
        onClearApprovals: _handleBulkClearApprovals,
        onRejectAll: _handleBulkRejectAll,
        onRejectOnlyRejected: _handleBulkRejectOnlyRejected,
      ),
      UnparsedColumnsSection(
        unparsedColumns: _session!.review.unparsedColumns,
      ),
      _buildStatusTabs(),
      if (_filteredRows.isEmpty) ...<Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: const Center(
            child: Text(
              'V této kategorii nejsou žádné řádky.',
              key: Key('CsvReviewScreen_empty_state'),
            ),
          ),
        ),
      ] else ...<Widget>[
        for (final CsvReviewRow row in _filteredRows) _buildRowCard(row),
      ],
      FinalizeCard(
        approvedCount: _approvedCount,
        rejectedCount: _rejectedCount,
        undecidedCount: _undecidedCount,
        duplicateCount: _duplicateRowCount,
        isFinalizing: _isFinalizing,
        onFinalize: _handleFinalize,
      ),
      const SizedBox(height: 24),
    ];

    return ListView(
      key: const Key('CsvReviewScreen_content'),
      padding: const EdgeInsets.only(bottom: 24),
      children: children,
    );
  }

  Widget _buildStatusTabs() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _statusFilters.map((_StatusFilter filter) {
          final bool selected = filter.key == _activeFilterKey;
          final int count = filter.status == null
              ? _rows.length
              : _groupedRows[filter.status]!.length;
          return ChoiceChip(
            key: Key(filter.key),
            label: Text('${filter.label} ($count)'),
            selected: selected,
            onSelected: (bool value) {
              if (!value || filter.key == _activeFilterKey) {
                return;
              }
              setState(() {
                _activeFilterKey = filter.key;
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRowCard(CsvReviewRow row) {
    final int rowIndex = row.originalIndex;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: CsvReviewRowCard(
        row: row,
        onRowEdit: () => _showRowEditDialog(row),
        onFieldEdit: (CsvFieldReview field, {String? overrideValue}) =>
            _handleFieldEdit(row, field, overrideValue: overrideValue),
        isEdited: _editedRows.contains(rowIndex),
        isLoading: _loadingRows.contains(rowIndex),
        decision: _decisionForRow(rowIndex),
        duplicateMatches:
            _duplicateMatches[rowIndex] ?? const <CsvDuplicateCandidate>[],
        onDecisionChanged: (CsvRowDecision decision) =>
            _updateRowDecision(rowIndex, decision),
      ),
    );
  }

  void _updateRowDecision(int rowIndex, CsvRowDecision decision) {
    setState(() {
      if (decision == CsvRowDecision.none) {
        _decisions.remove(rowIndex);
      } else {
        _decisions[rowIndex] = decision;
      }
    });
  }

  void _handleBulkApproveOk() {
    setState(() {
      for (final CsvReviewRow row in _groupedRows[CsvRowReviewStatus.ok]!) {
        if (_hasDuplicate(row.originalIndex)) {
          continue;
        }
        _decisions[row.originalIndex] = CsvRowDecision.approved;
      }
    });
  }

  void _handleBulkApproveInfo() {
    const Set<CsvRowReviewStatus> autoStatuses = <CsvRowReviewStatus>{
      CsvRowReviewStatus.ok,
      CsvRowReviewStatus.info,
    };
    setState(() {
      for (final CsvReviewRow row in _rows) {
        if (!autoStatuses.contains(row.status)) {
          continue;
        }
        if (_hasDuplicate(row.originalIndex)) {
          continue;
        }
        _decisions[row.originalIndex] = CsvRowDecision.approved;
      }
    });
  }

  void _handleBulkClearApprovals() {
    setState(() {
      _decisions.removeWhere(
        (int _, CsvRowDecision value) => value == CsvRowDecision.approved,
      );
    });
  }

  void _handleBulkRejectAll() {
    setState(() {
      for (final CsvReviewRow row in _rows) {
        _decisions[row.originalIndex] = CsvRowDecision.rejected;
      }
    });
  }

  void _handleBulkRejectOnlyRejected() {
    setState(() {
      for (final CsvReviewRow row in _rows) {
        if (row.status == CsvRowReviewStatus.rejected) {
          _decisions[row.originalIndex] = CsvRowDecision.rejected;
        } else if (_decisions[row.originalIndex] == CsvRowDecision.rejected) {
          _decisions.remove(row.originalIndex);
        }
      }
    });
  }

  Future<void> _handleFieldEdit(
    CsvReviewRow row,
    CsvFieldReview field, {
    String? overrideValue,
  }) async {
    if (overrideValue == null) {
      await _showRowEditDialog(row, focusColumn: field.columnKey);
      return;
    }

    final Map<String, String?> payload = _buildPayload(row);
    final String trimmedValue = overrideValue.trim();
    payload[field.columnKey] = trimmedValue;
    await _submitRowUpdate(row.originalIndex, payload);
  }

  Future<void> _showRowEditDialog(CsvReviewRow row,
      {String? focusColumn}) async {
    final Map<String, String?>? payload =
        await showDialog<Map<String, String?>>(
      context: context,
      builder: (BuildContext context) => CsvRowEditDialog(
        row: row,
        focusColumn: focusColumn,
      ),
    );

    if (payload != null) {
      await _submitRowUpdate(row.originalIndex, payload);
    }
  }

  Future<void> _submitRowUpdate(
      int rowIndex, Map<String, String?> payload) async {
    setState(() {
      _loadingRows.add(rowIndex);
    });

    try {
      final CsvReviewRow updatedRow = await widget.service.reparseRow(payload);
      if (!mounted) {
        return;
      }
      setState(() {
        _loadingRows.remove(rowIndex);
        _editedRows.add(rowIndex);
        _duplicateMatches.remove(rowIndex);
        _replaceRow(updatedRow);
      });
    } catch (error, stackTrace) {
      _logger.e('Failed to update CSV row $rowIndex',
          error: error, stackTrace: stackTrace);
      if (!mounted) {
        return;
      }
      setState(() {
        _loadingRows.remove(rowIndex);
      });
      _showErrorSnackBar(
          'Nepodařilo se uložit změny řádku. Zkuste to prosím znovu.');
    }
  }

  void _replaceRow(CsvReviewRow updatedRow) {
    final List<CsvReviewRow> newRows = List<CsvReviewRow>.from(_rows);
    final int index = newRows.indexWhere(
        (CsvReviewRow row) => row.originalIndex == updatedRow.originalIndex);
    if (index >= 0) {
      newRows[index] = updatedRow;
    } else {
      newRows.add(updatedRow);
    }
    newRows.sort((CsvReviewRow a, CsvReviewRow b) =>
        a.originalIndex.compareTo(b.originalIndex));

    _rows = newRows;
    _groupedRows = _groupRows(newRows);
    final CsvImportSession? current = _session;
    if (current != null) {
      _session = CsvImportSession(
        review: CsvImportReview(
          unparsedColumns: current.review.unparsedColumns,
          rows: newRows,
        ),
        personResult: current.personResult,
      );
    }
  }

  Map<String, String?> _buildPayload(CsvReviewRow row) {
    final Map<String, String?> payload = <String, String?>{};
    row.fields.forEach((String key, CsvFieldReview field) {
      final String? value = field.originalValue ?? field.normalizedValue;
      payload[key] = value?.trim() ?? '';
    });
    return payload;
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _handleFinalize() async {
    final CsvImportSession? session = _session;
    if (session == null || _approvedCount == 0) {
      return;
    }

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          key: const Key('CsvReviewScreen_finalize_confirm_dialog'),
          title: const Text('Potvrdit import'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Schválíte: $_approvedCount řádků'),
              Text('Odmítnete: $_rejectedCount řádků'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              key: const Key('CsvReviewScreen_finalize_cancel_button'),
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Zrušit'),
            ),
            FilledButton(
              key: const Key('CsvReviewScreen_finalize_confirm_button'),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Potvrdit'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    setState(() {
      _isFinalizing = true;
    });

    try {
      final CsvFinalizeResult result = await widget.service.finalizeImport(
        session: session,
        decisions: _decisions,
      );
      if (!mounted) {
        return;
      }

      setState(() {
        _isFinalizing = false;
      });

      await showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            key: const Key('CsvReviewScreen_finalize_summary_dialog'),
            title: const Text('Shrnutí importu'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Uloženo: ${result.savedCount}'),
                Text('Nepodařilo se uložit: ${result.failedCount}'),
                if (result.failures.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 12),
                  for (final CsvFinalizeFailure failure in result.failures)
                    Text('Řádek ${failure.originalIndex}: ${failure.message}'),
                ],
              ],
            ),
            actions: <Widget>[
              TextButton(
                key: const Key('CsvReviewScreen_finalize_summary_close'),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Zavřít'),
              ),
            ],
          );
        },
      );

      if (!mounted) {
        return;
      }

      await _loadSession();
    } catch (error, stackTrace) {
      _logger.e('Finalize import failed.',
          error: error, stackTrace: stackTrace);
      if (!mounted) {
        return;
      }
      setState(() {
        _isFinalizing = false;
      });
      _showErrorSnackBar('Dokončení importu selhalo. Zkuste to prosím znovu.');
    }
  }
}

class _StatusFilter {
  const _StatusFilter({
    required this.key,
    required this.label,
    required this.status,
  });

  final String key;
  final String label;
  final CsvRowReviewStatus? status;
}

Map<CsvRowReviewStatus, List<CsvReviewRow>> _emptyGroupedRows() {
  return <CsvRowReviewStatus, List<CsvReviewRow>>{
    CsvRowReviewStatus.rejected: <CsvReviewRow>[],
    CsvRowReviewStatus.warn: <CsvReviewRow>[],
    CsvRowReviewStatus.info: <CsvReviewRow>[],
    CsvRowReviewStatus.ok: <CsvReviewRow>[],
  };
}

const List<_StatusFilter> _statusFilters = <_StatusFilter>[
  _StatusFilter(
    key: 'CsvReviewScreen_tab_rejected',
    label: 'Zamítnuté',
    status: CsvRowReviewStatus.rejected,
  ),
  _StatusFilter(
    key: 'CsvReviewScreen_tab_warn',
    label: 'Varování',
    status: CsvRowReviewStatus.warn,
  ),
  _StatusFilter(
    key: 'CsvReviewScreen_tab_info',
    label: 'Informace',
    status: CsvRowReviewStatus.info,
  ),
  _StatusFilter(
    key: 'CsvReviewScreen_tab_ok',
    label: 'Platné',
    status: CsvRowReviewStatus.ok,
  ),
  _StatusFilter(
    key: 'CsvReviewScreen_tab_all',
    label: 'Vše',
    status: null,
  ),
];
