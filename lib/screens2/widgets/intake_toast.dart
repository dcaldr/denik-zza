import 'package:flutter/material.dart';
import '../../design_system/tokens/app_colors.dart';

/// Shows a centered toast notification for intake form feedback.
///
/// This toast appears in the vertical center of the screen (35% from top),
/// avoiding both the search bar at top and action buttons at bottom.
///
/// Example:
/// ```dart
/// showIntakeToast(context, 'Karel Čapek', arrived: true);
/// // Shows: "✓ Karel Čapek přišel"
/// showIntakeToast(context, 'Ema Destinnová', arrived: true, isFemale: true);
/// // Shows: "✓ Ema Destinnová přišla"
/// ```
void showIntakeToast(
  BuildContext context,
  String personName, {
  bool arrived = true,
  bool isFemale = false,
  Duration duration = const Duration(milliseconds: 1200),
}) {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;

  final message = arrived
      ? '✓ $personName ${isFemale ? 'přišla' : 'přišel'}'
      : '✓ $personName ${isFemale ? 'uložena' : 'uložen'}';

  entry = OverlayEntry(
    builder: (context) => Positioned(
      top: MediaQuery.of(context).size.height * 0.35,
      left: 40,
      right: 40,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.greenBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.greenIcon.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle,
                color: AppColors.greenIcon,
                size: 28,
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  message,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.greenText,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  overlay.insert(entry);
  Future.delayed(duration, () {
    if (entry.mounted) entry.remove();
  });
}
