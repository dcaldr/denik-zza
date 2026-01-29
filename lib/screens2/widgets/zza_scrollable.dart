import 'package:flutter/material.dart';
import 'package:denik_zza/design_system/tokens/app_colors.dart';
import 'package:denik_zza/design_system/tokens/app_spacing.dart';

/// A wrapper widget that adds visual "fading edges" to scrollable content
/// to signal that there is more content to view.
///
/// **The Problem**: The "Illusion of Completeness". Users often think a list ends
/// just because it cuts off cleanly at a text line.
///
/// **The Solution**:
/// 1.  **Fading Edge**: A gradient overlay at the bottom/top suggests continuity.
/// 2.  **Visual Cue**: An optional chevron or shadow reinforces "scroll down".
///
/// **Usage**:
/// Wrap your [CustomScrollView], [ListView], or any scrollable in [ZzaScrollable].
/// You MUST provide the same [ScrollController] to both this widget and your scrollable child.
///
/// ```dart
/// final controller = ScrollController();
/// return ZzaScrollable(
///   controller: controller,
///   child: ListView(controller: controller, ...),
/// );
/// ```
class ZzaScrollable extends StatefulWidget {
  final Widget child;

  /// The controller attached to the [child]. REQUIRED to monitor scroll position.
  final ScrollController controller;

  /// Optional override for the fade color (defaults to Scaffold background).
  final Color? fadeColor;

  /// Use a lighter, shorter fade for compact heights.
  final bool compactMode;

  const ZzaScrollable({
    super.key,
    required this.child,
    required this.controller,
    this.fadeColor,
    this.compactMode = false,
  });

  @override
  State<ZzaScrollable> createState() => _ZzaScrollableState();
}

class _ZzaScrollableState extends State<ZzaScrollable> {
  bool _hasMoreBelow = false;
  bool _hasMoreAbove = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_updateScrollIndicator);
    // Check initial state after first layout
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _updateScrollIndicator());
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateScrollIndicator);
    super.dispose();
  }

  @override
  void didUpdateWidget(ZzaScrollable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_updateScrollIndicator);
      widget.controller.addListener(_updateScrollIndicator);
      _updateScrollIndicator();
    }
  }

  void _updateScrollIndicator() {
    if (!widget.controller.hasClients) return;

    final position = widget.controller.position;
    // Tolerance of 5 pixels
    final hasMoreBelow = position.pixels < position.maxScrollExtent - 5;
    final hasMoreAbove = position.pixels > 5;

    if (hasMoreBelow != _hasMoreBelow || hasMoreAbove != _hasMoreAbove) {
      setState(() {
        _hasMoreBelow = hasMoreBelow;
        _hasMoreAbove = hasMoreAbove;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Re-check on every build (resize triggers rebuild)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _updateScrollIndicator();
    });

    final fadeColor =
        widget.fadeColor ?? Theme.of(context).scaffoldBackgroundColor;

    final topFadeHeight = widget.compactMode
      ? AppSpacing.xl + AppSpacing.s
      : 48.0;
    final bottomFadeHeight = widget.compactMode
      ? AppSpacing.xl + AppSpacing.m
      : 64.0;
    final fadeOpacity = widget.compactMode ? 0.75 : 0.95;
    final arrowSize = widget.compactMode ? 18.0 : 24.0;

    return Stack(
      children: [
        // The Scrollable Content
        widget.child,

        // Top Fade
        if (_hasMoreAbove)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: topFadeHeight,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      fadeColor.withValues(alpha: fadeOpacity),
                      fadeColor.withValues(alpha: 0.0),
                    ],
                  ),
                ),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Icon(
                      Icons.keyboard_arrow_up,
                      size: arrowSize,
                      color: AppColors.greyText.withValues(alpha: 0.8),
                      shadows: [
                        Shadow(
                          blurRadius: 2,
                          color: Colors.white.withValues(alpha: 0.5),
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

        // Bottom Fade
        if (_hasMoreBelow)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: bottomFadeHeight,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      fadeColor.withValues(alpha: fadeOpacity),
                      fadeColor.withValues(alpha: 0.0),
                    ],
                  ),
                ),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      size: arrowSize,
                      color: AppColors.greyText.withValues(alpha: 0.8),
                      // Add subtle text shadow to make it pop against any background
                      shadows: [
                        Shadow(
                          blurRadius: 2,
                          color: Colors.white.withValues(alpha: 0.5),
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
