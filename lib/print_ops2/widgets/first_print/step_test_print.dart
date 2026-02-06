import 'package:flutter/material.dart';
import 'package:denik_zza/design_system/tokens/app_spacing.dart';
import 'package:denik_zza/print_ops2/widgets/step_helpers.dart';

class FirstPrintStepTestPrint extends StatelessWidget {
  final bool isPrinting;
  final VoidCallback onPrint;
  final Widget navigation;

  const FirstPrintStepTestPrint({
    super.key,
    required this.isPrinting,
    required this.onPrint,
    required this.navigation,
  });

  @override
  Widget build(BuildContext context) {
    return StepContent(
      stepIndex: 2,
      children: [
        const StepHeader(
          icon: Icons.print,
          title: 'Testovací tisk',
        ),
        const StepSpacing.medium(),
        const Text(
          'Nyní vytiskneme 2 testovací stránky. Je potřeba zvolit skutečnou tiskárnu, která bude na akci používána (i když nejspíše se nabídne tisk do PDF). Pro zvládnutí samotného tisku se spustí nové okno operačního systému nikoli této aplikace.\n'
          '• Stránka 1 – s nadpisem "TESTOVACÍ STRÁNKA 1"\n'
          '• Stránka 2 – s nadpisem "TESTOVACÍ STRÁNKA 2"\n'
          'Obě stránky budou mít ukázkové záznamy podobné skutečným.',
        ),
        const StepSpacing.large(),
        Center(
          child: isPrinting
              ? const Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: AppSpacing.s),
                    Text('Tisknu...'),
                  ],
                )
              : FilledButton.icon(
                  key: const Key('FirstPrint_initial_print'),
                  onPressed: onPrint,
                  icon: const Icon(Icons.print, size: 28),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xxxl,
                      vertical: AppSpacing.l,
                    ),
                  ),
                  label: Text(
                    'Spustit testovací tisk',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
        ),
        const StepSpacing.large(),
        const InfoBox(
          icon: Icons.warning_amber,
          title: 'Po vytištění:',
          content:
              'Neodebírejte papíry z výstupního zásobníku!\nBudeme je potřebovat pro další kroky.',
        ),
        const StepSpacing.medium(),
        navigation,
      ],
    );
  }
}
