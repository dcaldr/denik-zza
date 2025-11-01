import 'package:flutter/material.dart';

/// Orange banner widget that indicates development mode
/// 
/// Shows a persistent banner at the top of the screen to make it immediately
/// obvious that the app is running in development mode with test data.
/// 
/// Usage:
/// ```dart
/// Scaffold(
///   body: Column(
///     children: [
///       DevBanner(message: 'Menu Testing (In-Memory DB)'),
///       Expanded(child: YourScreen()),
///     ],
///   ),
/// )
/// ```
class DevBanner extends StatelessWidget {
  /// The message to display in the banner (after "DEV MODE - ")
  final String message;
  
  /// Optional icon to display before the text
  final IconData? icon;

  const DevBanner({
    super.key,
    required this.message,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      color: Colors.orange,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 4),
          ],
          Text(
            'DEV MODE - $message',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Wrapper widget that adds dev banner to any screen
/// 
/// Simplifies adding the dev banner to a screen by handling the Column
/// and Expanded layout automatically.
/// 
/// Usage:
/// ```dart
/// home: DevBannerWrapper(
///   message: 'CSV Import Flow',
///   icon: Icons.table_chart,
///   child: CsvImportScreen(),
/// )
/// ```
class DevBannerWrapper extends StatelessWidget {
  /// The screen to wrap with a dev banner
  final Widget child;
  
  /// The message to display in the banner (after "DEV MODE - ")
  final String message;
  
  /// Optional icon to display before the text
  final IconData? icon;

  const DevBannerWrapper({
    super.key,
    required this.child,
    required this.message,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          DevBanner(message: message, icon: icon),
          Expanded(child: child),
        ],
      ),
    );
  }
}
