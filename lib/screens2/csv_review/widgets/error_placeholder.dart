import 'package:flutter/material.dart';

/// Visual placeholder displayed when the review service fails to load data.
class ErrorPlaceholder extends StatelessWidget {
  const ErrorPlaceholder({
    super.key,
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
