// Shared date/time formatting utilities for Czech locale.
//
// Central place for date/time formatting used across UI and PDF generation.
// Uses manual padLeft formatting (no intl dependency) for consistency.

/// Formats a DateTime as Czech date string: 'dd.MM.yyyy'
/// Returns empty string if null.
String formatCzechDate(DateTime? date) {
  if (date == null) return '';
  final d = date.day.toString().padLeft(2, '0');
  final m = date.month.toString().padLeft(2, '0');
  return '$d.$m.${date.year}';
}

/// Formats a DateTime as Czech time string: 'HH:mm'
/// Returns empty string if null.
String formatCzechTime(DateTime? date) {
  if (date == null) return '';
  final h = date.hour.toString().padLeft(2, '0');
  final min = date.minute.toString().padLeft(2, '0');
  return '$h:$min';
}

/// Formats a DateTime as Czech date+time string: 'dd.MM.yyyy HH:mm'
/// Returns empty string if null.
String formatCzechDateTime(DateTime? date) {
  if (date == null) return '';
  return '${formatCzechDate(date)} ${formatCzechTime(date)}';
}
