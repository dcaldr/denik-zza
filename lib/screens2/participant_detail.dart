import 'package:flutter/material.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_zaznam.dart';
import 'package:denik_zza/screens2/state/participant_notifier.dart';
import 'package:provider/provider.dart';
import 'package:denik_zza/print_ops/confirm_print.dart';
import 'package:denik_zza/print_ops/printer_woodoo.dart';

import 'new_record_page.dart';

class ParticipantDetailPage extends StatefulWidget {
  final MemoryOsoba participant;

  const ParticipantDetailPage({super.key, required this.participant});

  @override
  State<ParticipantDetailPage> createState() => _ParticipantDetailPageState();
}

class _ParticipantDetailPageState extends State<ParticipantDetailPage> {
  @override
  void initState() {
    super.initState();
    // Fetch records when the widget is initialized
    Provider.of<ParticipantNotifier>(context, listen: false)
        .fetchRecords(widget.participant.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.participant.jmeno} ${widget.participant.prijmeni}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Implement edit functionality
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildInfoCard('Personal Information', [
              _buildInfoRow('Datum Narození:', '${widget.participant.datumNarozeni?.day.toString().padLeft(2, '0')}.${widget.participant.datumNarozeni?.month.toString().padLeft(2, '0')}.${widget.participant.datumNarozeni?.year}'), //TODO: TD2
              _buildInfoRow('Pohlaví:', widget.participant.pohlavi == 1 ? 'Muž' : 'Žena'),
              _buildInfoRow('Adresa:', widget.participant.adresa ?? 'N/A'),
            ]),
            _buildInfoCard('Insurance Information', [
              _buildInfoRow('Pojišťovna:', widget.participant.zdravotniPojistovna ?? 'N/A'),
              _buildInfoRow('Rodné číslo:', widget.participant.cisloPojisteni ?? 'N/A'),
            ]),
            _buildInfoCard('Confirmations', [
                _buildInfoRow('Bezinfekčnost:', widget.participant.bezinfekcnost == true ? 'Ano' : 'Ne'),
                _buildInfoRow('Způsobilost:', widget.participant.zpusobilost == true ? 'Ano' : 'Ne'),
            ]),
            const SizedBox(height: 16),
            Text(
              'Medical Records',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            _buildMedicalRecords(),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => NewRecordPage(participant: widget.participant),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('New Record'),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    // TODO: This should be moved to a service/controller
                    final woodoo = PrinterWoodoo();
                    final packedPdf = await woodoo.printSelected([widget.participant]);
                    ConfirmPrint().showConfirmPrintDialog(context, packedPdf);
                  },
                  icon: const Icon(Icons.print),
                  label: const Text('Print Record'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMedicalRecords() {
    return Consumer<ParticipantNotifier>(
      builder: (context, notifier, child) {
        if (notifier.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (notifier.records.isEmpty) {
          return const Card(
            child: ListTile(
              title: Text('No medical records yet.'),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: notifier.records.length,
          itemBuilder: (context, index) {
            final record = notifier.records[index];
            return Card(
child: ListTile(
                title: Text(record.nazev ?? 'Bez názvu'),
                subtitle: Text(record.popis ?? 'Bez popisu'),
                trailing: record.casZaznamu != null
                    ? Text('${record.casZaznamu!.day}.${record.casZaznamu!.month}.${record.casZaznamu!.year}')
                    : const Text('Neznámé datum'),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
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
