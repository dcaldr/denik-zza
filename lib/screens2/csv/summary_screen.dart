import 'package:denik_zza/screens2/widgets/app_drawer.dart';
import 'package:denik_zza/services/csv_import_service.dart';
import 'package:denik_zza/design_system/tokens/app_spacing.dart';
import 'package:flutter/material.dart';

import 'widgets/summary_section.dart';

/// Displays the outcome of a CSV finalize operation and offers a way
/// back to the import flow.
class CsvImportSummaryScreen extends StatelessWidget {
  const CsvImportSummaryScreen({
    super.key,
    required this.result,
    required this.importFileLabel,
  });

  /// Aggregated result from the finalize operation.
  final CsvFinalizeResult result;

  /// Label of the source CSV file presented to the user.
  final String importFileLabel;

  /// Replaces the current route with the summary screen and resolves when the
  /// user returns to the first route in the stack.
  static Future<void> openAfterFinalize({
    required BuildContext context,
    required CsvFinalizeResult result,
    required String importFileLabel,
  }) {
    return Navigator.of(context).pushReplacement<void, void>(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => CsvImportSummaryScreen(
          result: result,
          importFileLabel: importFileLabel,
        ),
      ),
    );
  }

  bool get _hasFailures => result.failures.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shrnutí importu'),
      ),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: ListView(
                padding: AppSpacing.screenPadding,
                children: <Widget>[
                  Text(
                    'Soubor: $importFileLabel',
                    key: const Key('CsvSummary_file_label'),
                    style: theme.textTheme.titleMedium,
                  ),
                  SizedBox(height: AppSpacing.m),
                  Wrap(
                    spacing: AppSpacing.l,
                    runSpacing: AppSpacing.l,
                    children: <Widget>[
                      SummaryBadge(
                        key: const Key('CsvSummary_badge_approved'),
                        label: 'Schváleno',
                        count: result.approvedCount,
                        color: theme.colorScheme.primary,
                      ),
                      SummaryBadge(
                        key: const Key('CsvSummary_badge_rejected'),
                        label: 'Odmítnuto',
                        count: result.rejectedCount,
                        color: theme.colorScheme.error,
                      ),
                      SummaryBadge(
                        key: const Key('CsvSummary_badge_saved'),
                        label: 'Uloženo',
                        count: result.savedCount,
                        color: theme.colorScheme.tertiary,
                      ),
                      SummaryBadge(
                        key: const Key('CsvSummary_badge_failed'),
                        label: 'Selhalo',
                        count: result.failedCount,
                        color: theme.colorScheme.secondary,
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.xxl),
                  Text(
                    _hasFailures
                        ? 'Nepodařilo se uložit některé řádky. Zkontrolujte jejich hlášení:'
                        : 'Všechny vybrané řádky byly úspěšně uloženy.',
                    key: const Key('CsvSummary_result_message'),
                    style: theme.textTheme.bodyMedium,
                  ),
                  if (_hasFailures) ...<Widget>[
                    SizedBox(height: AppSpacing.m),
                    ..._buildFailureTiles(theme),
                  ],
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.l,
                  AppSpacing.s,
                  AppSpacing.l,
                  AppSpacing.l,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    TextButton(
                      key: const Key('CsvSummary_return_button'),
                      onPressed: () {
                        Navigator.of(context).popUntil((Route<dynamic> route) {
                          return route.isFirst;
                        });
                      },
                      child: const Text('Zpět na výběr CSV'),
                    ),
                    SizedBox(height: AppSpacing.s),
                    OutlinedButton(
                      key: const Key('CsvSummary_export_placeholder'),
                      onPressed: null,
                      child: const Text('Exportovat výsledky (TODO)'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFailureTiles(ThemeData theme) {
    return <Widget>[
      for (final CsvFinalizeFailure failure in result.failures)
        Card(
          key: Key('CsvSummary_failure_${failure.originalIndex}'),
          margin: EdgeInsets.only(bottom: AppSpacing.s),
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.m),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Řádek ${failure.originalIndex}',
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  failure.message,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
    ];
  }
}
