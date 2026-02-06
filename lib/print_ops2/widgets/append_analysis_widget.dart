import 'package:flutter/material.dart';
import 'package:denik_zza/design_system/tokens/app_radii.dart';
import 'package:denik_zza/design_system/tokens/app_spacing.dart';
import '../models/append_analysis.dart';

/// Widget for displaying append analysis results (T9)
///
/// Shows the results of the three-pass append algorithm analysis
/// with user-friendly information about page counts and append mode.
class AppendAnalysisWidget extends StatelessWidget {
  final AppendAnalysis? analysis;
  final bool isLoading;
  final String? error;

  const AppendAnalysisWidget({
    super.key,
    this.analysis,
    this.isLoading = false,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Card(
        key: const Key('AppendAnalysisWidget_loading_card'),
        child: Padding(
          padding: AppSpacing.containerPadding,
          child: Row(
            children: [
              const SizedBox(
                width: AppSpacing.xl,
                height: AppSpacing.xl,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: AppSpacing.m),
              Text(
                'Analyzuji možnosti tisku...',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    if (error != null) {
      return Card(
        key: const Key('AppendAnalysisWidget_error_card'),
        color: Theme.of(context).colorScheme.errorContainer,
        child: Padding(
          padding: AppSpacing.containerPadding,
          child: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Theme.of(context).colorScheme.error,
                key: const Key('AppendAnalysisWidget_error_icon'),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Text(
                  'Chyba analýzy: $error',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (analysis == null) {
      return const SizedBox.shrink();
    }

    return Card(
      key: const Key('AppendAnalysisWidget_analysis_card'),
      child: Padding(
        padding: AppSpacing.containerPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics_outlined,
                  color: Theme.of(context).primaryColor,
                  key: const Key('AppendAnalysisWidget_analysis_icon'),
                ),
                const SizedBox(width: AppSpacing.s),
                Text(
                  'Analýza tisku',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.m),

            // Main description
            Container(
              key: const Key('AppendAnalysisWidget_description_container'),
              padding: const EdgeInsets.all(AppSpacing.m),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: AppRadii.buttonRadius,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.print,
                    size: AppSpacing.xl,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: AppSpacing.s),
                  Expanded(
                    child: Text(
                      analysis!.getAppendModeDescription(),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.m),

            // Detailed information
            _buildDetailRow(
              context,
              'Aktuální stránky:',
              '${analysis!.baselinePages}',
              key: 'baseline_pages',
            ),
            _buildDetailRow(
              context,
              'Finální stránky:',
              '${analysis!.finalPages}',
              key: 'final_pages',
            ),
            if (analysis!.additionalPages > 0)
              _buildDetailRow(
                context,
                'Nové stránky:',
                '${analysis!.additionalPages}',
                key: 'additional_pages',
              ),
            if (analysis!.reusedLastPage)
              _buildDetailRow(
                context,
                'Pokračování:',
                'Na straně ${analysis!.insertionPage}',
                key: 'continuation_info',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value, {
    required String key,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        key: Key('AppendAnalysisWidget_${key}_row'),
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}
