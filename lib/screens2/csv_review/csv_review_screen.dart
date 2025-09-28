import 'package:denik_zza/input/csv_review_models.dart';
import 'package:denik_zza/services/csv_import_service.dart';
import 'package:denik_zza/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

/// CSV review page that surfaces parsing results and basic row summaries.
class CsvReviewScreen extends StatefulWidget {
  const CsvReviewScreen({
    super.key,
    required this.filePath,
    required this.service,
  });

  final String filePath;
  final CsvReviewService service;

  @override
  State<CsvReviewScreen> createState() => _CsvReviewScreenState();
}

class _CsvReviewScreenState extends State<CsvReviewScreen> {
  final Logger _logger = AppLogger.l;
  bool _isLoading = true;
  CsvImportSession? _session;
  Object? _error;
  bool _isFinalizing = false;
  final Set<int> _rowsInProgress = <int>{};
  final Set<int> _editedRows = <int>{};
  final Map<int, CsvRowDecision> _decisions = <int, CsvRowDecision>{};
  Map<int, List<CsvDuplicateCandidate>> _duplicateMatches =
      <int, List<CsvDuplicateCandidate>>{};

  @override
  void initState() {
    super.initState();
    _loadReview();
  }

  Future<void> _loadReview() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final CsvImportSession session = await widget.service.loadCsv(widget.filePath);
      if (!mounted) {
        return;
      }
      setState(() {
        _decisions.clear();
        _session = session;
        _isLoading = false;
        _duplicateMatches = <int, List<CsvDuplicateCandidate>>{};
      });
      await _loadDuplicateMatches(session);
    } catch (error, stackTrace) {
      _logger.e(
        'Failed to load CSV review data',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _error = error;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleRowEdit(CsvReviewRow row) async {
    final Map<String, String?>? updatedValues = await _showRowEditDialog(row);
    if (updatedValues == null) {
      return;
    }
    await _applyRowUpdate(
      row: row,
      updatedValues: updatedValues,
      replaceAll: true,
    );
  }

  Future<void> _handleFieldEdit(
    CsvReviewRow row,
    CsvFieldReview field, {
    String? overrideValue,
  }) async {
    final String? newValue = overrideValue ?? await _showFieldEditDialog(row, field);
    if (newValue == null) {
      return;
    }
    await _applyRowUpdate(
      row: row,
      updatedValues: <String, String?>{field.columnKey: newValue},
      replaceAll: false,
    );
  }

  Future<void> _applyRowUpdate({
    required CsvReviewRow row,
    required Map<String, String?> updatedValues,
    required bool replaceAll,
  }) async {
    final CsvImportSession? session = _session;
    if (session == null) {
      return;
    }

    setState(() {
      _rowsInProgress.add(row.originalIndex);
    });

    final Map<String, String?> payload = replaceAll
        ? <String, String?>{
            for (final MapEntry<String, String?> entry in updatedValues.entries)
              entry.key: entry.value?.trim(),
          }
        : _buildPayload(row, updatedValues);

    try {
      final CsvReviewRow updatedRow = await widget.service.reparseRow(payload);
      if (!mounted) {
        return;
      }
      setState(() {
        _session = _sessionWithUpdatedRow(updatedRow);
        _rowsInProgress.remove(row.originalIndex);
        _editedRows.add(row.originalIndex);
      });
        await _loadDuplicateMatches(_session!);
    } catch (error, stackTrace) {
      _logger.e(
        'Failed to reparse CSV row ${row.originalIndex}',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _rowsInProgress.remove(row.originalIndex);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Uložení úprav se nezdařilo. Zkuste to prosím znovu.'),
        ),
      );
    }
  }

  Map<String, String?> _buildPayload(
    CsvReviewRow row,
    Map<String, String?> overrides,
  ) {
    final Map<String, String?> payload = <String, String?>{};
    row.fields.forEach((String key, CsvFieldReview field) {
      final bool hasOverride = overrides.containsKey(key);
      final String? value = hasOverride
          ? overrides[key]
          : field.originalValue ?? field.normalizedValue;
      payload[key] = value?.trim();
    });
    return payload;
  }

  CsvImportSession _sessionWithUpdatedRow(CsvReviewRow updatedRow) {
    final CsvImportSession current = _session!;
    bool replaced = false;
    final List<CsvReviewRow> updatedRows = <CsvReviewRow>[];
    for (final CsvReviewRow existing in current.review.rows) {
      if (existing.originalIndex == updatedRow.originalIndex) {
        updatedRows.add(updatedRow);
        replaced = true;
      } else {
        updatedRows.add(existing);
      }
    }
    if (!replaced) {
      _logger.w('Updated row ${updatedRow.originalIndex} not found in current session.');
      return current;
    }

    return CsvImportSession(
      review: CsvImportReview(
        unparsedColumns: current.review.unparsedColumns,
        rows: updatedRows,
      ),
      personResult: current.personResult,
    );
  }

  CsvRowDecision _decisionForRow(int index) {
    return _decisions[index] ?? CsvRowDecision.none;
  }

  void _setRowDecision(int index, CsvRowDecision decision) {
    setState(() {
      if (decision == CsvRowDecision.none) {
        _decisions.remove(index);
      } else {
        _decisions[index] = decision;
      }
    });
  }

  Map<CsvRowDecision, int> _decisionCounts() {
    final Map<CsvRowDecision, int> counts = <CsvRowDecision, int>{
      for (final CsvRowDecision decision in CsvRowDecision.values) decision: 0,
    };
    for (final CsvRowDecision decision in _decisions.values) {
      counts[decision] = (counts[decision] ?? 0) + 1;
    }
    return counts;
  }

  void _applyApprovalPreset(Set<CsvRowReviewStatus> statuses) {
    final CsvImportSession? session = _session;
    if (session == null) {
      return;
    }
    setState(() {
      for (final CsvReviewRow row in session.review.rows) {
        if (statuses.contains(row.status)) {
          if (_hasDuplicate(row.originalIndex)) {
            continue;
          }
          _decisions[row.originalIndex] = CsvRowDecision.approved;
        } else if (_decisions[row.originalIndex] == CsvRowDecision.approved) {
          _decisions.remove(row.originalIndex);
        }
      }
    });
  }

  void _clearApprovals() {
    setState(() {
      _decisions.removeWhere((int _, CsvRowDecision decision) => decision == CsvRowDecision.approved);
    });
  }

  void _applyRejectionPreset({required bool allRows}) {
    final CsvImportSession? session = _session;
    if (session == null) {
      return;
    }
    setState(() {
      for (final CsvReviewRow row in session.review.rows) {
        if (allRows || row.status == CsvRowReviewStatus.rejected) {
          _decisions[row.originalIndex] = CsvRowDecision.rejected;
        } else if (_decisions[row.originalIndex] == CsvRowDecision.rejected) {
          _decisions.remove(row.originalIndex);
        }
      }
    });
  }

  Future<void> _loadDuplicateMatches(CsvImportSession session) async {
    try {
      final Map<int, List<CsvDuplicateCandidate>> duplicates =
          await widget.service.findPotentialDuplicates(session: session);
      if (!mounted) {
        return;
      }
      setState(() {
        _duplicateMatches = duplicates;
      });
    } catch (error, stackTrace) {
      _logger.w(
        'Failed to load duplicate matches',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  bool _hasDuplicate(int index) {
    return (_duplicateMatches[index]?.isNotEmpty ?? false);
  }

  List<CsvDuplicateCandidate> _duplicatesForRow(int index) {
    return _duplicateMatches[index] ?? const <CsvDuplicateCandidate>[];
  }

  Future<void> _handleFinalizePressed() async {
    final CsvImportSession? session = _session;
    if (session == null || _isFinalizing) {
      return;
    }

    final Map<CsvRowDecision, int> counts = _decisionCounts();
    final int approvedCount = counts[CsvRowDecision.approved] ?? 0;
    final int rejectedCount = counts[CsvRowDecision.rejected] ?? 0;
    final int undecidedCount = session.review.rows.length - approvedCount - rejectedCount;

    final bool confirmed = await _showFinalizeConfirmation(
      approvedCount: approvedCount,
      rejectedCount: rejectedCount,
      undecidedCount: undecidedCount,
    );
    if (!confirmed) {
      return;
    }

    setState(() {
      _isFinalizing = true;
    });

    try {
      final CsvFinalizeResult result = await widget.service.finalizeImport(
        session: session,
        decisions: Map<int, CsvRowDecision>.from(_decisions),
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _isFinalizing = false;
      });
      await _showFinalizeSummary(result);
      if (!mounted) {
        return;
      }
      if (result.savedCount > 0) {
        await _loadReview();
      }
    } catch (error, stackTrace) {
      _logger.e(
        'Finalize import failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _isFinalizing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dokončení importu selhalo. Zkuste to prosím znovu.'),
        ),
      );
    }
  }

  Future<bool> _showFinalizeConfirmation({
    required int approvedCount,
    required int rejectedCount,
    required int undecidedCount,
  }) async {
    if (approvedCount == 0) {
      return false;
    }
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          key: const Key('CsvReviewScreen_finalize_confirm_dialog'),
          title: const Text('Potvrdit import'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Schválíte: $approvedCount řádků'),
              Text('Odmítnete: $rejectedCount řádků'),
              Text('Bez rozhodnutí: $undecidedCount řádků'),
              const SizedBox(height: 12),
              const Text('Po potvrzení budou schválené řádky uloženy do evidence.'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              key: const Key('CsvReviewScreen_finalize_cancel_button'),
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Zrušit'),
            ),
            FilledButton(
              key: const Key('CsvReviewScreen_finalize_confirm_button'),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Potvrdit'),
            ),
          ],
        );
      },
    );
    return confirmed ?? false;
  }

  Future<void> _showFinalizeSummary(CsvFinalizeResult result) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          key: const Key('CsvReviewScreen_finalize_summary_dialog'),
          title: Text(
            result.failedCount > 0 ? 'Import dokončen s chybami' : 'Import dokončen',
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Schváleno: ${result.approvedCount}'),
                Text('Odmítnuto: ${result.rejectedCount}'),
                Text('Uloženo: ${result.savedCount}'),
                if (result.failedCount > 0) ...<Widget>[
                  const SizedBox(height: 12),
                  Text('Nepodařilo se uložit: ${result.failedCount}'),
                  const SizedBox(height: 8),
                  for (final CsvFinalizeFailure failure in result.failures)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text('• Řádek ${failure.originalIndex}: ${failure.message}'),
                    ),
                ],
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              key: const Key('CsvReviewScreen_finalize_summary_close'),
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Zavřít'),
            ),
          ],
        );
      },
    );
  }

  Future<Map<String, String?>?> _showRowEditDialog(CsvReviewRow row) async {
    final Map<String, TextEditingController> controllers = <String, TextEditingController>{
      for (final CsvFieldReview field in row.fields.values)
        field.columnKey: TextEditingController(text: field.originalValue ?? ''),
    };

    final Map<String, String?>? result = await showDialog<Map<String, String?>>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          key: Key('CsvReviewScreen_edit_dialog_${row.originalIndex}'),
          title: Text('Upravit řádek ${row.originalIndex}'),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: row.fields.values.map((CsvFieldReview field) {
                  final TextEditingController controller = controllers[field.columnKey]!;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: TextFormField(
                      key: Key('CsvReviewScreen_edit_field_${row.originalIndex}_${field.columnKey}'),
                      controller: controller,
                      decoration: InputDecoration(
                        labelText: field.columnName,
                        helperText: field.inferred ? 'Hodnota byla dopočítána' : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              key: const Key('CsvReviewScreen_edit_dialog_cancel'),
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Zrušit'),
            ),
            ElevatedButton(
              key: const Key('CsvReviewScreen_edit_dialog_save'),
              onPressed: () {
                final Map<String, String?> payload = <String, String?>{
                  for (final MapEntry<String, TextEditingController> entry in controllers.entries)
                    entry.key: entry.value.text,
                };
                Navigator.of(dialogContext).pop(payload);
              },
              child: const Text('Uložit změny'),
            ),
          ],
        );
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final TextEditingController controller in controllers.values) {
        controller.dispose();
      }
    });

    return result;
  }

  Future<String?> _showFieldEditDialog(CsvReviewRow row, CsvFieldReview field) async {
    final TextEditingController controller = TextEditingController(text: field.originalValue ?? '');
    final String? result = await showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          key: Key('CsvReviewScreen_field_edit_dialog_${row.originalIndex}_${field.columnKey}'),
          title: Text('Upravit ${field.columnName}'),
          content: TextFormField(
            key: Key('CsvReviewScreen_field_edit_input_${row.originalIndex}_${field.columnKey}'),
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              labelText: field.columnName,
              helperText: field.inferred ? 'Hodnota byla dopočítána' : null,
            ),
          ),
          actions: <Widget>[
            TextButton(
              key: Key('CsvReviewScreen_field_edit_cancel_${row.originalIndex}_${field.columnKey}'),
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Zrušit'),
            ),
            ElevatedButton(
              key: Key('CsvReviewScreen_field_edit_save_${row.originalIndex}_${field.columnKey}'),
              onPressed: () => Navigator.of(dialogContext).pop(controller.text),
              child: const Text('Uložit'),
            ),
          ],
        );
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.dispose();
    });
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final List<CsvReviewRow> rows = _session?.review.rows ?? const <CsvReviewRow>[];
    final Map<CsvRowReviewStatus, int> counts = _statusCounts(rows);

    return DefaultTabController(
      length: CsvRowReviewStatus.values.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Kontrola importu CSV'),
          bottom: TabBar(
            key: const Key('CsvReviewScreen_tabbar'),
            tabs: _buildTabs(counts),
            isScrollable: true,
          ),
        ),
        body: _buildBody(rows),
      ),
    );
  }

  Widget _buildBody(List<CsvReviewRow> rows) {
    if (_isLoading) {
      return const Center(
        key: Key('CsvReviewScreen_loading'),
        child: CircularProgressIndicator(),
      );
    }
    if (_error != null) {
      return _ErrorPlaceholder(onRetry: _loadReview);
    }

    final CsvImportReview review = _session!.review;
    final Map<CsvRowReviewStatus, List<CsvReviewRow>> groupedRows = _groupRows(review.rows);
    final Map<CsvRowDecision, int> decisionCounts = _decisionCounts();
    final int approvedCount = decisionCounts[CsvRowDecision.approved] ?? 0;
    final int rejectedCount = decisionCounts[CsvRowDecision.rejected] ?? 0;
    final int undecidedCount = review.rows.length - approvedCount - rejectedCount;
  final int duplicateCount = _duplicateMatches.values
    .where((List<CsvDuplicateCandidate> matches) => matches.isNotEmpty)
    .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Flexible(
          fit: FlexFit.loose,
          child: SingleChildScrollView(
            key: const Key('CsvReviewScreen_header_scroll'),
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _SummarySection(review: review, groupedRows: groupedRows),
                _UnparsedColumnsSection(unparsedColumns: review.unparsedColumns),
                _BulkActionBar(
                  approvedCount: decisionCounts[CsvRowDecision.approved] ?? 0,
                  rejectedCount: decisionCounts[CsvRowDecision.rejected] ?? 0,
                  onApproveOk: () => _applyApprovalPreset(<CsvRowReviewStatus>{CsvRowReviewStatus.ok}),
                  onApproveUpToInfo: () => _applyApprovalPreset(
                    <CsvRowReviewStatus>{CsvRowReviewStatus.ok, CsvRowReviewStatus.info},
                  ),
                  onClearApprovals: _clearApprovals,
                  onRejectAll: () => _applyRejectionPreset(allRows: true),
                  onRejectOnlyRejected: () => _applyRejectionPreset(allRows: false),
                ),
                _buildFinalizeSection(
                  approvedCount: approvedCount,
                  rejectedCount: rejectedCount,
                  undecidedCount: undecidedCount,
                  duplicateCount: duplicateCount,
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: TabBarView(
            key: const Key('CsvReviewScreen_tabbar_view'),
            children: <Widget>[
              _buildTabContent(groupedRows[CsvRowReviewStatus.rejected]!, CsvRowReviewStatus.rejected),
              _buildTabContent(groupedRows[CsvRowReviewStatus.warn]!, CsvRowReviewStatus.warn),
              _buildTabContent(groupedRows[CsvRowReviewStatus.info]!, CsvRowReviewStatus.info),
              _buildTabContent(groupedRows[CsvRowReviewStatus.ok]!, CsvRowReviewStatus.ok),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFinalizeSection({
    required int approvedCount,
    required int rejectedCount,
    required int undecidedCount,
    required int duplicateCount,
  }) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    final bool isButtonEnabled = !_isFinalizing && approvedCount > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        key: const Key('CsvReviewScreen_finalize_card'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Dokončení importu', style: textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(
                'Zkontrolujte počty řádků a potvrďte uložení schválených záznamů do evidence.',
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: <Widget>[
                  Chip(
                    key: const Key('CsvReviewScreen_finalize_approved_count'),
                    avatar: const Icon(Icons.check, size: 16),
                    label: Text('Ke schválení: $approvedCount'),
                  ),
                  Chip(
                    key: const Key('CsvReviewScreen_finalize_rejected_count'),
                    avatar: const Icon(Icons.close, size: 16),
                    label: Text('Odmítnuto: $rejectedCount'),
                  ),
                  Chip(
                    key: const Key('CsvReviewScreen_finalize_undecided_count'),
                    avatar: const Icon(Icons.help_outline, size: 16),
                    label: Text('Bez rozhodnutí: $undecidedCount'),
                  ),
                  if (duplicateCount > 0)
                    Chip(
                      key: const Key('CsvReviewScreen_finalize_duplicates_count'),
                      avatar: const Icon(Icons.warning_amber_rounded, size: 16),
                      label: Text('Možné duplicity: $duplicateCount'),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                key: const Key('CsvReviewScreen_finalize_button'),
                onPressed: isButtonEnabled ? _handleFinalizePressed : null,
                icon: const Icon(Icons.done_all),
                label: const Text('Dokončit import'),
              ),
              if (approvedCount == 0)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Nejprve vyberte řádky ke schválení.',
                    key: const Key('CsvReviewScreen_finalize_disabled_hint'),
                    style: textTheme.bodySmall,
                  ),
                ),
              if (_isFinalizing) ...<Widget>[
                const SizedBox(height: 12),
                const LinearProgressIndicator(
                  key: Key('CsvReviewScreen_finalize_progress'),
                  minHeight: 3,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<Tab> _buildTabs(Map<CsvRowReviewStatus, int> counts) {
    return <Tab>[
      Tab(
        key: const Key('CsvReviewScreen_tab_rejected'),
        text: 'Zamítnuto (${counts[CsvRowReviewStatus.rejected] ?? 0})',
      ),
      Tab(
        key: const Key('CsvReviewScreen_tab_warn'),
        text: 'Varování (${counts[CsvRowReviewStatus.warn] ?? 0})',
      ),
      Tab(
        key: const Key('CsvReviewScreen_tab_info'),
        text: 'Informace (${counts[CsvRowReviewStatus.info] ?? 0})',
      ),
      Tab(
        key: const Key('CsvReviewScreen_tab_ok'),
        text: 'Platné (${counts[CsvRowReviewStatus.ok] ?? 0})',
      ),
    ];
  }

  Widget _buildTabContent(List<CsvReviewRow> rows, CsvRowReviewStatus status) {
    if (rows.isEmpty) {
      return Center(
        key: Key('CsvReviewScreen_tab_${status.name}_empty'),
        child: const Text('Žádné záznamy'),
      );
    }

    return ListView.separated(
      key: Key('CsvReviewScreen_list_${status.name}'),
      padding: const EdgeInsets.all(16),
      itemBuilder: (BuildContext context, int index) {
        final CsvReviewRow row = rows[index];
        final CsvRowDecision decision = _decisionForRow(row.originalIndex);
        return CsvReviewRowCard(
          row: row,
          onRowEdit: () => _handleRowEdit(row),
          onFieldEdit: (
            CsvFieldReview field, {
            String? overrideValue,
          }) => _handleFieldEdit(
            row,
            field,
            overrideValue: overrideValue,
          ),
          isEdited: _editedRows.contains(row.originalIndex),
          isLoading: _rowsInProgress.contains(row.originalIndex),
          decision: decision,
          duplicateMatches: _duplicatesForRow(row.originalIndex),
          onDecisionChanged: (CsvRowDecision newDecision) => _setRowDecision(
            row.originalIndex,
            newDecision,
          ),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: rows.length,
    );
  }

  Map<CsvRowReviewStatus, int> _statusCounts(List<CsvReviewRow> rows) {
    final Map<CsvRowReviewStatus, int> counts = <CsvRowReviewStatus, int>{
      for (final CsvRowReviewStatus status in CsvRowReviewStatus.values) status: 0,
    };
    for (final CsvReviewRow row in rows) {
      counts[row.status] = (counts[row.status] ?? 0) + 1;
    }
    return counts;
  }

  Map<CsvRowReviewStatus, List<CsvReviewRow>> _groupRows(List<CsvReviewRow> rows) {
    final Map<CsvRowReviewStatus, List<CsvReviewRow>> grouped = <CsvRowReviewStatus, List<CsvReviewRow>>{
      for (final CsvRowReviewStatus status in CsvRowReviewStatus.values) status: <CsvReviewRow>[],
    };
    for (final CsvReviewRow row in rows) {
      grouped[row.status]!.add(row);
    }
    for (final List<CsvReviewRow> statusRows in grouped.values) {
      statusRows.sort((CsvReviewRow a, CsvReviewRow b) => a.originalIndex.compareTo(b.originalIndex));
    }
    return grouped;
  }
}

class _SummarySection extends StatelessWidget {
  const _SummarySection({
    required this.review,
    required this.groupedRows,
  });

  final CsvImportReview review;
  final Map<CsvRowReviewStatus, List<CsvReviewRow>> groupedRows;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Shrnutí', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: <Widget>[
                  _SummaryBadge(
                    key: const Key('CsvReviewScreen_summary_rejected_count'),
                    label: 'Zamítnuto',
                    count: groupedRows[CsvRowReviewStatus.rejected]!.length,
                    color: _statusColor(context, CsvRowReviewStatus.rejected),
                  ),
                  _SummaryBadge(
                    key: const Key('CsvReviewScreen_summary_warn_count'),
                    label: 'Varování',
                    count: groupedRows[CsvRowReviewStatus.warn]!.length,
                    color: _statusColor(context, CsvRowReviewStatus.warn),
                  ),
                  _SummaryBadge(
                    key: const Key('CsvReviewScreen_summary_info_count'),
                    label: 'Informace',
                    count: groupedRows[CsvRowReviewStatus.info]!.length,
                    color: _statusColor(context, CsvRowReviewStatus.info),
                  ),
                  _SummaryBadge(
                    key: const Key('CsvReviewScreen_summary_ok_count'),
                    label: 'Platné',
                    count: groupedRows[CsvRowReviewStatus.ok]!.length,
                    color: _statusColor(context, CsvRowReviewStatus.ok),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Celkem řádků: ${review.rows.length}',
                key: const Key('CsvReviewScreen_summary_total'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryBadge extends StatelessWidget {
  const _SummaryBadge({
    super.key,
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: textTheme.labelMedium?.copyWith(color: color)),
          const SizedBox(height: 4),
          Text('$count', style: textTheme.titleLarge?.copyWith(color: color)),
        ],
      ),
    );
  }
}

class _UnparsedColumnsSection extends StatelessWidget {
  const _UnparsedColumnsSection({
    required this.unparsedColumns,
  });

  final List<String> unparsedColumns;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: ExpansionTile(
          key: const Key('CsvReviewScreen_unparsed_columns_tile'),
          title: const Text('Nerozpoznané sloupce'),
          children: unparsedColumns.isEmpty
              ? const <Widget>[
                  ListTile(
                    key: Key('CsvReviewScreen_unparsed_columns_empty'),
                    title: Text('Žádné nerozpoznané sloupce'),
                  ),
                ]
              : <Widget>[
                  for (int i = 0; i < unparsedColumns.length; i++)
                    ListTile(
                      key: Key('CsvReviewScreen_unparsed_column_$i'),
                      leading: const Icon(Icons.info_outline),
                      title: Text(unparsedColumns[i]),
                    ),
                ],
        ),
      ),
    );
  }
}

class _BulkActionBar extends StatelessWidget {
  const _BulkActionBar({
    required this.approvedCount,
    required this.rejectedCount,
    required this.onApproveOk,
    required this.onApproveUpToInfo,
    required this.onClearApprovals,
    required this.onRejectAll,
    required this.onRejectOnlyRejected,
  });

  final int approvedCount;
  final int rejectedCount;
  final VoidCallback onApproveOk;
  final VoidCallback onApproveUpToInfo;
  final VoidCallback onClearApprovals;
  final VoidCallback onRejectAll;
  final VoidCallback onRejectOnlyRejected;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Hromadné akce', style: textTheme.titleMedium),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  FilledButton.icon(
                    key: const Key('CsvReviewScreen_bulk_approve_ok'),
                    onPressed: onApproveOk,
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Schválit platné'),
                  ),
                  FilledButton.icon(
                    key: const Key('CsvReviewScreen_bulk_approve_info'),
                    onPressed: onApproveUpToInfo,
                    icon: const Icon(Icons.info_outline),
                    label: const Text('Schválit platné + info'),
                  ),
                  OutlinedButton.icon(
                    key: const Key('CsvReviewScreen_bulk_clear_approvals'),
                    onPressed: onClearApprovals,
                    icon: const Icon(Icons.undo),
                    label: const Text('Zrušit schválení'),
                  ),
                  OutlinedButton.icon(
                    key: const Key('CsvReviewScreen_bulk_reject_only_rejected'),
                    onPressed: onRejectOnlyRejected,
                    icon: const Icon(Icons.block),
                    label: const Text('Odmítnout zamítnuté'),
                  ),
                  FilledButton.icon(
                    key: const Key('CsvReviewScreen_bulk_reject_all'),
                    onPressed: onRejectAll,
                    icon: const Icon(Icons.cancel),
                    label: const Text('Odmítnout vše'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: <Widget>[
                  Chip(
                    key: const Key('CsvReviewScreen_bulk_approved_count'),
                    avatar: const Icon(Icons.check, size: 16),
                    label: Text('Schváleno: $approvedCount'),
                  ),
                  Chip(
                    key: const Key('CsvReviewScreen_bulk_rejected_count'),
                    avatar: const Icon(Icons.close, size: 16),
                    label: Text('Odmítnuto: $rejectedCount'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CsvReviewRowCard extends StatefulWidget {
  const CsvReviewRowCard({
    super.key,
    required this.row,
    required this.onRowEdit,
    required this.onFieldEdit,
    required this.isEdited,
    required this.isLoading,
    required this.decision,
    required this.duplicateMatches,
    required this.onDecisionChanged,
  });

  final CsvReviewRow row;
  final VoidCallback onRowEdit;
  final Future<void> Function(CsvFieldReview field, {String? overrideValue}) onFieldEdit;
  final bool isEdited;
  final bool isLoading;
  final CsvRowDecision decision;
  final List<CsvDuplicateCandidate> duplicateMatches;
  final ValueChanged<CsvRowDecision> onDecisionChanged;

  @override
  State<CsvReviewRowCard> createState() => _CsvReviewRowCardState();
}

class _CsvReviewRowCardState extends State<CsvReviewRowCard> {
  final Map<String, TextEditingController> _inlineControllers = <String, TextEditingController>{};
  final Set<String> _editingFields = <String>{};

  @override
  void dispose() {
    for (final TextEditingController controller in _inlineControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _startInlineEdit(CsvFieldReview field) {
    if (_editingFields.contains(field.columnKey)) {
      return;
    }
    final TextEditingController controller = TextEditingController(
      text: field.originalValue ?? field.normalizedValue ?? '',
    );
    setState(() {
      _editingFields.add(field.columnKey);
      _inlineControllers[field.columnKey] = controller;
    });
  }

  Future<void> _submitInlineEdit(CsvFieldReview field) async {
    final TextEditingController? controller = _inlineControllers[field.columnKey];
    if (controller == null) {
      return;
    }
    final String newValue = controller.text;
    await widget.onFieldEdit(field, overrideValue: newValue);
    if (!mounted) {
      return;
    }
    setState(() {
      _editingFields.remove(field.columnKey);
      _inlineControllers.remove(field.columnKey)?.dispose();
    });
  }

  void _cancelInlineEdit(String columnKey) {
    setState(() {
      _editingFields.remove(columnKey);
      _inlineControllers.remove(columnKey)?.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    final Color statusColor = _statusColor(context, widget.row.status);
    final String statusLabel = _statusLabel(widget.row.status);
    final Iterable<String> messageTexts =
        widget.row.messages.map((CsvReviewMessage m) => m.message);
    final List<CsvFieldReview> fields = widget.row.fields.values.toList();
    final List<String> fieldPreviews = fields
        .take(3)
        .map((CsvFieldReview field) => '${field.columnName}: ${field.originalValue ?? ''}')
        .toList();
    final bool hasDuplicates = widget.duplicateMatches.isNotEmpty;

    return Card(
      key: Key('CsvReviewScreen_row_${widget.row.originalIndex}'),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Text('Řádek ${widget.row.originalIndex}', style: textTheme.titleMedium),
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: <Widget>[
                        Chip(
                          key: Key('CsvReviewScreen_row_${widget.row.originalIndex}_status'),
                          label: Text(statusLabel),
                          backgroundColor: statusColor.withValues(alpha: 0.15),
                          labelStyle: textTheme.labelMedium?.copyWith(color: statusColor),
                        ),
                        if (widget.decision != CsvRowDecision.none)
                          Tooltip(
                            message: widget.decision == CsvRowDecision.approved
                                ? 'Řádek bude schválen'
                                : 'Řádek bude odmítnut',
                            child: Chip(
                              key: Key('CsvReviewScreen_row_${widget.row.originalIndex}_decision_chip'),
                              avatar: Icon(
                                widget.decision == CsvRowDecision.approved ? Icons.check : Icons.close,
                                size: 16,
                              ),
                              label: Text(_decisionLabel(widget.decision)),
                              backgroundColor:
                                  _decisionColor(context, widget.decision).withValues(alpha: 0.15),
                              labelStyle: textTheme.labelMedium?.copyWith(
                                color: _decisionColor(context, widget.decision),
                              ),
                            ),
                          ),
                        if (hasDuplicates)
                          Tooltip(
                            message: 'Řádek může odpovídat již existujícímu účastníkovi',
                            child: Chip(
                              key:
                                  Key('CsvReviewScreen_row_${widget.row.originalIndex}_duplicate_badge'),
                              avatar: const Icon(Icons.warning_amber_rounded, size: 16),
                              label: const Text('Možná duplicita'),
                              backgroundColor: theme.colorScheme.errorContainer,
                              labelStyle: textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.onErrorContainer,
                              ),
                            ),
                          ),
                        if (widget.isEdited)
                          Tooltip(
                            message: 'Řádek byl upraven v rámci aktuální relace',
                            child: Chip(
                              key: Key(
                                  'CsvReviewScreen_row_${widget.row.originalIndex}_edited_badge'),
                              avatar: const Icon(Icons.edit_outlined, size: 16),
                              label: const Text('Upraveno'),
                              backgroundColor: theme.colorScheme.secondaryContainer,
                              labelStyle: textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.onSecondaryContainer,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                if (widget.isLoading) ...<Widget>[
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    key: Key('CsvReviewScreen_row_${widget.row.originalIndex}_loading_indicator'),
                    minHeight: 3,
                  ),
                ],
                if (fieldPreviews.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      for (int i = 0; i < fieldPreviews.length; i++)
                        Chip(
                          key: Key('CsvReviewScreen_row_${widget.row.originalIndex}_field_$i'),
                          label: Text(fieldPreviews[i]),
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                Text(
                  messageTexts.isNotEmpty ? messageTexts.join('\n') : 'Bez zprávy',
                  key: Key('CsvReviewScreen_row_${widget.row.originalIndex}_messages'),
                ),
                if (hasDuplicates) ...<Widget>[
                  const SizedBox(height: 12),
                  _DuplicateWarningPanel(
                    key: Key('CsvReviewScreen_row_${widget.row.originalIndex}_duplicate_panel'),
                    rowIndex: widget.row.originalIndex,
                    matches: widget.duplicateMatches,
                  ),
                ],
                if (widget.row.derived.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.row.derived.entries
                        .map(
                          (MapEntry<String, CsvDerivedValue> entry) => Chip(
                            key: Key(
                                'CsvReviewScreen_row_${widget.row.originalIndex}_derived_${entry.key}'),
                            avatar: Icon(
                              entry.value.applied ? Icons.check_circle : Icons.lightbulb_outline,
                              size: 18,
                              color: entry.value.applied
                                  ? theme.colorScheme.secondary
                                  : theme.colorScheme.primary,
                            ),
                            label: Text('${entry.value.key}: ${entry.value.value}'),
                          ),
                        )
                        .toList(),
                  ),
                ],
                const SizedBox(height: 12),
                SegmentedButton<CsvRowDecision>(
                  key: Key('CsvReviewScreen_row_${widget.row.originalIndex}_decision_segmented'),
                  segments: const <ButtonSegment<CsvRowDecision>>[
                    ButtonSegment<CsvRowDecision>(
                      value: CsvRowDecision.none,
                      label: Text('Bez rozhodnutí'),
                      icon: Icon(Icons.remove_circle_outline),
                    ),
                    ButtonSegment<CsvRowDecision>(
                      value: CsvRowDecision.approved,
                      label: Text('Schválit'),
                      icon: Icon(Icons.check_circle_outline),
                    ),
                    ButtonSegment<CsvRowDecision>(
                      value: CsvRowDecision.rejected,
                      label: Text('Odmítnout'),
                      icon: Icon(Icons.cancel_outlined),
                    ),
                  ],
                  selected: <CsvRowDecision>{widget.decision},
                  onSelectionChanged: widget.isLoading
                      ? null
                      : (Set<CsvRowDecision> selection) {
                          if (selection.isEmpty) {
                            return;
                          }
                          widget.onDecisionChanged(selection.first);
                        },
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    key: Key('CsvReviewScreen_row_${widget.row.originalIndex}_edit_button'),
                    onPressed: widget.isLoading ? null : widget.onRowEdit,
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Upravit řádek'),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ExpansionTile(
            key: Key('CsvReviewScreen_row_${widget.row.originalIndex}_fields_tile'),
            tilePadding: const EdgeInsets.symmetric(horizontal: 16),
            title: const Text('Detaily polí'),
            childrenPadding: const EdgeInsets.only(bottom: 16),
            maintainState: true,
            children: <Widget>[
              for (final CsvFieldReview field in fields)
                _FieldDetailTile(
                  key: Key(
                    'CsvReviewScreen_row_${widget.row.originalIndex}_field_tile_${field.columnKey}',
                  ),
                  field: field,
                  isLoading: widget.isLoading,
                  isEditing: _editingFields.contains(field.columnKey),
                  controller: _inlineControllers[field.columnKey],
                  onStartInlineEdit: () => _startInlineEdit(field),
                  onCancelInlineEdit: () => _cancelInlineEdit(field.columnKey),
                  onSubmitInlineEdit: () => _submitInlineEdit(field),
                  onOpenDialog: () => widget.onFieldEdit(field),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DuplicateWarningPanel extends StatelessWidget {
  const _DuplicateWarningPanel({
    super.key,
    required this.rowIndex,
    required this.matches,
  });

  final int rowIndex;
  final List<CsvDuplicateCandidate> matches;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.errorContainer),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Možní duplicitní účastníci v databázi:',
            style: textTheme.titleSmall?.copyWith(color: theme.colorScheme.onErrorContainer),
          ),
          const SizedBox(height: 8),
          for (int i = 0; i < matches.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                '• ${matches[i].displayName} – ${matches[i].reason}',
                key: Key('CsvReviewScreen_row_${rowIndex}_duplicate_$i'),
                style: textTheme.bodyMedium,
              ),
            ),
          Text(
            'Zkontrolujte, zda se nejedná o již registrovaného účastníka.',
            style: textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _FieldDetailTile extends StatelessWidget {
  const _FieldDetailTile({
    super.key,
    required this.field,
    required this.isLoading,
    required this.isEditing,
    required this.controller,
    required this.onStartInlineEdit,
    required this.onCancelInlineEdit,
    required this.onSubmitInlineEdit,
    required this.onOpenDialog,
  });

  final CsvFieldReview field;
  final bool isLoading;
  final bool isEditing;
  final TextEditingController? controller;
  final VoidCallback onStartInlineEdit;
  final VoidCallback onCancelInlineEdit;
  final Future<void> Function() onSubmitInlineEdit;
  final Future<void> Function() onOpenDialog;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            _fieldStatusIcon(field.status),
            color: _fieldStatusColor(context, field.status),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(field.columnName, style: textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(
                  _fieldSummaryText(field),
                  style: textTheme.bodySmall,
                ),
                if (field.messages.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: field.messages
                        .map(
                          (CsvReviewMessage message) => Text(
                            '• ${message.message}',
                            style: textTheme.bodySmall,
                          ),
                        )
                        .toList(),
                  ),
                ],
                if (isEditing && controller != null) ...<Widget>[
                  const SizedBox(height: 12),
                  TextField(
                    key: Key('CsvReviewScreen_inline_field_${field.columnKey}_input'),
                    controller: controller,
                    minLines: 1,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Nová hodnota',
                      helperText: 'Úprava přímo v tabulce',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: <Widget>[
                      FilledButton(
                        key: Key('CsvReviewScreen_inline_field_${field.columnKey}_save'),
                        onPressed: isLoading ? null : onSubmitInlineEdit,
                        child: const Text('Uložit'),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        key: Key('CsvReviewScreen_inline_field_${field.columnKey}_cancel'),
                        onPressed: onCancelInlineEdit,
                        child: const Text('Zrušit'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              if (!isEditing)
                IconButton(
                  key: Key('CsvReviewScreen_inline_field_${field.columnKey}_edit_button'),
                  tooltip: 'Upravit přímo v řádku',
                  icon: const Icon(Icons.edit_note_outlined),
                  onPressed: isLoading ? null : onStartInlineEdit,
                ),
              IconButton(
                key: Key('CsvReviewScreen_dialog_field_${field.columnKey}_edit_button'),
                tooltip: 'Otevřít dialog pro úpravu',
                icon: const Icon(Icons.open_in_new),
                onPressed: isLoading ? null : onOpenDialog,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ErrorPlaceholder extends StatelessWidget {
  const _ErrorPlaceholder({
    required this.onRetry,
  });

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      key: const Key('CsvReviewScreen_error'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Text(
            'Nepodařilo se načíst data',
            key: Key('CsvReviewScreen_error_text'),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            key: const Key('CsvReviewScreen_retry_button'),
            onPressed: onRetry,
            child: const Text('Zkusit znovu'),
          ),
        ],
      ),
    );
  }
}

Color _statusColor(BuildContext context, CsvRowReviewStatus status) {
  final ColorScheme colors = Theme.of(context).colorScheme;
  switch (status) {
    case CsvRowReviewStatus.rejected:
      return colors.error;
    case CsvRowReviewStatus.warn:
      return colors.tertiary;
    case CsvRowReviewStatus.info:
      return colors.primary;
    case CsvRowReviewStatus.ok:
      return colors.secondary;
  }
}

String _statusLabel(CsvRowReviewStatus status) {
  switch (status) {
    case CsvRowReviewStatus.rejected:
      return 'Zamítnuto';
    case CsvRowReviewStatus.warn:
      return 'Varování';
    case CsvRowReviewStatus.info:
      return 'Informace';
    case CsvRowReviewStatus.ok:
      return 'Platné';
  }
}

Color _fieldStatusColor(BuildContext context, CsvFieldReviewStatus status) {
  final ColorScheme colors = Theme.of(context).colorScheme;
  switch (status) {
    case CsvFieldReviewStatus.ok:
      return colors.secondary;
    case CsvFieldReviewStatus.warn:
      return colors.tertiary;
    case CsvFieldReviewStatus.bad:
      return colors.error;
    case CsvFieldReviewStatus.empty:
      return colors.outline;
  }
}

String _fieldStatusLabel(CsvFieldReviewStatus status) {
  switch (status) {
    case CsvFieldReviewStatus.ok:
      return 'V pořádku';
    case CsvFieldReviewStatus.warn:
      return 'Varování';
    case CsvFieldReviewStatus.bad:
      return 'Chyba';
    case CsvFieldReviewStatus.empty:
      return 'Prázdné';
  }
}

IconData _fieldStatusIcon(CsvFieldReviewStatus status) {
  switch (status) {
    case CsvFieldReviewStatus.ok:
      return Icons.check_circle_outline;
    case CsvFieldReviewStatus.warn:
      return Icons.warning_amber_rounded;
    case CsvFieldReviewStatus.bad:
      return Icons.error_outline;
    case CsvFieldReviewStatus.empty:
      return Icons.radio_button_unchecked;
  }
}

String _fieldSummaryText(CsvFieldReview field) {
  final String value = (field.originalValue == null || field.originalValue!.trim().isEmpty)
      ? 'Bez hodnoty'
      : field.originalValue!.trim();
  final String statusLabel = _fieldStatusLabel(field.status);
  if (field.inferred) {
    return '$value • $statusLabel • dopočteno';
  }
  return '$value • $statusLabel';
}

String _decisionLabel(CsvRowDecision decision) {
  switch (decision) {
    case CsvRowDecision.none:
      return 'Bez rozhodnutí';
    case CsvRowDecision.approved:
      return 'Schválit';
    case CsvRowDecision.rejected:
      return 'Odmítnout';
  }
}

Color _decisionColor(BuildContext context, CsvRowDecision decision) {
  final ColorScheme colors = Theme.of(context).colorScheme;
  switch (decision) {
    case CsvRowDecision.none:
      return colors.outline;
    case CsvRowDecision.approved:
      return colors.secondary;
    case CsvRowDecision.rejected:
      return colors.error;
  }
}
