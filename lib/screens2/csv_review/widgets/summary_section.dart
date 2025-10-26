import 'package:denik_zza/input/csv_review_models.dart';
import 'package:flutter/material.dart';

import 'review_style.dart';

/// Card that summarizes row counts for the current CSV review session.
class SummarySection extends StatelessWidget {
  const SummarySection({
    super.key,
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
                  SummaryBadge(
                    key: const Key('CsvReviewScreen_summary_rejected_count'),
                    label: 'Zamítnuto',
                    count: groupedRows[CsvRowReviewStatus.rejected]!.length,
                    color: statusColor(context, CsvRowReviewStatus.rejected),
                  ),
                  SummaryBadge(
                    key: const Key('CsvReviewScreen_summary_warn_count'),
                    label: 'Varování',
                    count: groupedRows[CsvRowReviewStatus.warn]!.length,
                    color: statusColor(context, CsvRowReviewStatus.warn),
                  ),
                  SummaryBadge(
                    key: const Key('CsvReviewScreen_summary_info_count'),
                    label: 'Informace',
                    count: groupedRows[CsvRowReviewStatus.info]!.length,
                    color: statusColor(context, CsvRowReviewStatus.info),
                  ),
                  SummaryBadge(
                    key: const Key('CsvReviewScreen_summary_ok_count'),
                    label: 'V pořádku',
                    count: groupedRows[CsvRowReviewStatus.ok]!.length,
                    color: statusColor(context, CsvRowReviewStatus.ok),
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

/// Individual badge used inside [SummarySection].
class SummaryBadge extends StatelessWidget {
  const SummaryBadge({
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
