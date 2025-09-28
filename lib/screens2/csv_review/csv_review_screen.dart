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
        _session = session;
        _isLoading = false;
      });
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _SummarySection(review: review, groupedRows: groupedRows),
        _UnparsedColumnsSection(unparsedColumns: review.unparsedColumns),
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
        return CsvReviewRowCard(row: rows[index]);
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

class CsvReviewRowCard extends StatelessWidget {
  const CsvReviewRowCard({
    super.key,
    required this.row,
  });

  final CsvReviewRow row;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Color statusColor = _statusColor(context, row.status);
    final String statusLabel = _statusLabel(row.status);
    final Iterable<String> messageTexts = row.messages.map((CsvReviewMessage m) => m.message);
    final List<String> fieldPreviews = row.fields.values
        .take(3)
        .map((CsvFieldReview field) => '${field.columnName}: ${field.originalValue ?? ''}')
        .toList();

    return Card(
      key: Key('CsvReviewScreen_row_${row.originalIndex}'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text('Řádek ${row.originalIndex}', style: textTheme.titleMedium),
                const SizedBox(width: 12),
                Chip(
                  key: Key('CsvReviewScreen_row_${row.originalIndex}_status'),
                  label: Text(statusLabel),
                  backgroundColor: statusColor.withValues(alpha: 0.15),
                  labelStyle: textTheme.labelMedium?.copyWith(color: statusColor),
                ),
              ],
            ),
            if (fieldPreviews.isNotEmpty) ...<Widget>[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  for (int i = 0; i < fieldPreviews.length; i++)
                    Chip(
                      key: Key('CsvReviewScreen_row_${row.originalIndex}_field_$i'),
                      label: Text(fieldPreviews[i]),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Text(
              messageTexts.isNotEmpty ? messageTexts.join('\n') : 'Bez zprávy',
              key: Key('CsvReviewScreen_row_${row.originalIndex}_messages'),
            ),
          ],
        ),
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
