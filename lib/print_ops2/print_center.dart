import 'package:denik_zza/print_ops2/first_print.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'print_center_controller.dart';
import 'print_center_service.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import '../database/in_memory_structures_tmp/memory_osoba.dart';
import 'package:denik_zza/design_system/tokens/app_colors.dart';
import 'package:denik_zza/design_system/tokens/app_radii.dart';
import 'package:denik_zza/services/system/system_interface.dart';
import 'widgets/step_badge.dart';
import 'widgets/print_confirm_dialog.dart';
import '../screens2/widgets/app_drawer.dart';

/// NOVÉ TISK CENTRUM (UI ONLY) -------------------------------------------------
/// Tento modul obsahuje pouze uživatelské rozhraní bez implementované logiky tisku.
/// Cíle:
///  - Zlepšený rozcestník ("Print Center")
///  - Základní flow: Vybrat osobu -> Režim tisku (Úplný / Dostisk) -> Náhled (stub) -> Potvrzení
///  - Vizualizace budoucích funkcí (Historie, Správa stavu, Nastavení, Multi‑page) jako vypnuté prvky
///  - Vše v češtině, jasně označit neimplementované části (ikona zámku + šedé)
///  - Připravit komponenty pro snadné doplnění logiky později

// -----------------------------------------------------------------------------
// MALÉ DOPLŇKOVÉ WIDGETY
// -----------------------------------------------------------------------------

class FeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;
  final bool implemented;
  final bool emphasize;

  const FeatureCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onTap,
    this.implemented = true,
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) {
    final card = Card(
      elevation: emphasize ? 4 : 1,
      color: implemented ? null : AppColors.greyBackground,
      child: InkWell(
        onTap: implemented ? onTap : null,
        borderRadius: AppRadii.buttonRadius,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon,
                  size: 32,
                  color: implemented
                      ? Theme.of(context).colorScheme.primary
                      : AppColors.greyIcon),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color:
                                        implemented ? null : AppColors.greyText,
                                  )),
                        ),
                        if (!implemented)
                          Tooltip(
                            message: 'Funkce zatím není implementována',
                            child: Icon(Icons.lock,
                                size: 18, color: AppColors.greyIcon),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: implemented
                                  ? Theme.of(context).colorScheme.onSurface
                                  : AppColors.greyText,
                            )),
                  ],
                ),
              ),
              if (implemented)
                const Icon(Icons.chevron_right)
              else
                const SizedBox(width: 24),
            ],
          ),
        ),
      ),
    );

    return implemented
        ? card
        : Opacity(
            opacity: 0.75,
            child: AbsorbPointer(child: card),
          );
  }
}


// -----------------------------------------------------------------------------
// HLAVNÍ ROZCESTNÍK
// -----------------------------------------------------------------------------

class PrintCenterPage extends StatelessWidget {
  const PrintCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final c = PrintCenterController(PrintCenterService());
        c.init();
        return c;
      },
      child: Builder(
        builder: (context) => Scaffold(
          drawer: const AppDrawer(),
          appBar: AppBar(title: const Text('Tisk Centrum – Nové')),
          body: Consumer<PrintCenterController>(
            builder: (context, ctrl, _) => ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('Rychlé volby',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                FeatureCard(
                  title: 'Tisk osoby',
                  subtitle: ctrl.loadingParticipants
                      ? 'Načítám účastníky…'
                      : (ctrl.participants.isEmpty
                          ? 'Žádní účastníci v aktuální akci'
                          : 'Vybrat osobu a pokračovat k náhledu. (Úplný / Dostisk)'),
                  icon: Icons.picture_as_pdf,
                  emphasize: true,
                  implemented:
                      !ctrl.loadingParticipants && ctrl.participants.isNotEmpty,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChangeNotifierProvider.value(
                        value: context.read<PrintCenterController>(),
                        child: const PersonAndModeFlowPage(),
                      ),
                    ),
                  ),
                ),
                FeatureCard(
                  title: 'Tisk vybraných',
                  subtitle: ctrl.participants.isEmpty
                      ? 'Žádní účastníci – není co tisknout'
                      : 'Vybrat více osob a vytisknout jejich záznamy v chronologickém sledu (agregace).',
                  icon: Icons.playlist_add_check,
                  implemented: ctrl.participants.isNotEmpty,
                  onTap: ctrl.participants.isEmpty
                      ? null
                      : () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChangeNotifierProvider.value(
                                value: context.read<PrintCenterController>(),
                                child: const SelectedAggregatedPrintPage(),
                              ),
                            ),
                          ),
                ),
                FeatureCard(
                  title: 'Správa stavu',
                  subtitle: 'Ruční označení vytištěných (zatím neaktivní).',
                  icon: Icons.rule_folder,
                  implemented: false,
                ),

                FeatureCard(
                  title: 'Nastavení a průvodce před prvním tiskem',
                  subtitle:
                      'Ověření že vše funguje správně s tiskovým systémem operačního systému a představení dotisku. Nastavení aplikace na fugnování s tiskárnou (pořadí stránek při dotisku)',
                  icon: Icons.remove_red_eye,
                  implemented: true,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FirstPrint()),
                  ),
                ),
                // Multi‑page test do budoucna můžeme obnovit
                const SizedBox(height: 24),
                if (ctrl.participantError != null)
                  _InfoBox(
                    color: Theme.of(context).colorScheme.errorContainer,
                    icon: Icons.error_outline,
                    text: ctrl.participantError!,
                  ),
                const SizedBox(height: 12),
                Text('Stav systému',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  'Tiskový modul je plně aktivní. Generuje PDF pomocí systémového dialogu a zapisuje stav vytištění zpět do databáze.',
                  style: TextStyle(fontSize: 12, color: AppColors.greyText),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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
    if (ctrl.participants.isEmpty) {
      return _InfoBox(
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
                        value: PrintMode.full,
                        title: const Text('Úplný tisk'),
                        subtitle: const Text(
                            'Vygeneruje celý dokument od začátku (reset).'),
                      ),
                      RadioListTile<PrintMode>(
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
                    icon: const Icon(Icons.print),
                    label: const Text('Tisk'),
                    onPressed: () async {
                      Future<void> runPrintCycle() async {
                        try {
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
                  icon: const Icon(Icons.home),
                  label: const Text('Zpět na centrum'),
                  onPressed: () =>
                      Navigator.of(context).popUntil((r) => r.isFirst),
                ),
                OutlinedButton.icon(
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

    switch (result) {
      case PrintSimulationResult.success:
        ctrl.confirmPrintResult(PrintSimulationResult.success);
        break;
      case PrintSimulationResult.repeat:
        ctrl.confirmPrintResult(PrintSimulationResult.repeat);
        break;
      case PrintSimulationResult.noChange:
        ctrl.confirmPrintResult(PrintSimulationResult.noChange);
        break;
      case PrintSimulationResult.reset:
        ctrl.confirmPrintResult(PrintSimulationResult.reset);
        break;
      case PrintSimulationResult.resetAndReprint:
        ctrl.confirmPrintResult(PrintSimulationResult.resetAndReprint);
        onReprint?.call();
        break;
      case null:
        // Dialog dismissed without selection
        break;
    }
  }
}

// --------------------------- Person PDF Preview Pane -------------------------

class _PersonPdfPreviewPane extends StatelessWidget {
  final PrintCenterController controller;
  const _PersonPdfPreviewPane({required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller.selected == null) {
      return _InfoBox(
        color: Theme.of(context).colorScheme.surface,
        icon: Icons.info_outline,
        text: 'Vyberte osobu vlevo…',
      );
    }
    return Card(
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

// --------------------------- Event Print Flow Page ---------------------------

class SelectedAggregatedPrintPage extends StatefulWidget {
  const SelectedAggregatedPrintPage({super.key});

  @override
  State<SelectedAggregatedPrintPage> createState() =>
      _EventPrintFlowPageState();
}

class _EventPrintFlowPageState extends State<SelectedAggregatedPrintPage> {
  final Set<int> _selectedIds = {};
  bool _loadingPdf = false;

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<PrintCenterController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Tisk vybraných – agregace')),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: ctrl.participants.length,
              itemBuilder: (c, i) {
                final p = ctrl.participants[i];
                final sel = _selectedIds.contains(p.id);
                return CheckboxListTile(
                  value: sel,
                  onChanged: (v) {
                    setState(() {
                      if (v == true) {
                        _selectedIds.add(p.id);
                      } else {
                        _selectedIds.remove(p.id);
                      }
                    });
                  },
                  title: Text('${p.jmeno} ${p.prijmeni}'),
                  subtitle: Text(
                      'ID: ${p.id}${p.wasPrinted == true ? ' • už tištěno' : ''}'),
                );
              },
              separatorBuilder: (_, __) => const Divider(height: 1),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Text('Vybráno: ${_selectedIds.length}'),
                const SizedBox(width: 16),
                Text(
                    'Agregovaný tisk: záznamy budou řazeny podle času napříč osobami.',
                    style: TextStyle(fontSize: 12, color: AppColors.greyText)),
                const Spacer(),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: _selectedIds.isEmpty || _loadingPdf
                      ? null
                      : () async {
                          setState(() => _loadingPdf = true);
                          try {
                            if (_selectedIds.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Vyberte alespoň jednoho účastníka k tisku.'),
                                  backgroundColor: AppColors.orangeText,
                                ),
                              );
                              return;
                            }

                            if (context.mounted) {
                              // Real Print execution (via SystemInterface to avoid OS dialogs in tests)
                              await SystemInterface.instance.printPdf(
                                onLayout: (_) => ctrl.generateAggregatedPdf(
                                    _selectedIds.toList()),
                                name:
                                    'Export_Hromadny_${DateTime.now().millisecondsSinceEpoch}',
                              );

                              if (context.mounted) {
                                await _showAggregatedConfirmDialog(
                                    context, ctrl);
                              }
                            }
                          } finally {
                            if (mounted) {
                              setState(() => _loadingPdf = false);
                            }
                          }
                        },
                  icon: const Icon(Icons.print),
                  label: const Text('Vytisknout vybrané'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAggregatedConfirmDialog(
      BuildContext context, PrintCenterController ctrl) async {
    await showDialog(
      context: context,
      barrierDismissible: false, // Force user decision
      builder: (c) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.greenIcon),
            const SizedBox(width: 8),
            const Text('Potvrzení hromadného tisku'),
          ],
        ),
        content: const Text(
          'Pokud se tisk zdařil, potvrďte prosím úspěch.\n\n'
          'Tato akce označí všechny vybrané osoby a jejich záznamy jako vytištěné (wasPrinted/isPrinted = true).',
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(c), // Cancel = no change
            child: const Text('Zrušit (nic neměnit)'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(c);
              await ctrl.confirmAggregatedPrint(_selectedIds.toList());
              if (mounted) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Hromadný tisk potvrzen a uložen.')),
                  );
                }
                // Optional: Clear selection or stay
                setState(() {
                  _selectedIds.clear();
                });
              }
            },
            child: const Text('Potvrdit úspěšný tisk'),
          ),
        ],
      ),
    );
  }
}

class _AppendHintBox extends StatelessWidget {
  final PrintMode mode;
  final bool canAppend;
  const _AppendHintBox({required this.mode, required this.canAppend});

  @override
  Widget build(BuildContext context) {
    if (mode == PrintMode.full) {
      return _InfoBox(
        color: AppColors.blueBackground,
        icon: Icons.info_outline,
        text:
            'Úplný tisk znovu vytiskne vše. Později zde bude možnost resetovat isPrinted příznaky.',
      );
    }
    return _InfoBox(
      color: canAppend ? AppColors.greenBackground : AppColors.orangeBackground,
      icon:
          canAppend ? Icons.check_circle_outline : Icons.warning_amber_outlined,
      text: canAppend
          ? 'Režim Dostisk: Připraveno k tisku nových záznamů.'
          : 'Režim Dostisk: Podmínky nejsou splněny (viz výše).',
    );
  }
}

class _InfoBox extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String text;
  const _InfoBox({required this.color, required this.icon, required this.text});

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

// _PreviewStub removed – replaced with real PdfPreview for person flow

// END -------------------------------------------------------------------------
