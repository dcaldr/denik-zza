import 'package:flutter/material.dart';
import 'package:denik_zza/design_system/tokens/app_colors.dart';

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

  const ZzaScrollable({
    super.key,
    required this.child,
    required this.controller,
    this.fadeColor,
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
    final fadeColor =
        widget.fadeColor ?? Theme.of(context).scaffoldBackgroundColor;

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
            height: 24,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      fadeColor.withValues(alpha: 0.8), // Reduced opacity
                      fadeColor.withValues(alpha: 0.0),
                    ],
                  ),
                ),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Icon(
                      Icons.keyboard_arrow_up,
                      size: 16,
                      color: AppColors.greyText.withValues(alpha: 0.5),
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
            height: 32,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      fadeColor.withValues(
                          alpha: 0.8), // Reduced opacity from 0.95 to 0.8
                      fadeColor.withValues(alpha: 0.0),
                    ],
                  ),
                ),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 2.0),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      size: 16,
                      color: AppColors.greyText.withValues(alpha: 0.5),
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
