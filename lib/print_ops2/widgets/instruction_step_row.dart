import 'package:flutter/material.dart';
import 'package:denik_zza/design_system/tokens/app_spacing.dart';

/// A single instruction step row (bullet point icon + text).
///
/// Used in [AppendInstructionDialog] and [FirstPrint] wizard.
class InstructionStepRow extends StatelessWidget {
  final String text;
  final bool isStrong;

  const InstructionStepRow({
    super.key,
    required this.text,
    this.isStrong = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Icon(
              Icons.circle,
              size: AppSpacing.s,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: Text(
              text,
              style: isStrong
                  ? const TextStyle(fontWeight: FontWeight.bold)
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
