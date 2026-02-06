import 'package:flutter/material.dart';
import 'package:denik_zza/design_system/tokens/app_colors.dart';
import 'package:denik_zza/design_system/tokens/app_spacing.dart';
import 'package:denik_zza/print_ops2/widgets/step_helpers.dart';

class FirstPrintStepConfirmation extends StatelessWidget {
  final VoidCallback onComplete;
  final VoidCallback onBack;

  const FirstPrintStepConfirmation({
    super.key,
    required this.onComplete,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return StepContent(
      stepIndex: 6,
      children: [
        const StepHeader(
          icon: Icons.check_circle,
          title: 'Potvrzení',
        ),
        const StepSpacing.medium(),
        const Text(
          'Zkontrolujte vytištěné papíry. Na každé stránce by měly být '
          'záznamy z obou průchodů.',
        ),
        const StepSpacing.medium(),
        const InfoBox(
          icon: Icons.help_outline,
          title: 'Je vše v pořádku?',
          content:
              'Pokud se nové záznamy vytiskly správně pod těmi původními, je kalibrace dokončena.',
        ),
        const StepSpacing.large(),
        Center(
          child: FilledButton.icon(
            key: const Key('FirstPrint_complete'),
            onPressed: onComplete,
            icon: const Icon(Icons.done_all, size: 28),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xxxl,
                vertical: AppSpacing.l,
              ),
              backgroundColor: AppColors.greenIcon,
            ),
            label: Text(
              'Dokončit nastavení',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),
        const StepSpacing.medium(),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl,
            vertical: AppSpacing.l,
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              key: const Key('FirstPrint_back_final'),
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Zpět'),
            ),
          ),
        ),
      ],
    );
  }
}
