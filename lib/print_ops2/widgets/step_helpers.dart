import 'package:flutter/material.dart';

// =============================================================================
// STEP HELPERS - Reusable widgets for multi-step wizards
// =============================================================================

/// Standard step page wrapper with scrolling and padding.
///
/// ## Usage
/// ```dart
/// StepContent(
///   stepIndex: 0,
///   children: [
///     StepHeader(icon: Icons.info, title: 'Welcome'),
///     StepSpacing.medium(),
///     Text('Your content here'),
///   ],
/// )
/// ```
class StepContent extends StatelessWidget {
  final int stepIndex;
  final List<Widget> children;
  
  const StepContent({
    super.key,
    required this.stepIndex,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: SingleChildScrollView(
        key: ValueKey(stepIndex),
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}

/// Step header with icon and title.
class StepHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  
  const StepHeader({
    super.key,
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
      ],
    );
  }
}

/// Highlighted info box with icon, title, and content.
///
/// Used for explanatory notes in wizard steps.
class InfoBox extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  
  const InfoBox({
    super.key,
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(content),
        ],
      ),
    );
  }
}

/// Section title (bold medium text).
class SectionTitle extends StatelessWidget {
  final String text;
  
  const SectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

/// Standard vertical spacing between sections.
///
/// Use named constructors for semantic spacing:
/// - `StepSpacing.small()` - 8px
/// - `StepSpacing.medium()` - 16px
/// - `StepSpacing.large()` - 24px
/// - `StepSpacing.xlarge()` - 32px
class StepSpacing extends StatelessWidget {
  final double size;
  
  const StepSpacing.small({super.key}) : size = 8;
  const StepSpacing.medium({super.key}) : size = 16;
  const StepSpacing.large({super.key}) : size = 24;
  const StepSpacing.xlarge({super.key}) : size = 32;

  @override
  Widget build(BuildContext context) => SizedBox(height: size);
}
