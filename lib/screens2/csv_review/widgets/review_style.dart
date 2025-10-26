import 'package:denik_zza/input/csv_review_models.dart';
import 'package:flutter/material.dart';

/// Common styling helpers shared across CSV review widgets.
Color statusColor(BuildContext context, CsvRowReviewStatus status) {
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

/// Returns a localized label that matches the given row status.
/// 
/// Note: [CsvRowReviewStatus.ok] returns "V pořádku" (in order/perfect) instead
/// of "Platné" (valid) to avoid confusion with the "Schválit všechny platné" 
/// button which approves all non-rejected rows (warn+info+ok), not just ok rows.
String statusLabel(CsvRowReviewStatus status) {
  switch (status) {
    case CsvRowReviewStatus.rejected:
      return 'Zamítnuto';
    case CsvRowReviewStatus.warn:
      return 'Varování';
    case CsvRowReviewStatus.info:
      return 'Informace';
    case CsvRowReviewStatus.ok:
      return 'V pořádku';
  }
}

/// Maps field status to a color used for icons and highlights.
Color fieldStatusColor(BuildContext context, CsvFieldReviewStatus status) {
  final ColorScheme colors = Theme.of(context).colorScheme;
  switch (status) {
    case CsvFieldReviewStatus.ok:
      return colors.secondary;
    case CsvFieldReviewStatus.warn:
      return colors.tertiary;
    case CsvFieldReviewStatus.bad:
      return colors.error;
    case CsvFieldReviewStatus.empty:
      return colors.outline;
  }
}

/// Converts field status into a localized label.
String fieldStatusLabel(CsvFieldReviewStatus status) {
  switch (status) {
    case CsvFieldReviewStatus.ok:
      return 'V pořádku';
    case CsvFieldReviewStatus.warn:
      return 'Varování';
    case CsvFieldReviewStatus.bad:
      return 'Chyba';
    case CsvFieldReviewStatus.empty:
      return 'Prázdné';
  }
}

/// Indicates which icon should be displayed for a given field status.
IconData fieldStatusIcon(CsvFieldReviewStatus status) {
  switch (status) {
    case CsvFieldReviewStatus.ok:
      return Icons.check_circle_outline;
    case CsvFieldReviewStatus.warn:
      return Icons.warning_amber_rounded;
    case CsvFieldReviewStatus.bad:
      return Icons.error_outline;
    case CsvFieldReviewStatus.empty:
      return Icons.radio_button_unchecked;
  }
}

/// Builds a short summary text for field status and value.
String fieldSummaryText(CsvFieldReview field) {
  final String value =
      (field.originalValue == null || field.originalValue!.trim().isEmpty)
          ? 'Bez hodnoty'
          : field.originalValue!.trim();
  final String label = fieldStatusLabel(field.status);
  if (field.inferred) {
    return '$value • $label • dopočteno';
  }
  return '$value • $label';
}

/// Returns a localized label for the given decision value.
String decisionLabel(CsvRowDecision decision) {
  switch (decision) {
    case CsvRowDecision.none:
      return 'Bez rozhodnutí';
    case CsvRowDecision.approved:
      return 'Schválit';
    case CsvRowDecision.rejected:
      return 'Odmítnout';
  }
}

/// Maps decisions to a color used for chips and markers.
Color decisionColor(BuildContext context, CsvRowDecision decision) {
  final ColorScheme colors = Theme.of(context).colorScheme;
  switch (decision) {
    case CsvRowDecision.none:
      return colors.outline;
    case CsvRowDecision.approved:
      return colors.secondary;
    case CsvRowDecision.rejected:
      return colors.error;
  }
}
