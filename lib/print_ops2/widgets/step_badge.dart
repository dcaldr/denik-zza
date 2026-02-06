import 'package:flutter/material.dart';
import 'package:denik_zza/design_system/tokens/app_colors.dart';
import 'package:denik_zza/design_system/tokens/app_radii.dart';
import 'package:denik_zza/design_system/tokens/app_spacing.dart';

// =============================================================================
// STEP BADGE - Individual step indicator
// =============================================================================

/// A badge widget that shows step progress state (pending/active/done).
/// 
/// Used in multi-step wizards to show the current progress.
class StepBadge extends StatelessWidget {
  final String text;
  final bool active;
  final bool done;
  
  const StepBadge({
    super.key,
    required this.text,
    this.active = false,
    this.done = false,
  });

  @override
  Widget build(BuildContext context) {
    Color base;
    if (active) {
      base = Theme.of(context).colorScheme.primary;
    } else if (done) {
      base = AppColors.greenIcon;
    } else {
      base = AppColors.greyTextLight;
    }
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s,
        vertical: AppSpacing.xs,
      ),
      margin: const EdgeInsets.only(
        right: AppSpacing.s,
        bottom: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: base.withValues(alpha: active ? 0.18 : 0.12),
        borderRadius: AppRadii.pillRadius,
        border: Border.all(color: base),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (done)
            Icon(Icons.check, size: AppSpacing.m, color: AppColors.greenIcon),
          if (done) const SizedBox(width: AppSpacing.xs),
          Text(
            text,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: base.darken(0.2),
                ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// STEP BADGE ROW - Horizontal scrollable row of step badges
// =============================================================================

/// A horizontal scrollable row of step badges with automatic active/done states.
/// 
/// Generates numbered step badges from a list of labels and highlights the
/// current step based on [currentStep] index.
class StepBadgeRow extends StatelessWidget {
  final List<String> stepLabels;
  final int currentStep;

  const StepBadgeRow({
    super.key,
    required this.stepLabels,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: stepLabels.asMap().entries.map((e) => StepBadge(
          key: ValueKey('StepBadge_${e.key}'),
          text: '${e.key + 1} ${e.value}',
          active: currentStep == e.key,
          done: currentStep > e.key,
        )).toList(),
      ),
    );
  }
}
