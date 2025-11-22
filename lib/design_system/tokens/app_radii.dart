import 'package:flutter/material.dart';

/// Border radius tokens extracted from your actual screens.
///
/// Found in code:
/// - CSV import file box: BorderRadius.circular(12)
/// - NewRecord participant box: BorderRadius.circular(12.0)
/// - NewRecord form fields: BorderRadius.circular(8.0)
/// - NewRecord action buttons: BorderRadius.circular(8.0)
class AppRadii {
  AppRadii._();

  static const double small = 4.0;
  static const double medium = 6.0;
  static const double large = 8.0; // Form fields, buttons
  static const double xl = 12.0; // Containers, cards

  // Common border radii (matching your actual code)
  static const BorderRadius buttonRadius =
      BorderRadius.all(Radius.circular(large)); // 8px
  static const BorderRadius cardRadius =
      BorderRadius.all(Radius.circular(xl)); // 12px
  static const BorderRadius inputRadius =
      BorderRadius.all(Radius.circular(large)); // 8px
  static const BorderRadius containerRadius =
      BorderRadius.all(Radius.circular(xl)); // 12px
}
