import 'package:denik_zza/input/csv_review_models.dart';
import 'package:denik_zza/screens2/csv_review/widgets/csv_row_edit_dialog.dart';
import 'package:denik_zza/screens2/csv_review/widgets/finalize_card.dart';
import 'package:denik_zza/services/csv_import_service.dart';
import 'package:flutter/material.dart';

import 'csv_review_shared.dart';

/// Guided checklist prototype focusing on reassuring new users with a linear
/// three-step flow.
class CsvReviewChecklistScreen extends StatelessWidget {
  const CsvReviewChecklistScreen({
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
        return _ChecklistScaffold(controller: controller);
      },
    );
  }
}

class _ChecklistScaffold extends StatefulWidget {
  const _ChecklistScaffold({
    required this.controller,
  });

  final CsvReviewPrototypeController controller;

  @override
  State<_ChecklistScaffold> createState() => _ChecklistScaffoldState();
}

class _ChecklistScaffoldState extends State<_ChecklistScaffold> {
  final List<_ChecklistStepDefinition> _steps = const <_ChecklistStepDefinition>[
    _ChecklistStepDefinition(
      title: 'Souhrn',
      description: 'Zkontrolujte základní údaje o souboru a celkový stav.',
      statusFilter: null,
      keyPrefix: 'CsvChecklist_summary',
    ),
    _ChecklistStepDefinition(
      title: 'Potřebuje opravy',
      description: 'Vyřešte řádky, které vyžadují zásah před importem.',
      statusFilter: CsvRowReviewStatus.rejected,
      includeWarn: true,
      keyPrefix: 'CsvChecklist_fixes',
    ),
    _ChecklistStepDefinition(
      title: 'Připraveno',
      description: 'Potvrďte řádky, které jsou připravené k importu.',
      statusFilter: CsvRowReviewStatus.ok,
      includeInfo: true,
      keyPrefix: 'CsvChecklist_ready',
    ),
  ];

  int _selectedIndex = 0;

  CsvReviewPrototypeController get _controller => widget.controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kontrolní seznam importu CSV'),
        actions: <Widget>[
          IconButton(
            key: const Key('CsvChecklist_refresh'),
            onPressed: _controller.reload,
            icon: const Icon(Icons.refresh),
            tooltip: 'Znovu načíst soubor',
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            const double breakpoint = 900;
            if (constraints.maxWidth >= breakpoint) {
              return _buildWideLayout(context);
            }
            return _buildCompactLayout(context);
          },
        ),
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
                    key: const Key('CsvChecklist_finalize'),
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

  Widget _buildWideLayout(BuildContext context) {
    return Row(
      children: <Widget>[
        NavigationRail(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (int index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          labelType: NavigationRailLabelType.all,
          destinations: _steps
              .map(
                (_ChecklistStepDefinition step) => NavigationRailDestination(
                  icon: const Icon(Icons.circle_outlined),
                  selectedIcon: const Icon(Icons.check_circle),
                  label: Text(step.title),
                ),
              )
              .toList(),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: _buildStepContent(context, _steps[_selectedIndex]),
        ),
      ],
    );
  }

  Widget _buildCompactLayout(BuildContext context) {
    return Column(
      children: <Widget>[
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SegmentedButton<int>(
            segments: List<ButtonSegment<int>>.generate(
              _steps.length,
              (int index) => ButtonSegment<int>(
                value: index,
                label: Text(_steps[index].title),
              ),
            ),
            selected: <int>{_selectedIndex},
            onSelectionChanged: (Set<int> selection) {
              setState(() {
                _selectedIndex = selection.first;
              });
            },
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: _buildStepContent(context, _steps[_selectedIndex]),
        ),
      ],
    );
  }

  Widget _buildStepContent(BuildContext context, _ChecklistStepDefinition step) {
    if (_controller.session == null) {
      return const SizedBox.shrink();
    }
    final ThemeData theme = Theme.of(context);

    final List<CsvReviewRow> rows = _rowsForStep(step);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: ListView(
        key: ValueKey<String>(step.keyPrefix),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        children: <Widget>[
          Text(
            step.title,
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 4),
          Text(
            step.description,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          if (step.statusFilter == null) _buildSummaryCards(context) else const SizedBox.shrink(),
          if (rows.isEmpty)
            _buildEmptyState(context)
          else
            ...rows.map((CsvReviewRow row) => _ChecklistRowCard(
                  keyPrefix: step.keyPrefix,
                  row: row,
                  controller: _controller,
                  highlightWarnings: step.statusFilter == CsvRowReviewStatus.rejected || step.includeWarn,
                  showInfoBadge: step.includeInfo,
                )),
          const SizedBox(height: 24),
          _buildActionBar(context, step),
        ],
      ),
    );
  }

  List<CsvReviewRow> _rowsForStep(_ChecklistStepDefinition step) {
    if (step.statusFilter == null) {
      return _controller.rows;
    }
    final List<CsvRowReviewStatus> statuses = <CsvRowReviewStatus>[step.statusFilter!];
    if (step.includeWarn) {
      statuses.add(CsvRowReviewStatus.warn);
    }
    if (step.includeInfo) {
      statuses.add(CsvRowReviewStatus.info);
    }
    return _controller.rows
        .where((CsvReviewRow row) => statuses.contains(row.status))
        .toList(growable: false);
  }

  Widget _buildSummaryCards(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: <Widget>[
        _SummaryChip(
          icon: Icons.library_add_check,
          label: 'Připravené',
          value: _controller.groupedRows[CsvRowReviewStatus.ok]?.length ?? 0,
          color: theme.colorScheme.primary,
        ),
        _SummaryChip(
          icon: Icons.info_outline,
          label: 'Informativní',
          value: _controller.groupedRows[CsvRowReviewStatus.info]?.length ?? 0,
          color: theme.colorScheme.secondary,
        ),
        _SummaryChip(
          icon: Icons.warning_amber,
          label: 'Vyžaduje pozornost',
          value: (_controller.groupedRows[CsvRowReviewStatus.warn]?.length ?? 0) +
              (_controller.groupedRows[CsvRowReviewStatus.rejected]?.length ?? 0),
          color: theme.colorScheme.error,
        ),
        _SummaryChip(
          icon: Icons.file_copy,
          label: 'Celkem řádků',
          value: _controller.totalRowCount,
          color: theme.colorScheme.outline,
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 64),
      child: Column(
        children: const <Widget>[
          Icon(Icons.tag_faces_outlined, size: 48),
          SizedBox(height: 12),
          Text('Pro tento krok nejsou k dispozici žádné řádky.'),
        ],
      ),
    );
  }

  Widget _buildActionBar(BuildContext context, _ChecklistStepDefinition step) {
    final ThemeData theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceVariant,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'Rozhodnutí: ${_controller.approvedCount} přijato, ${_controller.rejectedCount} zamítnuto, ${_controller.undecidedCount} čeká.',
              ),
            ),
            const SizedBox(width: 16),
            FilledButton.icon(
              key: Key('${step.keyPrefix}_approveStep'),
              onPressed: () {
                if (step.statusFilter == null) {
                  _controller.bulkApproveUpToInfo();
                } else {
                  _controller.bulkApproveOk();
                }
              },
              icon: const Icon(Icons.check),
              label: const Text('Přijmout vše'),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              key: Key('${step.keyPrefix}_reject'),
              onPressed: _controller.bulkRejectOnlyRejected,
              icon: const Icon(Icons.close),
              label: const Text('Zamítnout chyby'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChecklistRowCard extends StatelessWidget {
  const _ChecklistRowCard({
    required this.keyPrefix,
    required this.row,
    required this.controller,
    required this.highlightWarnings,
    required this.showInfoBadge,
  });

  final String keyPrefix;
  final CsvReviewRow row;
  final CsvReviewPrototypeController controller;
  final bool highlightWarnings;
  final bool showInfoBadge;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final CsvRowDecision decision = controller.decisionForRow(row.originalIndex);
    final List<DerivedValueDisplay> derivedValues = derivedValueDisplays(row);

    return Card(
      key: ValueKey<String>('${keyPrefix}_${row.originalIndex}'),
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      _primaryLabel(row),
                      style: theme.textTheme.titleMedium,
                    ),
                    Text('Řádek ${row.originalIndex}')
                  ],
                ),
                Wrap(
                  spacing: 8,
                  children: <Widget>[
                    Chip(
                      label: Text(statusLabel(row.status)),
                      backgroundColor: statusColor(theme, row.status).withOpacity(0.15),
                    ),
                    if (controller.hasDuplicate(row.originalIndex))
                      Chip(
                        avatar: const Icon(Icons.construction, size: 16),
                        label: const Text('Možná duplicita'),
                        backgroundColor: theme.colorScheme.errorContainer,
                      ),
                    if (showInfoBadge)
                      Chip(
                        avatar: const Icon(Icons.lightbulb_outline, size: 16),
                        label: Text('${row.messages.length} poznámek'),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: derivedValues
                  .map(
                    (DerivedValueDisplay display) => InputChip(
                      avatar: Icon(
                        display.applied ? Icons.check : Icons.hourglass_bottom,
                        size: 16,
                      ),
                      label: Text('${display.label}: ${display.formattedValue} (${display.appliedFlag})'),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                SegmentedButton<CsvRowDecision>(
                  segments: const <ButtonSegment<CsvRowDecision>>[
                    ButtonSegment<CsvRowDecision>(
                      value: CsvRowDecision.approved,
                      label: Text('Přijmout'),
                      icon: Icon(Icons.thumb_up_alt_outlined),
                    ),
                    ButtonSegment<CsvRowDecision>(
                      value: CsvRowDecision.rejected,
                      label: Text('Zamítnout'),
                      icon: Icon(Icons.thumb_down_alt_outlined),
                    ),
                    ButtonSegment<CsvRowDecision>(
                      value: CsvRowDecision.none,
                      label: Text('Odložit'),
                      icon: Icon(Icons.pause_circle_outline),
                    ),
                  ],
                  selected: <CsvRowDecision>{decision},
                  onSelectionChanged: (Set<CsvRowDecision> selection) {
                    controller.updateDecision(
                      row.originalIndex,
                      selection.single,
                    );
                  },
                ),
                const SizedBox(width: 16),
                TextButton.icon(
                  key: Key('${keyPrefix}_edit_${row.originalIndex}'),
                  onPressed: () async {
                    final Map<String, String?>? payload = await showDialog<Map<String, String?>>(
                      context: context,
                      builder: (BuildContext context) => CsvRowEditDialog(row: row),
                    );
                    if (payload != null) {
                      try {
                        await controller.editRow(row, payload);
                      } catch (_) {
                        if (!context.mounted) {
                          return;
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Úpravu se nepodařilo uložit.')),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.edit_square),
                  label: const Text('Upravit'),
                ),
              ],
            ),
            if (highlightWarnings && row.messages.isNotEmpty) ...<Widget>[
              const SizedBox(height: 12),
              _WarningList(messages: row.messages),
            ],
          ],
        ),
      ),
    );
  }

  String _primaryLabel(CsvReviewRow row) {
    final CsvFieldReview? firstName = row.fields['jmeno'];
    final CsvFieldReview? lastName = row.fields['prijmeni'];
    final CsvFieldReview? birthDate = row.fields['datum_narozeni'];
    final String name =
        '${firstName?.normalizedValue ?? firstName?.originalValue ?? ''} ${lastName?.normalizedValue ?? lastName?.originalValue ?? ''}'.trim();
    final String birth = birthDate?.normalizedValue ?? birthDate?.originalValue ?? '';
    if (birth.isEmpty) {
      return name.isEmpty ? 'Řádek ${row.originalIndex}' : name;
    }
    return '$name – $birth';
  }
}

class _ChecklistStepDefinition {
  const _ChecklistStepDefinition({
    required this.title,
    required this.description,
    required this.statusFilter,
    required this.keyPrefix,
    this.includeWarn = false,
    this.includeInfo = false,
  });

  final String title;
  final String description;
  final CsvRowReviewStatus? statusFilter;
  final String keyPrefix;
  final bool includeWarn;
  final bool includeInfo;
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, color: color),
      label: Text('$label: $value'),
      backgroundColor: color.withOpacity(0.15),
    );
  }
}

class _WarningList extends StatelessWidget {
  const _WarningList({
    required this.messages,
  });

  final List<CsvReviewMessage> messages;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: messages
          .map(
            (CsvReviewMessage message) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(
                    _iconForSeverity(message.severity),
                    size: 16,
                    color: _colorForSeverity(context, message.severity),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(message.message)),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  IconData _iconForSeverity(CsvReviewMessageSeverity severity) {
    switch (severity) {
      case CsvReviewMessageSeverity.info:
        return Icons.info_outline;
      case CsvReviewMessageSeverity.warn:
        return Icons.warning_amber_outlined;
      case CsvReviewMessageSeverity.error:
        return Icons.error_outline;
    }
  }

  Color _colorForSeverity(BuildContext context, CsvReviewMessageSeverity severity) {
    final ThemeData theme = Theme.of(context);
    switch (severity) {
      case CsvReviewMessageSeverity.info:
        return theme.colorScheme.primary;
      case CsvReviewMessageSeverity.warn:
        return theme.colorScheme.tertiary;
      case CsvReviewMessageSeverity.error:
        return theme.colorScheme.error;
    }
  }
}
