import 'package:flutter/material.dart';
import 'package:denik_zza/print_ops2/widgets/step_helpers.dart';

class FirstPrintStepPreparePaper extends StatelessWidget {
  final Widget navigation;

  const FirstPrintStepPreparePaper({
    super.key,
    required this.navigation,
  });

  @override
  Widget build(BuildContext context) {
    return StepContent(
      stepIndex: 1,
      children: [
        const StepHeader(
          icon: Icons.description_outlined,
          title: 'Příprava testovacích papírů',
        ),
        const StepSpacing.large(),
        const InfoBox(
          icon: Icons.checklist,
          title: 'Co budete potřebovat:',
          content: '• 2 listy čistého papíru (A4)\n'
              '• Tiskárnu připravenou k tisku',
        ),
        const StepSpacing.medium(),
        const SectionTitle('Postup:'),
        const StepSpacing.small(),
        const Text(
          '1. Vložte 2 listy papíru do tiskárny\n'
          '2. V dalším kroku vytiskneme testovací stránky\n'
          '3. Poté zjistíme, která stránka skončila navrchu',
        ),
        const StepSpacing.medium(),
        const InfoBox(
          icon: Icons.visibility_outlined,
          title: 'Na co se zaměřit po tisku:',
          content: 'Po tisku si všimněte, která stránka leží navrchu:\n'
              '• Stránka s číslem 1? Nebo stránka s číslem 2\n'
              '• Papíry ponechte v tiskárně tak jak jsou (bez otáčení, převracení, měnění pořadí)',
        ),
        const StepSpacing.medium(),
        navigation,
      ],
    );
  }
}
