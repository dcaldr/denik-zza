import 'package:flutter/material.dart';
import 'package:denik_zza/design_system/tokens/app_colors.dart';
import 'package:denik_zza/design_system/tokens/app_radii.dart';
import 'package:denik_zza/design_system/tokens/app_spacing.dart';
import 'package:denik_zza/print_ops2/widgets/append_instructions_view.dart';
import 'package:denik_zza/print_ops2/widgets/instruction_step_row.dart';
import 'package:denik_zza/print_ops2/widgets/step_helpers.dart';

class FirstPrintStepReinsertPaper extends StatelessWidget {
  final bool isNormalOrder;
  final Widget navigation;

  const FirstPrintStepReinsertPaper({
    super.key,
    required this.isNormalOrder,
    required this.navigation,
  });

  @override
  Widget build(BuildContext context) {
    return StepContent(
      stepIndex: 4,
      children: [
        const StepHeader(
          icon: Icons.school,
          title: 'Co vás čeká?',
        ),
        const StepSpacing.medium(),
        const Text(
          'V dalším kroku simulujeme reálný tisk. Až kliknete na "Spustit dostisk", uvidíte postupně dvě okna:',
        ),
        const StepSpacing.medium(),
        const SectionTitle('1. Instrukce pro vložení papíru'),
        const SizedBox(height: AppSpacing.s),
        Container(
          padding: const EdgeInsets.all(AppSpacing.m),
          decoration: BoxDecoration(
            color: AppColors.greyBackground.withValues(alpha: 0.5),
            border: Border.all(color: AppColors.greyBorder),
            borderRadius: AppRadii.cardRadius,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'UKÁZKA:',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.greyText,
                    ),
              ),
              const SizedBox(height: AppSpacing.s),
              AppendInstructionsView(
                steps: [
                  InstructionStepRow(
                    text:
                        isNormalOrder ? 'Nahoře stránka 1' : 'Nahoře stránka 2',
                    isStrong: true,
                  ),
                  InstructionStepRow(
                    text:
                        isNormalOrder ? 'Pod ní stránka 2' : 'Pod ní stránka 1',
                    isStrong: true,
                  ),
                ],
                infoWidget: Container(
                  padding: const EdgeInsets.all(AppSpacing.s),
                  decoration: BoxDecoration(
                    color: AppColors.blueBackground,
                    borderRadius: BorderRadius.circular(AppRadii.small),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          size: 16, color: AppColors.blueText),
                      const SizedBox(width: AppSpacing.s),
                      Expanded(
                        child: Text(
                          isNormalOrder
                              ? 'Vložte podle čísel vzestupně (1 nahoře).'
                              : 'Vložte podle čísel sestupně (2 nahoře).',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.blueText,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const StepSpacing.medium(),
        const SectionTitle('2. Potvrzení výsledku'),
        const SizedBox(height: AppSpacing.s),
        const Text(
          'Po vytištění se objeví dialog s otázkou "Jak dopadl tisk?". '
          'Tento dialog slouží k tomu, aby aplikace věděla, zda se tisk podařil, nebo zda došlo k chybě (např. zaseknutý papír) a je třeba jej opakovat.',
        ),
        const StepSpacing.medium(),
        const InfoBox(
          icon: Icons.visibility,
          title: 'Proč dvě okna?',
          content:
              'Každý tisk je dvoufázový: nejdříve příprava (vložení papíru) a pak kontrola (jestli se to povedlo).',
        ),
        const StepSpacing.medium(),
        navigation,
      ],
    );
  }
}
