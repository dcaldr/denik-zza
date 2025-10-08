import 'package:denik_zza/input/csv_review_models.dart';
import 'package:denik_zza/screens2/csv_review/widgets/csv_row_edit_dialog.dart';
import 'package:denik_zza/screens2/csv_review/widgets/finalize_card.dart';
import 'package:denik_zza/services/csv_import_service.dart';
import 'package:flutter/material.dart';

import 'csv_review_shared.dart';

/// Card gallery prototype grouping rows by status with quick decision buttons.
class CsvReviewCardGalleryScreen extends StatelessWidget {
  const CsvReviewCardGalleryScreen({
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
        return _CardGalleryScaffold(controller: controller);
      },
    );
  }
}

class _CardGalleryScaffold extends StatefulWidget {
  const _CardGalleryScaffold({
    required this.controller,
  });

  final CsvReviewPrototypeController controller;

  @override
  State<_CardGalleryScaffold> createState() => _CardGalleryScaffoldState();
}

class _CardGalleryScaffoldState extends State<_CardGalleryScaffold> {
  final Map<CsvRowReviewStatus, bool> _expanded = <CsvRowReviewStatus, bool>{
    CsvRowReviewStatus.rejected: true,
    CsvRowReviewStatus.warn: true,
    CsvRowReviewStatus.info: false,
    CsvRowReviewStatus.ok: false,
  };

  CsvReviewPrototypeController get _controller => widget.controller;

  @override
  Widget build(BuildContext context) {
    final bool ready = _controller.session != null;
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildPageHeader(context),
            const Divider(height: 1),
            if (!ready)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else ...<Widget>[
              const SizedBox(height: 12),
              _GalleryHeader(controller: _controller),
              const SizedBox(height: 8),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  children: CsvRowReviewStatus.values
                      .map((CsvRowReviewStatus status) => _buildSection(context, status))
                      .toList(),
                ),
              ),
            ],
          ],
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
                    key: const Key('CsvCardGallery_finalize'),
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

  Widget _buildPageHeader(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              'Galerie záznamů CSV',
              style: theme.textTheme.titleLarge,
            ),
          ),
          IconButton(
            key: const Key('CsvCardGallery_refresh'),
            onPressed: _controller.reload,
            icon: const Icon(Icons.refresh),
            tooltip: 'Znovu načíst soubor',
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, CsvRowReviewStatus status) {
    final List<CsvReviewRow> rows = _controller.groupedRows[status] ?? <CsvReviewRow>[];
    final ThemeData theme = Theme.of(context);
    final String title = '${statusLabel(status)} (${rows.length})';

    return ExpansionPanelList.radio(
      elevation: 0,
      expandedHeaderPadding: EdgeInsets.zero,
      initialOpenPanelValue: status,
      children: <ExpansionPanelRadio>[
        ExpansionPanelRadio(
          value: status,
          canTapOnHeader: true,
          headerBuilder: (BuildContext context, bool isExpanded) {
            _expanded[status] = isExpanded;
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              title: Text(title),
              leading: Icon(
                _iconForStatus(status),
                color: statusColor(theme, status),
              ),
              trailing: Text(
                isExpanded ? 'Skrýt' : 'Zobrazit',
                style: theme.textTheme.labelMedium,
              ),
            );
          },
          body: rows.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Žádné záznamy.',
                    style: theme.textTheme.bodyMedium,
                  ),
                )
              : _GalleryGrid(
                  status: status,
                  rows: rows,
                  controller: _controller,
                  keyPrefix: 'CsvCardGallery_${status.name}',
                ),
        ),
      ],
    );
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
}

class _GalleryHeader extends StatelessWidget {
  const _GalleryHeader({
    required this.controller,
  });

  final CsvReviewPrototypeController controller;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Wrap(
          spacing: 16,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            Text(
              'Soubor obsahuje ${controller.totalRowCount} řádků.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Chip(
              avatar: const Icon(Icons.library_add_check, size: 16),
              label: Text('Připravené: ${controller.groupedRows[CsvRowReviewStatus.ok]?.length ?? 0}'),
            ),
            Chip(
              avatar: const Icon(Icons.warning_amber_outlined, size: 16),
              label: Text('K řešení: ${(controller.groupedRows[CsvRowReviewStatus.warn]?.length ?? 0) + (controller.groupedRows[CsvRowReviewStatus.rejected]?.length ?? 0)}'),
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
            ),
            if (controller.duplicateRowCount > 0)
              Chip(
                avatar: const Icon(Icons.construction, size: 16),
                label: Text('Duplicitní: ${controller.duplicateRowCount}'),
                backgroundColor: Theme.of(context).colorScheme.errorContainer,
              ),
          ],
        ),
      ),
    );
  }
}

class _GalleryGrid extends StatelessWidget {
  const _GalleryGrid({
    required this.status,
    required this.rows,
    required this.controller,
    required this.keyPrefix,
  });

  final CsvRowReviewStatus status;
  final List<CsvReviewRow> rows;
  final CsvReviewPrototypeController controller;
  final String keyPrefix;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final SliverGridDelegate delegate = const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 360,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.95,
        );
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 16),
          gridDelegate: delegate,
          itemCount: rows.length,
          itemBuilder: (BuildContext context, int index) {
            final CsvReviewRow row = rows[index];
            return _GalleryCard(
              row: row,
              controller: controller,
              keyPrefix: keyPrefix,
            );
          },
        );
      },
    );
  }
}

class _GalleryCard extends StatelessWidget {
  const _GalleryCard({
    required this.row,
    required this.controller,
    required this.keyPrefix,
  });

  final CsvReviewRow row;
  final CsvReviewPrototypeController controller;
  final String keyPrefix;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final CsvRowDecision decision = controller.decisionForRow(row.originalIndex);
    final List<DerivedValueDisplay> derivedValues = derivedValueDisplays(row);
    final bool hasDuplicate = controller.hasDuplicate(row.originalIndex);

    return Card(
      key: ValueKey<String>('${keyPrefix}_${row.originalIndex}'),
      elevation: decision == CsvRowDecision.approved ? 6 : 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    _primaryLabel(row),
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                Icon(
                  _iconForDecision(decision),
                  color: _colorForDecision(theme, decision),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: <Widget>[
                Chip(
                  label: Text(statusLabel(row.status)),
                  backgroundColor: statusColor(theme, row.status).withOpacity(0.15),
                ),
                if (hasDuplicate)
                  Chip(
                    avatar: const Icon(Icons.construction, size: 16),
                    label: const Text('Možná duplicita'),
                    backgroundColor: theme.colorScheme.errorContainer,
                  ),
                Chip(
                  avatar: const Icon(Icons.list_alt, size: 16),
                  label: Text('Zprávy: ${row.messages.length}'),
                ),
              ],
            ),
            const Divider(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: derivedValues
                  .map(
                    (DerivedValueDisplay derived) => InputChip(
                      label: Text('${derived.label}: ${derived.formattedValue}'),
                      avatar: Icon(
                        derived.applied ? Icons.check : Icons.hourglass_bottom,
                        size: 16,
                      ),
                    ),
                  )
                  .toList(),
            ),
            const Spacer(),
            const SizedBox(height: 8),
            SegmentedButton<CsvRowDecision>(
              key: Key('${keyPrefix}_decision_${row.originalIndex}'),
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
                  icon: Icon(Icons.pause),
                  label: Text('Později'),
                ),
              ],
              selected: <CsvRowDecision>{decision},
              onSelectionChanged: (Set<CsvRowDecision> value) {
                controller.updateDecision(row.originalIndex, value.single);
              },
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
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
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Upravit'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _primaryLabel(CsvReviewRow row) {
    final CsvFieldReview? name = row.fields['jmeno'];
    final CsvFieldReview? surname = row.fields['prijmeni'];
    return '${name?.normalizedValue ?? name?.originalValue ?? ''} ${surname?.normalizedValue ?? surname?.originalValue ?? ''}'.trim();
  }

  IconData _iconForDecision(CsvRowDecision decision) {
    switch (decision) {
      case CsvRowDecision.approved:
        return Icons.thumb_up_alt_outlined;
      case CsvRowDecision.rejected:
        return Icons.thumb_down_alt_outlined;
      case CsvRowDecision.none:
        return Icons.hourglass_empty;
    }
  }

  Color _colorForDecision(ThemeData theme, CsvRowDecision decision) {
    switch (decision) {
      case CsvRowDecision.approved:
        return Colors.green;
      case CsvRowDecision.rejected:
        return theme.colorScheme.error;
      case CsvRowDecision.none:
        return theme.colorScheme.outline;
    }
  }
}
