import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import 'package:denik_zza/database/database_wrapper.dart';
import 'package:denik_zza/design_system/tokens/app_spacing.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_zaznam.dart';
import 'package:denik_zza/screens2/services/participant_service.dart';
import 'package:denik_zza/print_ops2/person_mode_flow_page.dart';
import 'package:denik_zza/print_ops2/print_center_controller.dart';
import 'package:denik_zza/print_ops2/print_center_service.dart';

import 'package:denik_zza/screens2/new_record/new_record_page.dart';
import 'participant_edit_page.dart';

class ParticipantDetailPage extends StatefulWidget {
  final MemoryOsoba participant;

  const ParticipantDetailPage({super.key, required this.participant});

  @override
  State<ParticipantDetailPage> createState() => _ParticipantDetailPageState();
}

class _ParticipantDetailPageState extends State<ParticipantDetailPage> {
  final ParticipantService _participantService = ParticipantService();
  List<MemoryZaznam> _records = [];
  bool _isLoading = false;
  bool _isParticipantValid = true;

  @override
  void initState() {
    super.initState();
    // Validate participant exists in current event before allowing actions
    _validateParticipantInCurrentEvent();
  }

  Future<void> _validateParticipantInCurrentEvent() async {
    try {
      final db = DatabaseWrapper.getDatabase();
      final participants = await db.getParticipantsByCurrentEvent();
      final isValid = participants
          .any((participant) => participant.id == widget.participant.id);
      if (!mounted) return;
      setState(() {
        _isParticipantValid = isValid;
      });
      if (isValid) {
        _fetchRecords();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isParticipantValid = false;
      });
    }
  }

  Future<void> _fetchRecords() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final records = await _participantService
          .getParticipantRecords(widget.participant.id);
      setState(() {
        _records = records;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      // Handle error if needed
    }
  }

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold(
      appBar: AppBar(
        title:
            Text('${widget.participant.jmeno} ${widget.participant.prijmeni}'),
        actions: [
          if (_isParticipantValid)
            IconButton(
              key: const Key('ParticipantDetail_edit_button'),
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        ParticipantEditPage(participant: widget.participant),
                  ),
                );
                // If participant was edited, refresh the data
                if (result == true && context.mounted) {
                  _fetchRecords(); // This also refreshes participant data
                }
              },
            ),
        ],
      ),
      body: Padding(
        padding: AppSpacing.screenPadding,
        child: ListView(
          key: const Key('ParticipantDetail_scroll_list'),
          children: [
            _buildInfoCard('Osobní údaje', [
              _buildInfoRow('Datum narození:',
                  '${widget.participant.datumNarozeni?.day.toString().padLeft(2, '0')}.${widget.participant.datumNarozeni?.month.toString().padLeft(2, '0')}.${widget.participant.datumNarozeni?.year}'), //TODO: TD2
              _buildInfoRow(
                  'Pohlaví:',
                  widget.participant.pohlavi == MemoryOsoba.POHLAVI_MUZ
                      ? 'Muž'
                      : 'Žena'),
              _buildInfoRow('Adresa:', widget.participant.adresa ?? 'N/A'),
            ]),
            _buildInfoCard('Pojišťovací údaje', [
              _buildInfoRow('Pojišťovna:',
                  widget.participant.zdravotniPojistovna ?? 'N/A'),
              _buildInfoRow(
                  'Rodné číslo:', widget.participant.cisloPojisteni ?? 'N/A'),
            ]),
            _buildInfoCard('Potvrzení', [
              _buildInfoRow('Bezinfekčnost:',
                  widget.participant.bezinfekcnost == true ? 'Ano' : 'Ne'),
              _buildInfoRow('Způsobilost:',
                  widget.participant.zpusobilost == true ? 'Ano' : 'Ne'),
            ]),
            AppSpacing.mediumGap,
            Text(
              'Lékařské záznamy',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            _buildMedicalRecords(),
            AppSpacing.mediumGap,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FilledButton.icon(
                  key: const Key('ParticipantDetail_newRecord_button'),
                  onPressed: _isParticipantValid
                      ? () async {
                          final result = await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  NewRecordPage(participant: widget.participant),
                            ),
                          );
                          // If a record was added, refresh the records list
                          if (result == true && context.mounted) {
                            _fetchRecords();
                          }
                        }
                      : null,
                  icon: const Icon(Icons.add),
                  label: const Text('Nový záznam'),
                ),
                FilledButton.icon(
                  key: const Key('ParticipantDetail_print_button'),
                  onPressed: _isParticipantValid
                      ? () async {
                          // Navigate to modern print system
                          final service = PrintCenterService();
                          final controller = PrintCenterController(service);
                          controller.init();
                          if (context.mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChangeNotifierProvider.value(
                                  value: controller,
                                  child: PersonAndModeFlowPage(
                                    initialParticipant: widget.participant,
                                  ),
                                ),
                              ),
                            );
                          }
                        }
                      : null,
                  icon: const Icon(Icons.print),
                  label: const Text('Tisknout záznamy'),
                ),
              ],
            )
          ],
        ),
      ),
    );
    return scaffold;
  }

  Widget _buildMedicalRecords() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_records.isEmpty) {
      return const Card(
        child: ListTile(
          title: Text('Zatím žádné lékařské záznamy.'),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _records.length,
      itemBuilder: (context, index) {
        final record = _records[index];
        return Card(
          child: ListTile(
            title: Text(record.nazev ?? 'Bez názvu'),
            subtitle: Text(record.popis ?? 'Bez popisu'),
            trailing: record.casZaznamu != null
                ? Text(
                    '${record.casZaznamu!.day}.${record.casZaznamu!.month}.${record.casZaznamu!.year}')
                : const Text('Neznámé datum'),
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: AppSpacing.containerPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            AppSpacing.smallGap,
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
