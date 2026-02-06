import 'package:flutter/material.dart';

import 'package:denik_zza/design_system/tokens/app_spacing.dart';

/// A pure view for displaying append print instructions.
///
/// This widget encapsulates the "Warning -> Steps -> Info" layout
/// so it can be reused in both [AppendInstructionDialog] (popup)
/// and [FirstPrint] (wizard).
class AppendInstructionsView extends StatelessWidget {
  /// The main instruction steps (usually [InstructionStepRow] widgets).
  final List<Widget> steps;

  /// Optional warning message widget (displayed at the top).
  /// E.g. "Printer not calibrated".
  final Widget? warningWidget;

  /// Optional info message widget (displayed at the bottom).
  /// E.g. "Note about transparent pages" or "Why this order matters".
  final Widget? infoWidget;

  const AppendInstructionsView({
    super.key,
    required this.steps,
    this.warningWidget,
    this.infoWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (warningWidget != null) ...[
          warningWidget!,
          const SizedBox(height: AppSpacing.m),
        ],
        Text('Vložte papír do zásobníku:',
            style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: AppSpacing.s),
        ...steps,
        if (infoWidget != null) ...[
          const SizedBox(height: AppSpacing.l),
          infoWidget!,
        ],
      ],
    );
  }
}
