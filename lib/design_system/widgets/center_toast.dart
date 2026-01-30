import 'package:flutter/material.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_radii.dart';
import '../tokens/app_spacing.dart';

/// A center-screen floating toast that does not block bottom buttons.
///
/// This widget provides a quick visual confirmation that auto-dismisses
/// without using a SnackBar (which causes `pumpAndSettle` delays in tests).
///
/// ## Usage
/// ```dart
/// CenterToast.show(context, 'Účastník uložen');
/// ```
///
/// ## Customization
/// - [icon]: Defaults to a green checkmark for success.
/// - [duration]: Defaults to 800ms (fast enough for queue-critical intake flow).
/// - [backgroundColor]: Defaults to semi-transparent white.
class CenterToast {
  CenterToast._();

  static bool _disableTimers = false;

  /// Test helper to disable timers and auto-dismiss scheduling.
  static void configureForTests({bool disableTimers = true}) {
    _disableTimers = disableTimers;
  }

  /// Shows a center-screen toast with the given [message].
  ///
  /// - [icon]: The icon to display. Defaults to a green check circle.
  /// - [duration]: How long the toast is visible. Defaults to 800ms.
  /// - [backgroundColor]: Background color of the toast.
  static void show(
    BuildContext context,
    String message, {
    IconData icon = Icons.check_circle,
    Color? iconColor,
    Duration duration = const Duration(milliseconds: 800),
    Color? backgroundColor,
  }) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (context) => _CenterToastWidget(
        message: message,
        icon: icon,
        iconColor: iconColor ?? AppColors.greenIcon,
        backgroundColor: backgroundColor ?? Colors.white.withValues(alpha: 0.95),
        duration: duration,
        disableTimers: _disableTimers,
      ),
    );

    overlay.insert(entry);

    if (_disableTimers) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        entry.remove();
      });
      return;
    }

    // Auto-remove after animation completes
    Future.delayed(duration + const Duration(milliseconds: 200), () {
      entry.remove();
    });
  }
}

class _CenterToastWidget extends StatefulWidget {
  final String message;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final Duration duration;
  final bool disableTimers;

  const _CenterToastWidget({
    required this.message,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.duration,
    required this.disableTimers,
  });

  @override
  State<_CenterToastWidget> createState() => _CenterToastWidgetState();
}

class _CenterToastWidgetState extends State<_CenterToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    // Start fade-in
    _controller.forward();

    if (!widget.disableTimers) {
      // Schedule fade-out
      Future.delayed(widget.duration, () {
        if (mounted) {
          _controller.reverse();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        // Toast should not block interactions
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                key: const Key('CenterToast_container'),
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.xxl,
                  vertical: AppSpacing.l,
                ),
                decoration: BoxDecoration(
                  color: widget.backgroundColor,
                  borderRadius: AppRadii.cardRadius,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.icon,
                      color: widget.iconColor,
                      size: 28,
                    ),
                    SizedBox(width: AppSpacing.m),
                    Text(
                      widget.message,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.greyIcon,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
