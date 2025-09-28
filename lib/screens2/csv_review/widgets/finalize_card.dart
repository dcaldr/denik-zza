import 'package:flutter/material.dart';

/// Summary card that presents finalize counts and action button.
class FinalizeCard extends StatelessWidget {
  const FinalizeCard({
    super.key,
    required this.approvedCount,
    required this.rejectedCount,
    required this.undecidedCount,
    required this.duplicateCount,
    required this.isFinalizing,
    required this.onFinalize,
  });

  final int approvedCount;
  final int rejectedCount;
  final int undecidedCount;
  final int duplicateCount;
  final bool isFinalizing;
  final VoidCallback onFinalize;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    final bool isButtonEnabled = !isFinalizing && approvedCount > 0;

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
                      key: const Key(
                          'CsvReviewScreen_finalize_duplicates_count'),
                      avatar: const Icon(Icons.warning_amber_rounded, size: 16),
                      label: Text('Možné duplicity: $duplicateCount'),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                key: const Key('CsvReviewScreen_finalize_button'),
                onPressed: isButtonEnabled ? onFinalize : null,
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
              if (isFinalizing) ...<Widget>[
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
}
