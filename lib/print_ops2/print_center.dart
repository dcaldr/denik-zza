import 'package:denik_zza/print_ops2/first_print.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'print_center_controller.dart';
import 'print_center_service.dart';
import 'package:denik_zza/design_system/tokens/app_colors.dart';
import 'package:denik_zza/print_ops2/widgets/feature_card.dart';
import 'package:denik_zza/print_ops2/person_mode_flow_page.dart';
import 'package:denik_zza/print_ops2/aggregated_print_page.dart';
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
                  InfoBox(
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

// END -------------------------------------------------------------------------
