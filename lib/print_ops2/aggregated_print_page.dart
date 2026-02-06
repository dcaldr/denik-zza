import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:denik_zza/design_system/tokens/app_colors.dart';
import 'package:denik_zza/services/system/system_interface.dart';
import 'print_center_controller.dart';

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
                  key: Key('Aggregated_participant_${p.id}'),
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
                  key: const Key('Aggregated_printButton'),
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
