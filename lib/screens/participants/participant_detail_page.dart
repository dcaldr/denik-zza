import 'package:denik_zza/database/database_interface.dart';
import 'package:denik_zza/database/database_wrapper.dart';
import 'package:denik_zza/print_ops/printer_woodoo.dart';
import 'package:denik_zza/screens/records/new_record_page.dart';
import 'package:denik_zza/screens/records/record_detail_page.dart';
import 'package:flutter/material.dart';

import '../../database/in_memory_structures_tmp/memory_osoba.dart';
import '../../database/in_memory_structures_tmp/memory_zaznam.dart';
import '../../print_ops/confirm_print.dart';
import '../../print_ops/zraneni_list_view.dart';

/// Displays detailed information about a participant including personal details and health records.
class ParticipantDetailPage extends StatelessWidget {
  final MemoryOsoba ucastnik;

  /// Constructor for the ParticipantDetailPage class.
  ParticipantDetailPage({required this.ucastnik, super.key});

  @override
  Widget build(BuildContext context) {
    DatabaseInterface db = DatabaseWrapper.getDatabase();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Účastníka'),
        actions: const [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: null,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 0),
            Text(
              '${ucastnik.jmeno} ${ucastnik.prijmeni}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            // Bubbles with participant information
            Expanded(
              child: ListView(
                children: [
                  InfoBubble(label: 'Datum Narození', value: '${ucastnik.datumNarozeni?.day.toString().padLeft(2, '0')}.${ucastnik.datumNarozeni?.month.toString().padLeft(2, '0')}.${ucastnik.datumNarozeni?.year}' ?? 'N/A'),
                  InfoBubble(label: 'Pohlaví', value: ucastnik.pohlavi == 1 ? 'Muž' : 'Žena'),
                  InfoBubble(label: 'Pojišťovna', value: ucastnik.zdravotniPojistovna ?? 'N/A'),
                  InfoBubble(label: 'Rodné číslo', value: ucastnik.cisloPojisteni ?? 'N/A'),
                  InfoBubble(label: 'Adresa', value: ucastnik.adresa ?? 'N/A'),
                  InfoBubble(label: 'Bezinfekčnost', value: ucastnik.bezinfekcnost == true ? 'Ano' : 'Ne'),
                  InfoBubble(label: 'Způsobilost', value: ucastnik.zpusobilost == true ? 'Ano' : 'Ne'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Záznam o nemoci section
            const Text(
              'Záznam o Nemoci/Ošetření',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                // Buttons for new record and printing
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => NewRecordPage( osoba: ucastnik,)),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.black,
                    onPrimary: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 25,
                    ),
                  ),
                  child: const Text(
                    'Nový Záznam',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async { //todo check efficiency
                    PrinterWoodoo woodoo = PrinterWoodoo();
                    PrintPack packedPdf;
                    if(ucastnik.wasPrinted!){
                    packedPdf = await woodoo.appendPrintOne(ucastnik);
                    }else{
                    packedPdf= await woodoo.printSelected([ucastnik]);
                      }
                    ConfirmPrint().showConfirmPrintDialog(context,packedPdf);
                  },
                  style: ElevatedButton.styleFrom(
                    primary: const Color.fromARGB(255, 255, 251, 245),
                    onPrimary: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 25,
                    ),
                  ),
                  child: const Text(
                    'Tisk Záznamu',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // List of previous records
            Expanded(
              child: FullZraneniList(databaze: db, osoba: ucastnik),
            ),
          ],
        ),
      ),
    );
  }
}

/// List of all ijuries.
///
/// TODO: ref somewhere else.
class FullZraneniList extends StatelessWidget {
  const FullZraneniList({
    super.key,
    required this.databaze,
    required this.osoba,
  });

  final DatabaseInterface databaze;
  final MemoryOsoba osoba;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MemoryZaznam>>(
      future: databaze.getRecordsByParticipantID(osoba.id),
      builder: (BuildContext context, AsyncSnapshot<List<MemoryZaznam>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return Container(
                width: double.infinity,
                color: index % 2 == 0 ? Colors.white : Colors.grey[200],
                margin: const EdgeInsets.all(8.0),
                child: ZraneniListItem(snapshot.data![index]),
              );
            },
          );
        }
      },
    );
  }
}

/// Placeholder widget for the bubbles.
class InfoBubble extends StatelessWidget {
  final String label;
  final String value;

  InfoBubble({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 226, 226, 226),
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      margin: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Colors.black),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 14, color: Colors.black),
          ),
        ],
      ),
    );
  }
}

/// Placeholder widget for previous záznamy.
class PreviousZaznam extends StatelessWidget {
  final String title;
  final String date;

  PreviousZaznam({required this.title, required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 226, 226, 226),
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 1.0),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title),
            Text(date),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RecordDetailPage()),
                );
              },
              child: const Text('Detail'),
            ),
          ],
        ),
      ),
    );
  }
}

class EditParticipantPage extends StatelessWidget {
  // Placeholder widget for editing participant details
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upravit'),
      ),
      body: const Center(
        child: Text('Prostě to musím dodělat chcípám z toho'),
      ),
    );
  }
}
