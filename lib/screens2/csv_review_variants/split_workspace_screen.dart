import 'package:denik_zza/input/csv_review_models.dart';
import 'package:denik_zza/screens2/csv_review/widgets/finalize_card.dart';
import 'package:denik_zza/services/csv_import_service.dart';
import 'package:flutter/material.dart';

import 'csv_review_shared.dart';

/// Split workspace prototype offering list/detail workflow for power users.
class CsvReviewSplitWorkspaceScreen extends StatelessWidget {
  const CsvReviewSplitWorkspaceScreen({
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
        return _SplitWorkspaceScaffold(controller: controller);
      },
    );
  }
}

class _SplitWorkspaceScaffold extends StatefulWidget {
  const _SplitWorkspaceScaffold({
    required this.controller,
  });

  final CsvReviewPrototypeController controller;

  @override
  State<_SplitWorkspaceScaffold> createState() => _SplitWorkspaceScaffoldState();
}

class _SplitWorkspaceScaffoldState extends State<_SplitWorkspaceScaffold>
    with SingleTickerProviderStateMixin {
  CsvRowReviewStatus? _filter;
  int? _selectedRowIndex;
  late TabController _tabController;
  final Map<String, TextEditingController> _fieldControllers =
      <String, TextEditingController>{};

  CsvReviewPrototypeController get _controller => widget.controller;

  static const List<String> _basicKeys = <String>[
    'jmeno',
    'prijmeni',
    'datum_narozeni',
    'pohlavi',
    'cislo_pojisteni',
  ];

  static const List<String> _contactKeys = <String>[
    'email_rodice',
    'telefon_rodice',
    'adresa',
    'jmeno_rodice',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    if (_controller.rows.isNotEmpty) {
      _selectRow(_controller.rows.first.originalIndex);
    }
  }

  @override
  void didUpdateWidget(covariant _SplitWorkspaceScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_controller.rows.isEmpty) {
      _selectedRowIndex = null;
      _clearControllers();
    } else if (_selectedRowIndex == null) {
      _selectRow(_controller.rows.first.originalIndex);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _clearControllers();
    super.dispose();
  }

  void _clearControllers() {
    for (final TextEditingController controller in _fieldControllers.values) {
      controller.dispose();
    }
    _fieldControllers.clear();
  }

  void _selectRow(int rowIndex) {
    setState(() {
      _selectedRowIndex = rowIndex;
      _initControllers();
    });
  }

  void _initControllers() {
    _clearControllers();
    final CsvReviewRow? row = _currentRow;
    if (row == null) {
      return;
    }
    for (final MapEntry<String, CsvFieldReview> entry in row.fields.entries) {
      _fieldControllers[entry.key] = TextEditingController(
        text: entry.value.normalizedValue ?? entry.value.originalValue ?? '',
      );
    }
  }

  CsvReviewRow? get _currentRow {
    if (_selectedRowIndex == null) {
      return null;
    }
    if (_controller.rows.isEmpty) {
      return null;
    }
    return _controller.rows.firstWhere(
      (CsvReviewRow row) => row.originalIndex == _selectedRowIndex,
      orElse: () => _controller.rows.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dvou-panelový přehled CSV'),
        actions: <Widget>[
          IconButton(
            key: const Key('CsvSplitWorkspace_refresh'),
            icon: const Icon(Icons.refresh),
            tooltip: 'Znovu načíst soubor',
            onPressed: _controller.reload,
          ),
        ],
      ),
      body: _controller.session == null
          ? const SizedBox.shrink()
          : Row(
              children: <Widget>[
                SizedBox(
                  width: 320,
                  child: Column(
                    children: <Widget>[
                      _buildFilterChips(theme),
                      const Divider(height: 1),
                      Expanded(
                        child: _buildRowList(theme),
                      ),
                    ],
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: _buildDetailPane(theme),
                ),
              ],
            ),
      bottomNavigationBar: _controller.session == null
          ? null
          : Material(
              elevation: 6,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: FinalizeCard(
                    key: const Key('CsvSplitWorkspace_finalize'),
                    approvedCount: _controller.approvedCount,
                    rejectedCount: _controller.rejectedCount,
                    undecidedCount: _controller.undecidedCount,
                    duplicateCount: _controller.duplicateRowCount,
                    isFinalizing: _controller.isFinalizing,
                    onFinalize: () async {
                      await _controller.finalizeImport();
                    },
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildFilterChips(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Wrap(
        spacing: 8,
        children: <Widget>[
          _buildFilterChip('Vše', null, theme),
          _buildFilterChip('Chyby', CsvRowReviewStatus.rejected, theme),
          _buildFilterChip('Varování', CsvRowReviewStatus.warn, theme),
          _buildFilterChip('Informace', CsvRowReviewStatus.info, theme),
          _buildFilterChip('V pořádku', CsvRowReviewStatus.ok, theme),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, CsvRowReviewStatus? status, ThemeData theme) {
    final bool selected = _filter == status;
    final int count = status == null
        ? _controller.totalRowCount
        : _controller.groupedRows[status]?.length ?? 0;
    return FilterChip(
      key: Key('CsvSplitWorkspace_filter_${status?.name ?? 'all'}'),
      label: Text('$label ($count)'),
      selected: selected,
      onSelected: (bool value) {
        setState(() {
          _filter = value ? status : null;
        });
      },
      selectedColor: theme.colorScheme.primaryContainer,
    );
  }

  Widget _buildRowList(ThemeData theme) {
    final Iterable<CsvReviewRow> rows = _filter == null
        ? _controller.rows
        : _controller.rows.where((CsvReviewRow row) => row.status == _filter);
    if (rows.isEmpty) {
      return const Center(child: Text('Žádné řádky pro daný filtr.'));
    }
    return ListView(
      key: const Key('CsvSplitWorkspace_rowList'),
      children: rows
          .map(
            (CsvReviewRow row) => ListTile(
              key: ValueKey<int>(row.originalIndex),
              selected: row.originalIndex == _selectedRowIndex,
              title: Text(_listTileTitle(row)),
              subtitle: Text(statusLabel(row.status)),
              leading: Icon(
                _iconForStatus(row.status),
                color: statusColor(theme, row.status),
              ),
              trailing: _controller.hasDuplicate(row.originalIndex)
                  ? const Icon(Icons.warning_amber_outlined, color: Colors.orange)
                  : null,
              onTap: () => _selectRow(row.originalIndex),
            ),
          )
          .toList(),
    );
  }

  String _listTileTitle(CsvReviewRow row) {
    final String name =
        '${row.fields['jmeno']?.normalizedValue ?? row.fields['jmeno']?.originalValue ?? ''} ${row.fields['prijmeni']?.normalizedValue ?? row.fields['prijmeni']?.originalValue ?? ''}'.trim();
    return name.isEmpty ? 'Řádek ${row.originalIndex}' : name;
  }

  IconData _iconForStatus(CsvRowReviewStatus status) {
    switch (status) {
      case CsvRowReviewStatus.ok:
        return Icons.check_circle_outline;
      case CsvRowReviewStatus.info:
        return Icons.info_outline;
      case CsvRowReviewStatus.warn:
        return Icons.warning_amber_outlined;
      case CsvRowReviewStatus.rejected:
        return Icons.error_outline;
    }
  }

  Widget _buildDetailPane(ThemeData theme) {
    final CsvReviewRow? row = _currentRow;
    if (row == null) {
      return const Center(
        child: Text('Vyberte řádek vlevo pro zobrazení detailů.'),
      );
    }
    final CsvRowDecision decision = _controller.decisionForRow(row.originalIndex);
    final bool loading = _controller.isRowLoading(row.originalIndex);
    final List<DerivedValueDisplay> derivedValues = derivedValueDisplays(row);

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      _listTileTitle(row),
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: <Widget>[
                        Chip(
                          label: Text(statusLabel(row.status)),
                          backgroundColor:
                              statusColor(theme, row.status).withOpacity(0.15),
                        ),
                        Chip(
                          label: Text('Zprávy: ${row.messages.length}'),
                        ),
                        if (_controller.hasDuplicate(row.originalIndex))
                          Chip(
                            avatar: const Icon(Icons.warning_amber, size: 16),
                            label: const Text('Možná duplicita'),
                            backgroundColor:
                                theme.colorScheme.errorContainer,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              SegmentedButton<CsvRowDecision>(
                segments: const <ButtonSegment<CsvRowDecision>>[
                  ButtonSegment<CsvRowDecision>(
                    value: CsvRowDecision.approved,
                    icon: Icon(Icons.check),
                    label: Text('Přijmout'),
                  ),
                  ButtonSegment<CsvRowDecision>(
                    value: CsvRowDecision.rejected,
                    icon: Icon(Icons.close),
                    label: Text('Zamítnout'),
                  ),
                  ButtonSegment<CsvRowDecision>(
                    value: CsvRowDecision.none,
                    icon: Icon(Icons.hourglass_bottom),
                    label: Text('Rozhodnout později'),
                  ),
                ],
                selected: <CsvRowDecision>{decision},
                onSelectionChanged: (Set<CsvRowDecision> value) {
                  _controller.updateDecision(row.originalIndex, value.single);
                },
              ),
            ],
          ),
        ),
        TabBar(
          controller: _tabController,
          tabs: const <Tab>[
            Tab(text: 'Základní údaje'),
            Tab(text: 'Kontakty'),
            Tab(text: 'Odvozené hodnoty'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: <Widget>[
              _buildFieldList(row, _basicKeys, 'CsvSplitWorkspace_basic'),
              _buildFieldList(row, _contactKeys, 'CsvSplitWorkspace_contacts'),
              _buildDerivedTab(derivedValues, row),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Row(
            children: <Widget>[
              ElevatedButton.icon(
                key: const Key('CsvSplitWorkspace_save'),
                onPressed: loading
                    ? null
                    : () async {
                        await _submitEdits(row);
                      },
                icon: const Icon(Icons.save),
                label: Text(loading ? 'Ukládám...' : 'Uložit změny'),
              ),
              const SizedBox(width: 12),
              TextButton.icon(
                key: const Key('CsvSplitWorkspace_reset'),
                onPressed: loading ? null : _initControllers,
                icon: const Icon(Icons.refresh),
                label: const Text('Obnovit hodnoty'),
              ),
              const Spacer(),
              Chip(
                label: Text(
                    'Rozhodnutí: ${_controller.approvedCount} ✓ / ${_controller.rejectedCount} ✗ / ${_controller.undecidedCount} čeká'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFieldList(
    CsvReviewRow row,
    List<String> orderedKeys,
    String keyPrefix,
  ) {
    final List<Widget> fields = <Widget>[];
    final Set<String> displayedKeys = <String>{};

    for (final String key in orderedKeys) {
      if (!row.fields.containsKey(key)) {
        continue;
      }
      displayedKeys.add(key);
      fields.add(_buildFieldTile(row, key, keyPrefix));
    }

    // Append any remaining fields not covered by the ordered list.
    for (final String key in row.fields.keys) {
      if (displayedKeys.contains(key)) {
        continue;
      }
      fields.add(_buildFieldTile(row, key, keyPrefix));
    }

    if (fields.isEmpty) {
      return const Center(child: Text('Pro tuto záložku nejsou k dispozici údaje.'));
    }

    return ListView(
      key: ValueKey<String>('${keyPrefix}_${row.originalIndex}'),
      padding: const EdgeInsets.all(16),
      children: fields,
    );
  }

  Widget _buildFieldTile(CsvReviewRow row, String fieldKey, String keyPrefix) {
    final CsvFieldReview? field = row.fields[fieldKey];
    final TextEditingController controller = _fieldControllers[fieldKey] ??
        (_fieldControllers[fieldKey] = TextEditingController(
          text: field?.normalizedValue ?? field?.originalValue ?? '',
        ));

    final bool hasWarning = field?.status == CsvFieldReviewStatus.warn ||
        field?.status == CsvFieldReviewStatus.bad;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        key: Key('${keyPrefix}_${row.originalIndex}_$fieldKey'),
        controller: controller,
        decoration: InputDecoration(
          labelText: field?.columnName ?? fieldKey,
          helperText: hasWarning && field != null && field.messages.isNotEmpty
              ? field.messages.first.message
              : null,
          suffixIcon: hasWarning
              ? const Icon(Icons.warning_amber_outlined, color: Colors.orange)
              : null,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildDerivedTab(List<DerivedValueDisplay> derivedValues, CsvReviewRow row) {
    if (derivedValues.isEmpty) {
      return const Center(child: Text('Žádné odvozené hodnoty.'));
    }
    return ListView(
      key: ValueKey<int>(row.originalIndex),
      padding: const EdgeInsets.all(16),
      children: derivedValues
          .map(
            (DerivedValueDisplay derived) => ListTile(
              title: Text(derived.label),
              subtitle: Text('Hodnota: ${derived.formattedValue}'),
              trailing: Chip(
                label: Text(derived.appliedFlag),
                backgroundColor: derived.applied
                    ? Colors.green.withOpacity(0.15)
                    : Colors.grey.withOpacity(0.15),
              ),
            ),
          )
          .toList(),
    );
  }

  Future<void> _submitEdits(CsvReviewRow row) async {
    final Map<String, String?> payload = _controller.buildPayload(row);
    _fieldControllers.forEach((String key, TextEditingController value) {
      payload[key] = value.text.trim();
    });
    try {
      await _controller.editRow(row, payload);
      _initControllers();
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Úpravu se nepodařilo uložit.')),
      );
    }
  }
}
