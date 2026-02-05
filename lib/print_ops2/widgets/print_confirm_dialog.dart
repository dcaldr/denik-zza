import 'package:flutter/material.dart';
import 'package:denik_zza/design_system/tokens/app_colors.dart';
import 'package:denik_zza/design_system/tokens/app_radii.dart';
import 'package:denik_zza/print_ops2/print_center_controller.dart';

// Re-export so consumers can use it without extra import
export 'package:denik_zza/print_ops2/print_center_controller.dart' show PrintSimulationResult;

/// Shows the standard print confirmation dialog.
/// 
/// This is used after every print to let user confirm what happened.
/// Returns the user's choice as [PrintSimulationResult].
Future<PrintSimulationResult?> showPrintConfirmDialog({
  required BuildContext context,
  bool? appendActive,
  bool? appendPossible,
  Widget? extraContent,
}) async {
  return showDialog<PrintSimulationResult>(
    context: context,
    barrierDismissible: false,
    builder: (c) => _PrintConfirmDialog(
      appendActive: appendActive,
      appendPossible: appendPossible,
      extraContent: extraContent,
    ),
  );
}

class _PrintConfirmDialog extends StatelessWidget {
  final bool? appendActive;
  final bool? appendPossible;
  final Widget? extraContent;

  const _PrintConfirmDialog({
    this.appendActive,
    this.appendPossible,
    this.extraContent,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Jak dopadl tisk?'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
                'Zvolte hlavní výsledek. Sekce níže obsahuje méně časté případy.'),
            const SizedBox(height: 12),
            // Primary options
            Text('Hlavní volby',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            const ConfirmOptionDescription(
              icon: Icons.check_circle_outline,
              title: 'Vše OK (úspěšný tisk)',
              body:
                  'Označí (v budoucnu) nové záznamy/strany jako vytištěné. Pokud běží režim Dostisk, označí jen ty nové.',
            ),
            const ConfirmOptionDescription(
              icon: Icons.replay_circle_filled_outlined,
              title: 'Zopakovat tisk',
              body:
                  'Nic neoznačí – můžete hned zkusit znovu (např. zaseklá tiskárna).',
            ),
            const SizedBox(height: 16),
            Text('Vedlejší & speciální',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            const ConfirmOptionDescription(
              icon: Icons.remove_done,
              title: 'Neměnit označení',
              body:
                  'Nechá vše tak, jak bylo před tiskem. Vhodné pokud jen testujete náhled nebo čekáte na potvrzení.',
            ),
            const ConfirmOptionDescription(
              icon: Icons.error_outline,
              title: 'Rozbitý tisk (reset)',
              body:
                  'Zruší označení vytištěného stavu (budoucí implementace). Po výběru Reset si ještě zvolíte zda rovnou spustit nový tisk.',
            ),
            const SizedBox(height: 16),
            if (appendActive != null || appendPossible != null)
              AppendInfoBanner(
                appendActive: appendActive ?? false,
                appendPossible: appendPossible,
              ),
            if (extraContent != null) ...[
              const SizedBox(height: 8),
              extraContent!,
            ],
            const SizedBox(height: 8),
            const ManualMarkingNote(),
          ],
        ),
      ),
      actions: [
        TextButton.icon(
          onPressed: () => Navigator.of(context).pop(PrintSimulationResult.noChange),
          icon: const Icon(Icons.remove_done),
          label: const Text('Neměnit'),
        ),
        TextButton.icon(
          onPressed: () async {
            Navigator.of(context).pop();
            final subResult = await showDialog<PrintSimulationResult>(
              context: context,
              builder: (sc) => AlertDialog(
                title: const Text('Reset tisku'),
                content: const Text(
                    'Chcete pouze resetovat stav, nebo resetovat a ihned spustit nový tisk?'),
                actions: [
                  TextButton.icon(
                    onPressed: () => Navigator.of(sc).pop(PrintSimulationResult.reset),
                    icon: const Icon(Icons.restart_alt),
                    label: const Text('Jen reset'),
                  ),
                  FilledButton.icon(
                    onPressed: () => Navigator.of(sc).pop(PrintSimulationResult.resetAndReprint),
                    icon: const Icon(Icons.restart_alt),
                    label: const Text('Reset + znovu'),
                  ),
                ],
              ),
            );
            // Return sub-result to parent if context is still valid
            if (context.mounted && subResult != null) {
              Navigator.of(context).pop(subResult);
            }
          },
          icon: const Icon(Icons.restart_alt),
          label: const Text('Reset'),
        ),
        OutlinedButton.icon(
          onPressed: () => Navigator.of(context).pop(PrintSimulationResult.repeat),
          icon: const Icon(Icons.replay_circle_filled_outlined),
          label: const Text('Zopakovat'),
        ),
        FilledButton.icon(
          onPressed: () => Navigator.of(context).pop(PrintSimulationResult.success),
          icon: const Icon(Icons.check_circle),
          label: const Text('Vše OK'),
        ),
      ],
    );
  }
}

/// Description of a confirmation option with icon, title, and body.
class ConfirmOptionDescription extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  
  const ConfirmOptionDescription({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(body,
                    style: TextStyle(fontSize: 12, color: AppColors.greyText)),
              ],
            ),
          )
        ],
      ),
    );
  }
}

/// Banner showing append mode status.
class AppendInfoBanner extends StatelessWidget {
  final bool appendActive;
  final bool? appendPossible;

  const AppendInfoBanner({
    super.key,
    required this.appendActive,
    this.appendPossible,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bool allowed = appendActive && (appendPossible == true);
    final bool explicitlyBlocked = appendActive && appendPossible == false;
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: allowed
            ? cs.secondaryContainer
            : (explicitlyBlocked
                ? cs.errorContainer
                : cs.surfaceContainerHighest),
        borderRadius: AppRadii.buttonRadius,
        border: Border.all(
            color: allowed
                ? cs.secondary
                : (explicitlyBlocked ? cs.error : cs.outlineVariant)),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(appendActive ? Icons.layers : Icons.layers_clear,
              color: allowed
                  ? cs.onSecondaryContainer
                  : (explicitlyBlocked
                      ? cs.onErrorContainer
                      : cs.onSurfaceVariant)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Režim Dostisk',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                if (!appendActive)
                  const Text(
                      'Aktuálně tisknete celý obsah. To je v pořádku – tím vytváříte referenční stav, aby pozdější Dostisk mohl bezpečně vytisknout jen nové záznamy. Přepněte na Dostisk jen pokud nyní opravdu doplňujete předchozí tisk.',
                      style: TextStyle(fontSize: 12))
                else if (allowed)
                  const Text(
                      'Režim Dostisk: vytisknou se pouze nové záznamy od posledního plného tisku. Tím zachováte čistou historii a připravíte půdu pro další budoucí dostisky.',
                      style: TextStyle(fontSize: 12))
                else if (explicitlyBlocked)
                  const Text(
                      'Dostisk teď nelze – nepřibyly nové záznamy, nebo sledované pořadí už není konzistentní. Pro opětovné využití dostisku udělejte nejprve plný tisk.',
                      style: TextStyle(fontSize: 12))
                else
                  const Text(
                      'Kontroluji podmínky pro Dostisk (pořadí a nové záznamy)…',
                      style: TextStyle(fontSize: 12)),
              ],
            ),
          )
        ],
      ),
    );
  }
}

/// Note about manual marking.
class ManualMarkingNote extends StatelessWidget {
  const ManualMarkingNote({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Tip: Ruční označení je možné v detailu osoby.',
      style: TextStyle(fontSize: 11, color: AppColors.greyText),
    );
  }
}
