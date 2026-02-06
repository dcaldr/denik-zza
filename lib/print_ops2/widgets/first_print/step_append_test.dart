import 'package:flutter/material.dart';
import 'package:denik_zza/design_system/tokens/app_spacing.dart';
import 'package:denik_zza/print_ops2/widgets/step_helpers.dart';

class FirstPrintStepAppendTest extends StatelessWidget {
  final bool isPrinting;
  final VoidCallback onPrint;
  final Widget navigation;

  const FirstPrintStepAppendTest({
    super.key,
    required this.isPrinting,
    required this.onPrint,
    required this.navigation,
  });

  @override
  Widget build(BuildContext context) {
    return StepContent(
      stepIndex: 5,
      children: [
        const StepHeader(
          icon: Icons.add_to_photos,
          title: 'Test dotisku',
        ),
        const StepSpacing.medium(),
        const Text(
          'Nyní vytiskneme nové záznamy na již vytištěné papíry. '
          'Nové záznamy by se měly objevit pod těmi stávajícími.',
        ),
        const StepSpacing.medium(),
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
                  key: const Key('FirstPrint_append_print'),
                  onPressed: onPrint,
                  icon: const Icon(Icons.print, size: 28),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xxxl,
                      vertical: AppSpacing.l,
                    ),
                  ),
                  label: Text(
                    'Spustit dostisk',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
        ),
        const StepSpacing.medium(),
        const InfoBox(
          icon: Icons.info_outline,
          title: 'Potvrzení tisku',
          content:
              'Po tomto tisku se objeví dialog s potvrzením stavu tisku, ten se bude objevovat po každém tisku aby se záznamy správně označily.\n'
              'Označí se tam co se povedlo a nepovedlo vytisknout, popř. nějaké chyby (chybějící papír apd) lze opakovat tisk, pokud došlo k velké chybě (otočení papíru apd.) lze vše označit, že je třeba začít od začátku',
        ),
        navigation,
      ],
    );
  }
}
