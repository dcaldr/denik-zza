import 'package:flutter/widgets.dart';

/// Centralized breakpoint constants and responsive helpers.
///
/// Usage:
/// ```dart
/// LayoutBuilder(
///   builder: (context, constraints) {
///     if (AppBreakpoints.isMobile(constraints.maxWidth)) {
///       return MobileLayout();
///     }
///     return DesktopLayout();
///   },
/// )
/// ```
///
/// See /flutter-ui workflow for responsive design patterns.
class AppBreakpoints {
  AppBreakpoints._();

  // Width breakpoints per /flutter-ui workflow
  // - Compact (<600dp): Mobile phones (portrait)
  // - Medium (600–900dp): Tablets, landscape phones
  // - Expanded (>900dp): Large tablets, desktops
  static const double mobile = 600.0;
  static const double tablet = 900.0;
  static const double desktop = 1200.0;

  // Height breakpoint for compact vertical layouts
  static const double compactHeight = 600.0;

  // Content width constraints
  static const double contentMaxWidth = 1200.0;
  static const double formMaxWidth = 800.0;

  // --- Helper Methods ---

  /// True if width is in mobile range (<600px).
  static bool isMobile(double width) => width < mobile;

  /// True if width is in tablet range (600-900px).
  static bool isTablet(double width) => width >= mobile && width < tablet;

  /// True if width is in desktop range (≥900px).
  static bool isDesktop(double width) => width >= tablet;

  /// True if height indicates a compact vertical layout.
  static bool isCompactHeight(double height) => height <= compactHeight;

  /// Returns optimal column count for responsive form layouts.
  /// - Desktop (≥900px): 3 columns
  /// - Tablet (600-899px): 2 columns
  /// - Mobile (<600px): 1 column
  static int getColumnCount(double width) {
    if (width >= tablet) return 3;
    if (width >= mobile) return 2;
    return 1;
  }

  /// Returns optimal column count from BoxConstraints.
  static int getColumnCountFromConstraints(BoxConstraints constraints) {
    return getColumnCount(constraints.maxWidth);
  }
}
