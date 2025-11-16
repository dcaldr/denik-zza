import 'package:flutter/material.dart';

/// App-wide spacing constants extracted from CSV import flow and NewRecord page.
///
/// Spacing scale follows 4px base unit for consistency.
/// CSV import uses generous 24px padding (most open feel).
/// NewRecord uses 20px padding (balanced feel).
///
/// User feedback: "Too cramped, need more whitespace" - These values address that.
///
/// Reference: SCREEN_ANALYSIS.md, APP_DESIGN_FEEL.md line 714
/// Date: 2025-11-16
class AppSpacing {
  AppSpacing._(); // Private constructor to prevent instantiation

  // ==========================================
  // BASE SPACING SCALE (4px increments)
  // Single source of truth for all spacing
  // ==========================================

  /// 4px - Minimal spacing for very tight layouts
  static const double xs = 4.0;

  /// 8px - Compact spacing
  /// Used in: Card gaps, chip spacing, small section dividers
  static const double s = 8.0;

  /// 12px - Medium spacing
  /// Used in: Section gaps within cards, form field internal padding
  static const double m = 12.0;

  /// 16px - Large spacing
  /// Used in: Form field padding, button gaps, standard container padding
  static const double l = 16.0;

  /// 20px - Extra large spacing (NewRecord screen padding)
  /// Used in: Default screen padding for balanced feel
  static const double xl = 20.0;

  /// 24px - Extra extra large spacing (CSV screen padding)
  /// Used in: Generous screen padding for most open feel
  static const double xxl = 24.0;

  // ==========================================
  // SEMANTIC SPACING (Use-case specific)
  // These make code more readable and maintainable
  // ==========================================

  /// Default screen padding (20px all sides) - NewRecord style
  /// Use for: Most screens that need breathing room
  /// Fixes: ParticipantRegistrationForm edge-to-edge issue
  static const EdgeInsets screenPadding = EdgeInsets.all(xl);

  /// Generous screen padding (24px all sides) - CSV import style
  /// Use for: Screens that need maximum open feel
  static const EdgeInsets screenPaddingGenerous = EdgeInsets.all(xxl);

  /// Horizontal screen padding only
  /// Use for: Screens with vertical scrolling that need side margins only
  static const EdgeInsets screenPaddingHorizontal = EdgeInsets.symmetric(horizontal: xl);

  /// Form field internal padding (16px horizontal, 12px vertical)
  /// Use for: TextFormField contentPadding
  static const EdgeInsets formFieldPadding = EdgeInsets.symmetric(
    horizontal: l,
    vertical: m,
  );

  /// Container internal padding (16px all sides)
  /// Use for: Generic container padding, dialog content
  static const EdgeInsets containerPadding = EdgeInsets.all(l);

  /// Card internal padding (12px all sides)
  /// Use for: Card content padding (slightly tighter than containers)
  static const EdgeInsets cardPadding = EdgeInsets.all(m);

  /// Button internal padding (14px vertical, 20px horizontal)
  /// Extracted from NewRecord actual button measurements
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    vertical: 14.0,
    horizontal: 20.0,
  );

  /// Outlined button padding (14px vertical, 16px horizontal)
  /// Slightly less horizontal padding than filled buttons
  static const EdgeInsets outlinedButtonPadding = EdgeInsets.symmetric(
    vertical: 14.0,
    horizontal: 16.0,
  );

  /// List item padding (16px horizontal, 12px vertical)
  /// Use for: ListTile contentPadding
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(
    horizontal: l,
    vertical: m,
  );

  /// Dialog padding (24px all sides)
  /// Use for: Dialog content with extra breathing room
  static const EdgeInsets dialogPadding = EdgeInsets.all(xxl);

  // ==========================================
  // GAP WIDGETS (Spacers for Column/Row)
  // More readable than SizedBox(height: ...)
  // ==========================================

  /// 4px vertical gap - Minimal
  static const Widget tinyGap = SizedBox(height: xs);

  /// 8px vertical gap - Small section divider
  /// Use for: Space between related items in a list
  static const Widget smallGap = SizedBox(height: s);

  /// 12px vertical gap - Medium section divider
  /// Use for: Space between form sections
  static const Widget mediumGap = SizedBox(height: m);

  /// 16px vertical gap - Large section divider
  /// Use for: Space between major sections
  static const Widget largeGap = SizedBox(height: l);

  /// 20px vertical gap - Extra large section divider
  static const Widget xlargeGap = SizedBox(height: xl);

  /// 24px vertical gap - Maximum section divider
  /// Use for: Space between major content blocks
  static const Widget xxlargeGap = SizedBox(height: xxl);

  // ==========================================
  // HORIZONTAL GAPS
  // For Row widgets
  // ==========================================

  /// 4px horizontal gap - Minimal
  static const Widget tinyHGap = SizedBox(width: xs);

  /// 8px horizontal gap - Small
  /// Use for: Space between related buttons in a row
  static const Widget smallHGap = SizedBox(width: s);

  /// 12px horizontal gap - Medium
  static const Widget mediumHGap = SizedBox(width: m);

  /// 16px horizontal gap - Large (button gap from NewRecord)
  /// Use for: Space between action buttons
  static const Widget buttonGap = SizedBox(width: l);

  /// 20px horizontal gap - Extra large
  static const Widget xlargeHGap = SizedBox(width: xl);

  /// 24px horizontal gap - Maximum
  static const Widget xxlargeHGap = SizedBox(width: xxl);

  // ==========================================
  // SPECIFIC USE CASES
  // Common spacing patterns
  // ==========================================

  /// Padding for screens that should NOT be edge-to-edge
  /// Addresses user complaint: "completely edge to edge... spills whole screen"
  /// Use for: ParticipantRegistrationForm, EventList, EventRegistrationForm
  static const EdgeInsets notEdgeToEdge = screenPadding;

  /// Bottom padding for floating action buttons
  /// Ensures FAB doesn't overlap content
  static const EdgeInsets fabPadding = EdgeInsets.only(bottom: 72.0);

  /// Padding for bottom sheets
  /// Combines with safe area for proper spacing
  static const EdgeInsets bottomSheetPadding = EdgeInsets.all(l);
}
