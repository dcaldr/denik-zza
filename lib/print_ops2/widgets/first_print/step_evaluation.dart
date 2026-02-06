import 'package:flutter/material.dart';
import 'package:denik_zza/design_system/tokens/app_colors.dart';
import 'package:denik_zza/design_system/tokens/app_radii.dart';
import 'package:denik_zza/design_system/tokens/app_spacing.dart';
import 'package:denik_zza/print_ops2/widgets/step_helpers.dart';

class FirstPrintStepEvaluation extends StatelessWidget {
  final bool? page1OnTop;
  final ValueChanged<bool> onPage1OnTopChanged;
  final Widget navigation;

  const FirstPrintStepEvaluation({
    super.key,
    required this.page1OnTop,
    required this.onPage1OnTopChanged,
    required this.navigation,
  });

  @override
  Widget build(BuildContext context) {
    return StepContent(
      stepIndex: 3,
      children: [
        const StepHeader(
          icon: Icons.question_answer,
          title: 'Která stránka je navrchu?',
        ),
        const StepSpacing.medium(),
        const Text(
          'Podívejte se na vytištěné papíry ve výstupním zásobníku tiskárny. '
          'Která stránka leží nahoře?',
        ),
        const StepSpacing.medium(),
        Row(
          children: [
            Expanded(
              child: _SelectionCard(
                key: const Key('FirstPrint_page1_on_top'),
                title: 'Stránka 1',
                icon: Icons.looks_one,
                isSelected: page1OnTop == true,
                onTap: () => onPage1OnTopChanged(true),
              ),
            ),
            const SizedBox(width: AppSpacing.l),
            Expanded(
              child: _SelectionCard(
                key: const Key('FirstPrint_page2_on_top'),
                title: 'Stránka 2',
                icon: Icons.looks_two,
                isSelected: page1OnTop == false,
                onTap: () => onPage1OnTopChanged(false),
              ),
            ),
          ],
        ),
        const StepSpacing.medium(),
        navigation,
      ],
    );
  }
}

class _SelectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _SelectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: isSelected ? 4 : 1,
      color: isSelected ? colorScheme.primaryContainer : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.cardRadius,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            children: [
              Icon(
                icon,
                size: 48,
                color: isSelected ? colorScheme.primary : AppColors.greyIcon,
              ),
              const SizedBox(height: AppSpacing.s),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
              ),
              const SizedBox(height: AppSpacing.s),
              Opacity(
                opacity: isSelected ? 1.0 : 0.0,
                child: Icon(Icons.check_circle, color: colorScheme.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
