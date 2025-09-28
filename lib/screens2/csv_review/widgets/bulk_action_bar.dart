import 'package:flutter/material.dart';

/// Provides bulk decision shortcuts and counters for the review table.
class BulkActionBar extends StatelessWidget {
  const BulkActionBar({
    super.key,
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
