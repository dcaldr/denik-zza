import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:denik_zza/design_system/tokens/app_colors.dart';
import 'package:denik_zza/design_system/tokens/app_radii.dart';
import 'package:denik_zza/services/system/system_interface.dart';
import 'package:denik_zza/print_ops2/widgets/step_badge.dart';
import 'package:denik_zza/print_ops2/widgets/print_confirm_dialog.dart';
import 'package:denik_zza/print_ops2/widgets/append_instruction_dialog.dart';
import 'package:denik_zza/print_ops2/print_center_controller.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';

// -----------------------------------------------------------------------------
// FLOW: OSOBNÍ TISK (VÝBĚR OSOBY -> REŽIM -> NÁHLED -> POTVRZENÍ)
// -----------------------------------------------------------------------------

class PersonAndModeFlowPage extends StatefulWidget {
  final MemoryOsoba? initialParticipant;
  final PrintMode? initialMode;

  const PersonAndModeFlowPage({
    super.key,
    this.initialParticipant,
    this.initialMode,
  });

  @override
  State<PersonAndModeFlowPage> createState() => _PersonAndModeFlowPageState();
}

class _PersonAndModeFlowPageState extends State<PersonAndModeFlowPage> {
  @override
  void initState() {
    super.initState();
    // Auto-select participant and mode if provided
    if (widget.initialParticipant != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ctrl = context.read<PrintCenterController>();
        ctrl.selectParticipant(widget.initialParticipant!);
        if (widget.initialMode != null) {
          ctrl.changeMode(widget.initialMode!);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<PrintCenterController>();
    final steps = [
      StepBadge(
          text: '1 Osoba',
          active: ctrl.selected == null,
          done: ctrl.selected != null),
      StepBadge(
          text: '2 Režim',
          active: ctrl.selected != null && !ctrl.simulatedPrinted,
          done: ctrl.simulatedPrinted),
      StepBadge(
          text: '3 Náhled',
          active: ctrl.selected != null && !ctrl.simulatedPrinted),
      StepBadge(text: '4 Potvrzení', active: ctrl.simulatedPrinted),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Tisk osoby – krokový průvodce')),
      body: Column(
        children: [
          // Steps row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(children: steps),
          ),
          const Divider(height: 1),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _buildStage(context, ctrl),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStage(BuildContext context, PrintCenterController ctrl) {
    if (ctrl.selected == null) return _buildSelectPerson(context, ctrl);
    if (!ctrl.simulatedPrinted) return _buildModeAndPreview(context, ctrl);
    return _buildPostConfirmation(context, ctrl);
  }

  Widget _buildSelectPerson(BuildContext context, PrintCenterController ctrl) {
    if (ctrl.loadingParticipants) {
      return const Center(child: CircularProgressIndicator());
    }
    
    print('=== DEBUG UI _buildSelectPerson: Rendering list. Participants count: ${ctrl.participants.length} ===');
    for (var p in ctrl.participants) {
      print('=== DEBUG UI _buildSelectPerson Participant: "${p.jmeno} ${p.prijmeni}" ===');
    }

    if (ctrl.participants.isEmpty) {
      return ModeFlowInfoBox(
        color: AppColors.orangeBackground,
        icon: Icons.warning_amber,
        text: 'Žádní účastníci\nNejsou k dispozici žádní účastníci pro tisk. '
            'Nejprve importujte nebo přidejte účastníky.',
      );
    }
    return ListView.separated(
      key: const ValueKey('select-person'),
      padding: const EdgeInsets.all(8),
      itemBuilder: (c, i) {
        final p = ctrl.participants[i];
        return ListTile(
          key: Key('PersonMode_select_${p.id}'),
          leading: CircleAvatar(child: Text(p.jmeno.substring(0, 1))),
          title: Text('${p.jmeno} ${p.prijmeni}'),
          subtitle: Text(p.poznamka ?? ''),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => ctrl.selectParticipant(p),
        );
      },
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemCount: ctrl.participants.length,
    );
  }

  Widget _buildModeAndPreview(
      BuildContext context, PrintCenterController ctrl) {
    // Removed placeholder logic usage
    return LayoutBuilder(
      key: const ValueKey('mode-preview'),
      builder: (context, constraints) {
        final vertical = constraints.maxWidth < 700;
        final left = Expanded(
          flex: 3,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Osoba', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Card(
                  child: ListTile(
                    title: Text(
                        '${ctrl.selected!.jmeno} ${ctrl.selected!.prijmeni}'),
                    subtitle: Text('ID: ${ctrl.selected!.id} – databáze'),
                    trailing: TextButton.icon(
                      key: const Key('PersonMode_changePerson'),
                      onPressed: () => ctrl.resetFlow(),
                      icon: const Icon(Icons.swap_horiz),
                      label: const Text('Změnit'),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Režim tisku',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                RadioGroup<PrintMode>(
                  groupValue: ctrl.mode,
                  onChanged: (v) {
                    if (v != null) ctrl.changeMode(v);
                  },
                  child: Column(
                    children: [
                      RadioListTile<PrintMode>(
                        key: const Key('PersonMode_fullPrint'),
                        value: PrintMode.full,
                        title: const Text('Úplný tisk'),
                        subtitle: const Text(
                            'Vygeneruje celý dokument od začátku (reset).'),
                      ),
                      RadioListTile<PrintMode>(
                        key: const Key('PersonMode_appendPrint'),
                        value: PrintMode.append,
                        title: Row(
                          children: const [
                            Text('Dostisk (append)'),
                            SizedBox(width: 6),
                            Tooltip(
                                message:
                                    'Pouze nové záznamy, ostatní průhledně',
                                child: Icon(Icons.info_outline, size: 16)),
                          ],
                        ),
                        subtitle: _appendSubtitle(ctrl),
                        secondary: (ctrl.appendPossible == false)
                            ? Tooltip(
                                message:
                                    'Nelze použít – pořadí nebo stav neumožňuje dostisk',
                                child: Icon(Icons.block,
                                    color: AppColors.greyIcon))
                            : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _AppendHintBox(
                    mode: ctrl.mode, canAppend: ctrl.appendPossible ?? false),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    key: const Key('PersonMode_printButton'),
                    icon: const Icon(Icons.print),
                    label: const Text('Tisk'),
                    onPressed: () async {
                      Future<void> runPrintCycle() async {
                        try {
                          // Append Instruction Dialog
                          if (ctrl.mode == PrintMode.append) {
                            final proceed = await showDialog<bool>(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) =>
                                  AppendInstructionDialog(controller: ctrl),
                            );

                            if (proceed != true) return;
                          }

                          await SystemInterface.instance.printPdf(
                            onLayout: (_) => ctrl.generateCurrentPdf(),
                            name: 'Osoba_${ctrl.selected?.id ?? "export"}',
                          );
                          if (context.mounted) {
                            await _showConfirmDialog(context, ctrl,
                                onReprint: runPrintCycle);
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Chyba tisku: $e')),
                            );
                          }
                        }
                      }

                      await runPrintCycle();
                    },
                  ),
                ),
              ],
            ),
          ),
        );

        final right = Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: _PersonPdfPreviewPane(controller: ctrl),
          ),
        );

        if (vertical) {
          return Column(
            children: [left, right],
          );
        }
        return Row(children: [left, right]);
      },
    );
  }

  Widget _appendSubtitle(PrintCenterController ctrl) {
    if (ctrl.appendChecking) {
      return const Text('Ověřuji podmínky…');
    }
    if (ctrl.appendError != null) {
      return Text('Chyba: ${ctrl.appendError}',
          style: TextStyle(color: Theme.of(context).colorScheme.error));
    }
    if (ctrl.appendPossible != null) {
      return Text(ctrl.appendPossible!
          ? 'Append je možný (validováno).'
          : 'Append není možný.');
    }
    // No validation result yet
    return const Text('Čekám na validaci…');
  }

  Widget _buildPostConfirmation(
      BuildContext context, PrintCenterController ctrl) {
    return Center(
      key: const ValueKey('post-confirm'),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: AppColors.greenIcon, size: 64),
            const SizedBox(height: 16),
            Text('Tisk dokončen?',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Text(
              'Pokud se tisk zdařil, potvrďte prosím úspěch v dialogu.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.greyText),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              children: [
                FilledButton.icon(
                  key: const Key('PersonMode_backToCenter'),
                  icon: const Icon(Icons.home),
                  label: const Text('Zpět na centrum'),
                  onPressed: () =>
                      Navigator.of(context).popUntil((r) => r.isFirst),
                ),
                OutlinedButton.icon(
                  key: const Key('PersonMode_newPrint'),
                  icon: const Icon(Icons.replay),
                  label: const Text('Nový tisk'),
                  onPressed: () => ctrl.resetFlow(),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<void> _showConfirmDialog(
      BuildContext context, PrintCenterController ctrl,
      {VoidCallback? onReprint}) async {
    final result = await showPrintConfirmDialog(
      context: context,
      appendActive: ctrl.mode == PrintMode.append,
      appendPossible: ctrl.appendPossible,
    );

    if (result == null) return;
    await ctrl.confirmPrintResult(result);
    if (result == PrintSimulationResult.resetAndReprint) onReprint?.call();
  }
}

// --------------------------- Person PDF Preview Pane -------------------------

class _PersonPdfPreviewPane extends StatelessWidget {
  final PrintCenterController controller;
  const _PersonPdfPreviewPane({required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller.selected == null) {
      return ModeFlowInfoBox(
        color: Theme.of(context).colorScheme.surface,
        icon: Icons.info_outline,
        text: 'Vyberte osobu vlevo…',
      );
    }
    return Card(
      key: const Key('PersonMode_pdfPreview'),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: .1),
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4), topRight: Radius.circular(4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.picture_as_pdf),
                const SizedBox(width: 8),
                Text('Náhled PDF',
                    style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                if (controller.appendChecking)
                  const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2)),
                if (!controller.appendChecking &&
                    controller.appendPossible == true)
                  Icon(Icons.check_circle,
                      color: AppColors.greenIcon, size: 18),
                if (!controller.appendChecking &&
                    controller.appendPossible == false)
                  Icon(Icons.block,
                      color: Theme.of(context).colorScheme.error, size: 18),
              ],
            ),
          ),
          Expanded(
            child: PdfPreview(
              build: (format) => controller.generateCurrentPdf(),
              initialPageFormat: PdfPageFormat.a4,
              maxPageWidth: 600,
              canChangeOrientation: false,
              canChangePageFormat: false,
              pdfFileName: 'osoba_${controller.selected!.id}.pdf',
            ),
          ),
        ],
      ),
    );
  }
}

// --------------------------- Append Hint Box ---------------------------------

class _AppendHintBox extends StatelessWidget {
  final PrintMode mode;
  final bool canAppend;
  const _AppendHintBox({required this.mode, required this.canAppend});

  @override
  Widget build(BuildContext context) {
    if (mode == PrintMode.full) {
      return ModeFlowInfoBox(
        color: AppColors.blueBackground,
        icon: Icons.info_outline,
        text:
            'Úplný tisk znovu vytiskne vše. Později zde bude možnost resetovat isPrinted příznaky.',
      );
    }
    return ModeFlowInfoBox(
      color: canAppend ? AppColors.greenBackground : AppColors.orangeBackground,
      icon:
          canAppend ? Icons.check_circle_outline : Icons.warning_amber_outlined,
      text: canAppend
          ? 'Režim Dostisk: Připraveno k tisku nových záznamů.'
          : 'Režim Dostisk: Podmínky nejsou splněny (viz výše).',
    );
  }
}

// --------------------------- Info Box ----------------------------------------

class ModeFlowInfoBox extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String text;
  const ModeFlowInfoBox({
    super.key,
    required this.color,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppRadii.buttonRadius,
        border: Border.all(color: color.darken(0.1)),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.greyText),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
