import 'package:flutter/material.dart';
import 'package:denik_zza/design_system/tokens/app_colors.dart';

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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Icon(Icons.circle, size: 8, color: AppColors.primary),
          ),
          const SizedBox(width: 8),
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
