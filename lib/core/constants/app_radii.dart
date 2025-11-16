import 'package:flutter/material.dart';

/// App-wide border radius constants extracted from NewRecord and CSV screens.
///
/// This app uses ROUNDER corners than Material 3 default (4px):
/// - Inputs/Buttons: 8px (NewRecord actual measurement)
/// - Containers/Cards: 12px (NewRecord and CSV actual measurement)
///
/// Creates a softer, more approachable feel while maintaining professionalism.
///
/// Reference: SCREEN_ANALYSIS.md - Border Radius section
/// Date: 2025-11-16
class AppRadii {
  AppRadii._(); // Private constructor to prevent instantiation

  // ==========================================
  // BASE RADIUS VALUES (in pixels)
  // ==========================================

  /// 4px - Minimal rounding (rarely used)
  static const double small = 4.0;

  /// 6px - Medium rounding (intermediate)
  static const double medium = 6.0;

  /// 8px - Large rounding
  /// Used for: Form fields, buttons (NewRecord style)
  static const double large = 8.0;

  /// 12px - Extra large rounding
  /// Used for: Containers, cards (NewRecord, CSV style)
  static const double xl = 12.0;

  // ==========================================
  // SEMANTIC BORDER RADIUS
  // Use-case specific for better code readability
  // ==========================================

  /// Button border radius (8px - NewRecord measurement)
  /// Use for: FilledButton, OutlinedButton, ElevatedButton
  static const BorderRadius buttonRadius = BorderRadius.all(
    Radius.circular(large),
  );

  /// Card border radius (12px - NewRecord/CSV measurement)
  /// Use for: Card widgets, elevated containers
  static const BorderRadius cardRadius = BorderRadius.all(
    Radius.circular(xl),
  );

  /// Input field border radius (8px - NewRecord measurement)
  /// Use for: TextFormField, TextField, Autocomplete
  static const BorderRadius inputRadius = BorderRadius.all(
    Radius.circular(large),
  );

  /// Container border radius (12px - NewRecord measurement)
  /// Use for: Generic Container, participant boxes, section containers
  static const BorderRadius containerRadius = BorderRadius.all(
    Radius.circular(xl),
  );

  /// Dialog border radius (12px)
  /// Use for: Dialogs, bottom sheets, modal overlays
  static const BorderRadius dialogRadius = BorderRadius.all(
    Radius.circular(xl),
  );

  /// Chip border radius (8px)
  /// Use for: Health status chips, filter chips
  static const BorderRadius chipRadius = BorderRadius.all(
    Radius.circular(large),
  );

  // ==========================================
  // ROUNDED RECTANGLE BORDERS
  // Pre-configured for common use cases
  // ==========================================

  /// Rounded rectangle border for buttons
  static final RoundedRectangleBorder buttonShape = RoundedRectangleBorder(
    borderRadius: buttonRadius,
  );

  /// Rounded rectangle border for cards
  static final RoundedRectangleBorder cardShape = RoundedRectangleBorder(
    borderRadius: cardRadius,
  );

  /// Rounded rectangle border for inputs
  static final RoundedRectangleBorder inputShape = RoundedRectangleBorder(
    borderRadius: inputRadius,
  );

  /// Rounded rectangle border for containers
  static final RoundedRectangleBorder containerShape = RoundedRectangleBorder(
    borderRadius: containerRadius,
  );

  /// Rounded rectangle border for dialogs
  static final RoundedRectangleBorder dialogShape = RoundedRectangleBorder(
    borderRadius: dialogRadius,
  );

  // ==========================================
  // SPECIAL CASES
  // ==========================================

  /// Top-only rounded corners for bottom sheets
  static const BorderRadius bottomSheetRadius = BorderRadius.only(
    topLeft: Radius.circular(xl),
    topRight: Radius.circular(xl),
  );

  /// Bottom-only rounded corners (rare use case)
  static const BorderRadius bottomOnlyRadius = BorderRadius.only(
    bottomLeft: Radius.circular(xl),
    bottomRight: Radius.circular(xl),
  );

  /// No radius (sharp corners)
  static const BorderRadius noRadius = BorderRadius.zero;
}
