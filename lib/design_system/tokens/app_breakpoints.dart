import 'package:flutter/material.dart';

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
  static const double compactHeight = 800.0;

  // Content width constraints
  static const double contentMaxWidth = 1200.0;
  static const double wideContentMaxWidth = 1600.0;
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

  /// True if device should use touch-friendly UI (larger targets, spacing).
  ///
  /// Uses `shortestSide` per Flutter/Material 3 best practices:
  /// - shortestSide < 600: Touch-friendly (phones, narrow windows)
  /// - shortestSide >= 600: Desktop-compact (tablets, desktops)
  ///
  /// This approach correctly handles:
  /// - Phones in landscape (shortestSide still < 600)
  /// - Tablets (shortestSide >= 600, so desktop mode)
  /// - Split-screen/multi-window scenarios
  ///
  /// NOTE: We intentionally don't check Platform.isAndroid/iOS because:
  /// - Device type != available space (Flutter antipattern)
  /// - Tablets have enough screen for compact mode
  /// - Multi-window on mobile breaks platform assumptions
  static bool useTouchMode(BuildContext context) {
    final size = MediaQuery.maybeOf(context)?.size ?? const Size(1280, 720);
    return size.shortestSide < mobile; // < 600px
  }

  /// Width-based touch mode check (use when you have constraints width).
  ///
  /// This allows forms to use the SAME width source for:
  /// - Column count (getColumnCount)
  /// - Touch mode (useTouchModeForWidth)
  ///
  /// Note: For forms, we use width (not shortestSide) because
  /// the form's available width determines column layout.
  static bool useTouchModeForWidth(double width) {
    return width < mobile; // < 600px
  }

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

  /// Item height based on typography (not hardcoded pixels).
  /// Dense mode for compact lists, regular for spacious lists.
  static double getItemHeight(BuildContext context, {bool dense = true}) {
    final fontSize = Theme.of(context).textTheme.bodyMedium?.fontSize ?? 14.0;
    return dense ? fontSize * 2.8 : fontSize * 3.5;
  }

  /// Responsive gap that adapts to screen width.
  /// Mobile: 12px, Tablet: 16px, Desktop: 24px.
  static double getGap(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    if (screenWidth < mobile) return 4.0; // Compact Mobile
    if (screenWidth < desktop) return 8.0; // Tablet & Laptop (Compact)
    return 16.0; // Big Desktop (Breathing Room)
  }

  /// Grid columns based on screen width.
  /// Mobile: 1, Tablet: 2, Desktop: 3.
  static int getGridColumns(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < mobile) return 1;
    if (width < tablet) return 2;
    return 3;
  }

  /// Calculate list height for [itemCount] items without LayoutBuilder.
  /// Uses theme typography for responsive sizing.
  ///
  /// Example:
  /// ```dart
  /// SizedBox(
  ///   height: AppBreakpoints.getListHeight(context, itemCount: 3),
  ///   child: ListView.builder(...),
  /// )
  /// ```
  static double getListHeight(
    BuildContext context, {
    required int itemCount,
    double peekRatio = 0.25,
    bool dense = true,
  }) {
    final itemHeight = getItemHeight(context, dense: dense);
    return (itemCount + peekRatio) * itemHeight;
  }

  /// @Deprecated: Use [getListHeight] instead - no constraints param needed.
  /// Kept for backward compatibility during migration.
  static double listHeightForItems(
    BuildContext context,
    BoxConstraints constraints, {
    required int itemCount,
    double peekRatio = 0.25,
    bool dense = true,
  }) {
    final targetHeight = getListHeight(
      context,
      itemCount: itemCount,
      peekRatio: peekRatio,
      dense: dense,
    );

    // Handle unbounded constraints
    if (!constraints.maxHeight.isFinite) {
      return targetHeight;
    }

    return targetHeight.clamp(
      constraints.maxHeight * 0.1,
      constraints.maxHeight * 0.5,
    );
  }
}
