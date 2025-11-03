import 'package:flutter/material.dart';

/// Development warning badge indicating mock/test data is in use
///
/// Shows a prominent "USES MOCKUPS !!" badge to clearly indicate
/// that the current data is for development/testing purposes only.
///
/// **Usage:**
/// ```dart
/// Row(
///   children: [
///     Text('Section Title'),
///     const SizedBox(width: 8),
///     const DevMockDataBadge(),
///   ],
/// )
/// ```
///
/// **When to use:**
/// - Near data displays that use DevEnvironment mock data
/// - In forms that don't yet have real data entry workflows
/// - Next to participant/health info sections during development
///
/// **When to remove:**
/// - After implementing real data entry forms
/// - When production data sources are wired up
/// - Before deployment to production environment
class DevMockDataBadge extends StatelessWidget {
  /// Optional custom text (defaults to "USES MOCKUPS !!")
  final String? text;
  
  /// Optional custom icon (defaults to Icons.construction)
  final IconData? icon;

  const DevMockDataBadge({
    super.key,
    this.text,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade400, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon ?? Icons.construction,
            size: 10,
            color: Colors.orange.shade700,
          ),
          const SizedBox(width: 2),
          Text(
            text ?? 'USES MOCKUPS !!',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: Colors.orange.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
