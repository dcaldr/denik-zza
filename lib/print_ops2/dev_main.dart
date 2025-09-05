import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import '../database/in_memory_structures_tmp/memory_lek.dart';
import '../database/in_memory_structures_tmp/memory_omezeni.dart';
import '../database/in_memory_structures_tmp/memory_osoba.dart';
import 'package:printing/printing.dart';
import '../database/in_memory_structures_tmp/memory_zaznam.dart';
import 'generate_pdf_template.dart';
import 'package:pdf/widgets.dart' as pw;

// Demo persons (Czech themed, subtle cultural nods)
final List<MemoryOsoba> demoPersons = [
  MemoryOsoba.fullNamed(
    id: 1,
    jmeno: 'Jan',
    prijmeni: 'Novák',
    pohlavi: 1,
    adresa: 'Praha 1',
    cisloPojisteni: '123456/0001',
    datumNarozeni: DateTime(2008, 5, 14),
    jmenoRodice: 'Petr',
    telefonRodice: '777111222',
    emailRodice: 'rodic.jan@example.cz',
    zpusobilost: true,
    bezinfekcnost: true,
    zdravotniPojistovna: '111 VZP',
    poznamka: 'Má rád turistické značky.',
    wasPrinted: false, oddil: null, prisel: null, potvrzeniPath: null,
  ),
  MemoryOsoba.fullNamed(
    id: 2,
  jmeno: 'Karel',
  prijmeni: 'Čapek', // jemný náznak nyní plné příjmení
    pohlavi: 1,
    adresa: 'Hradec Králové',
    cisloPojisteni: '234567/0002',
    datumNarozeni: DateTime(2007, 11, 2),
    jmenoRodice: 'Alena',
    telefonRodice: '777333444',
    emailRodice: 'rodic.karel@example.cz',
    zpusobilost: true,
    bezinfekcnost: true,
    zdravotniPojistovna: '207 OZP',
    poznamka: 'Píše si krátké sloupky.',
    wasPrinted: false, oddil: null, prisel: null, potvrzeniPath: null,
  ),
  MemoryOsoba.fullNamed(
    id: 3,
  jmeno: 'Božena',
  prijmeni: 'Němcová', // nenápadný odkaz nyní plné příjmení
    pohlavi: 2,
    adresa: 'Litomyšl',
    cisloPojisteni: '345678/0003',
    datumNarozeni: DateTime(2006, 2, 9),
    jmenoRodice: 'Ludmila',
    telefonRodice: '777555666',
    emailRodice: 'rodic.bozena@example.cz',
    zpusobilost: true,
    bezinfekcnost: true,
    zdravotniPojistovna: '211 ZPMV',
    poznamka: 'Sbírá lidové pověsti.',
    wasPrinted: false, oddil: null, prisel: null, potvrzeniPath: null,
  ),
  MemoryOsoba.fullNamed(
    id: 4,
    jmeno: 'David',
    prijmeni: 'Dvojstránka',
    pohlavi: 1,
    adresa: 'Brno',
    cisloPojisteni: '456789/0004',
    datumNarozeni: DateTime(2008, 9, 21),
    jmenoRodice: 'Ivana',
    telefonRodice: '777999888',
    emailRodice: 'rodic.david@example.cz',
    zpusobilost: true,
    bezinfekcnost: true,
    zdravotniPojistovna: '205 ČPZP',
    poznamka: 'Má hodně záznamů k tisku.',
    wasPrinted: false, oddil: null, prisel: null, potvrzeniPath: null,
  ),
];
List<MemoryZaznam> historicalRecords = [
  MemoryZaznam.fullNamed(
    idZaznamu: 1,
    casZaznamu: DateTime(1415, 7, 6),
    nazev: 'Upálení',
    popis: 'Jan Hus byl upálen na hranici.',
    lecba: null,
    isPrinted: false,
    idAuthor: 1,
    idPacient: 1,
    poznamka: 'Historická událost',
    teplota: null,
    obrazekPath: null,
  ),
  MemoryZaznam.fullNamed(
    idZaznamu: 2,
    casZaznamu: DateTime(1402, 3, 15),
    nazev: 'Kázání v Betlémské kapli',
    popis: 'Jan Hus začal kázat v Betlémské kapli.',
    lecba: null,
    isPrinted: false,
    idAuthor: 1,
    idPacient: 1,
    poznamka: 'Důležitý moment v životě Jana Husa',
    teplota: null,
    obrazekPath: null,
  ),
  MemoryZaznam.fullNamed(
    idZaznamu: 3,
    casZaznamu: DateTime(1414, 11, 5),
    nazev: 'Kostnický koncil',
    popis: 'Jan Hus byl předvolán před Kostnický koncil.',
    lecba: null,
    isPrinted: false,
    idAuthor: 1,
    idPacient: 1,
    poznamka: 'Začátek soudního procesu',
    teplota: null,
    obrazekPath: null,
  ),
  MemoryZaznam.fullNamed(
    idZaznamu: 4,
    casZaznamu: DateTime(1409, 6, 24),
    nazev: 'Dekret kutnohorský',
    popis: 'Jan Hus podpořil Dekret kutnohorský.',
    lecba: null,
    isPrinted: false,
    idAuthor: 1,
    idPacient: 1,
    poznamka: 'Významný politický akt',
    teplota: null,
    obrazekPath: null,
  ),
  MemoryZaznam.fullNamed(
    idZaznamu: 5,
    casZaznamu: DateTime(1412, 6, 7),
    nazev: 'Odpustky',
    popis: 'Jan Hus vystoupil proti odpustkům.',
    lecba: null,
    isPrinted: false,
    idAuthor: 1,
    idPacient: 1,
    poznamka: 'Kritika církevních praktik',
    teplota: null,
    obrazekPath: null,
  ),
  // Sample records for the other demo persons (minimal to show filtering)
  MemoryZaznam.fullNamed(
    idZaznamu: 6,
    casZaznamu: DateTime(2024, 6, 1),
    nazev: 'Trénink',
    popis: ' absolvoval ranní běh a kontrolu dýchání.',
    lecba: null,
    isPrinted: false,
    idAuthor: 1,
    idPacient: 1,
    poznamka: 'Bez komplikací',
    teplota: null,
    obrazekPath: null,
  ),
  MemoryZaznam.fullNamed(
    idZaznamu: 7,
    casZaznamu: DateTime(2024, 6, 2),
    nazev: 'Poznámka',
    popis: 'Karel si přinesl vlastní sešit, krátce psal.',
    lecba: null,
    isPrinted: false,
    idAuthor: 2,
    idPacient: 2,
    poznamka: 'Klidný den',
    teplota: null,
    obrazekPath: null,
  ),
  MemoryZaznam.fullNamed(
    idZaznamu: 8,
    casZaznamu: DateTime(2024, 6, 3),
    nazev: 'Setkání',
    popis: 'Božena se účastnila čtení příběhů.',
    lecba: null,
    isPrinted: false,
    idAuthor: 3,
    idPacient: 3,
    poznamka: 'Spolupráce s ostatními',
    teplota: null,
    obrazekPath: null,
  ),
  // Many records for David Dvojstránka to simulate multi-page scenario
  for (int i = 0; i < 25; i++)
    MemoryZaznam.fullNamed(
      idZaznamu: 100 + i,
      casZaznamu: DateTime(2024, 7, 1, 8 + (i % 10), (i * 7) % 60),
      nazev: 'Aktivita ${i + 1}',
      popis: 'David provedl aktivitu číslo ${i + 1} – krátký popis události s detaily pro test délky.',
      lecba: null,
      isPrinted: false,
      idAuthor: 4,
      idPacient: 4,
      poznamka: 'Poznámka k aktivitě ${i + 1}',
      teplota: null,
      obrazekPath: null,
    ),
];

List<MemoryOmezeni> omezeniList = [
  MemoryOmezeni(id: 1, omezeni: 'Bezlepková dieta', typOmezeni: 1),
  MemoryOmezeni(id: 2, omezeni: 'Alergie na ořechy', typOmezeni: 2),
  MemoryOmezeni(id: 3, omezeni: 'Laktózová intolerance', typOmezeni: 1),
  MemoryOmezeni(id: 4, omezeni: 'Alergie na pyl', typOmezeni: 2),
  MemoryOmezeni(id: 5, omezeni: 'Vegetariánství', typOmezeni: 1),
];

List<MemoryLek> lekList = [
  MemoryLek(1, 'Paralen', '1 tableta každé 4 hodiny', false, DavkaKdy.rano),
  MemoryLek(2, 'Ibalgin', '2 tablety po jídle', false, DavkaKdy.vecer),
  MemoryLek(3, 'Aspirin', '1 tableta denně', false, DavkaKdy.poledne),
  MemoryLek(4, 'Nurofen', '1 tableta každých 6 hodin', false, DavkaKdy.odpoledne),
  MemoryLek(5, 'Panadol', '1 tableta každé 8 hodin', false, DavkaKdy.dopoledne),
];

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: PrintDemoLandingScreen(),
    );
  }
}

// New landing page: only two buttons as requested.
class PrintDemoLandingScreen extends StatelessWidget {
  const PrintDemoLandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Print Demo')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const PersonSelectionScreen(),
                  ),
                );
              },
              child: const Text('Per Person'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: null,
              child: const Text('Per Event (soon)'),
            ),
          ],
        ),
      ),
    );
  }
}

// First screen: list of demo persons, each with two buttons:
// 1) Per Person (active) -> navigates to PDF preview for that person
// 2) Per Event (disabled placeholder)
class PersonSelectionScreen extends StatelessWidget {
  const PersonSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Person to Print')),
      body: ListView.separated(
        padding: const EdgeInsets.all(4),
        itemCount: demoPersons.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final person = demoPersons[index];
          return ListTile(
            title: Text('${person.jmeno} ${person.prijmeni}'),
            subtitle: Text(person.poznamka ?? ''),
            leading: CircleAvatar(child: Text(person.jmeno.substring(0,1))),
            trailing: const Icon(Icons.picture_as_pdf),
            onTap: () {
              final filteredRecords = historicalRecords.where((r) => r.idPacient == person.id).toList();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PdfPreviewScreen(
                    osoba: person,
                    omezeni: omezeniList,
                    leky: lekList,
                    zaznamy: filteredRecords,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}


class PdfPreviewScreen extends StatelessWidget {
  final MemoryOsoba osoba;
  final List<MemoryOmezeni> omezeni;
  final List<MemoryLek> leky;
  final List<MemoryZaznam> zaznamy;

  const PdfPreviewScreen({
    super.key,
    required this.osoba,
    required this.omezeni,
    required this.leky,
    required this.zaznamy,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Preview - ${osoba.jmeno} ${osoba.prijmeni}'),
      ),
      body: PdfPreview(
        build: (format) async {
          final template = GeneratePdfTemplate();
          // Work on cloned lists to avoid side-effects downstream
          final clonedRecords = List<MemoryZaznam>.from(zaznamy);
          final pdfPages = await template.getPdfPages(
            osoba: osoba,
            omezeniList: omezeni,
            lekList: leky,
            zaznamList: clonedRecords,
          );
          final pdf = pw.Document();
          for (var page in pdfPages) {
            pdf.addPage(page);
          }
          return pdf.save();
        },
        initialPageFormat: PdfPageFormat.a4,
        // Keep a simpler heuristic for preview width
        maxPageWidth: 600,
        pdfFileName: 'person_${osoba.id}.pdf',
      ),
    );
  }
}