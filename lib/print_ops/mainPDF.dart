import '../database/dummy_data.dart';
import '../database/in_memory_structures_tmp/memory_zaznam.dart';
import 'dev_pdf_view.dart';
//import 'package:my_pdf/memory_zaznam.dart';

//import 'package:pdf/widgets.dart' as pw;

import 'package:flutter/material.dart';


void main() {
  runApp(const MyApp());
}

// Main class of PDF with actions and patients 
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final List<MemoryZaznam> zraneni = MemoryZaznamHolder().memoryZaznamList;


  MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Zranění list Pacient id: ${zraneni[0].idPacient}'),
      ),
      body: ListView.builder(
        itemCount: zraneni.length,
        itemBuilder: (context, index) {
          return ZraneniListItem(zraneni[index]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DevPdfView()),
          );
        },
        child: const Icon(Icons.add), // Use const to improve performance
      ),
    );
  }
}

class ZraneniListItem extends StatelessWidget {
  final MemoryZaznam zraneni;


  const ZraneniListItem(this.zraneni, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start, // Align everything to the left
        children: <Widget>[
          Flexible(
            fit: FlexFit.loose, // Make the column only take up as much space as it needs
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '${zraneni.casZaznamu?.day.toString().padLeft(2, '0')}.${zraneni.casZaznamu?.month.toString().padLeft(2, '0')}.${zraneni.casZaznamu?.year}',
                  style: const TextStyle(fontSize: 10.0),
                ),
                Text(
                  '${zraneni.casZaznamu?.hour.toString().padLeft(2, '0')}:${zraneni.casZaznamu?.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 13.0),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20), // No space between the two columns
          Flexible(
            fit: FlexFit.tight, // Make the column only take up as much space as it needs
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(zraneni.nazev ?? 'No title'),
                Text(zraneni.popis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

 List<String> notes = [
  '10:35 bolest hlavy z programování',
  '11:00 - dlouhodobě si stěžuje natolik, aby byl text zápisu co nejdelší',
  'přitom obsahoval co nejvíce záludností',
  'dále by docela rád viděl jak se dlouhý text dále kupí a kupí, ale to se snad nějakým způsobem dále natáhne aby bylo vidět, jestli se text dokáže zalomit sám, bez vložení dalších speciálních znaků',
  '11:30 už to dále nezvládá',
  '14:30 absolutně nechápe, jaktože je ještě naživu',
];