import 'package:flutter/material.dart';

/// Spacing tokens extracted from CSV import flow and NewRecord page.
///
/// Based on actual code analysis:
/// - CSV import uses: EdgeInsets.all(24)
/// - NewRecord uses: EdgeInsets.all(20) "for better breathing room"
/// - Internal spacing: 12-24px
class AppSpacing {
  AppSpacing._();

  // Base spacing scale (from actual code)
  static const double xs = 4.0;
  static const double s = 8.0;
  static const double m = 12.0; // Compact spacing
  static const double l = 16.0; // Form field padding
  static const double xl = 20.0; // NewRecord page padding
  static const double xxl = 24.0; // CSV import padding

  // Screen-level padding (matches NewRecord: 20px, CSV: 24px)
  static const EdgeInsets screenPadding = EdgeInsets.all(xl);
  static const EdgeInsets screenPaddingGenerous = EdgeInsets.all(xxl);

  // Form-specific spacing (from NewRecord page)
  static const EdgeInsets formFieldPadding = EdgeInsets.symmetric(
    horizontal: l,
    vertical: m,
  );

  // Container padding (from NewRecord participant box: all 16)
  static const EdgeInsets containerPadding = EdgeInsets.all(l);

  // Compact spacing (isCompact ? 8.0 : 12.0 from NewRecord)
  static const double compactSpacing = s;
  static const double regularSpacing = m;

  // Section spacing (from CSV: height: 12, 24)
  static const SizedBox smallGap = SizedBox(height: m);
  static const SizedBox mediumGap = SizedBox(height: l);
  static const SizedBox largeGap = SizedBox(height: xxl);

  // Button spacing (from CSV: SizedBox(width: 16))
  static const SizedBox buttonGap = SizedBox(width: l);
}
