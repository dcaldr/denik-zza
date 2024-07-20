import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import '../database/in_memory_structures_tmp/memory_lek.dart';
import '../database/in_memory_structures_tmp/memory_omezeni.dart';
import '../database/in_memory_structures_tmp/memory_osoba.dart';
import 'package:printing/printing.dart';
import '../database/in_memory_structures_tmp/memory_zaznam.dart';
import 'print_template.dart';

MemoryOsoba historicalFigure = MemoryOsoba.fullNamed(
  id: 1,
  jmeno: 'Jan',
  prijmeni: 'Hus',
  pohlavi: 1,
  adresa: 'Husinec, Česká Republika',
  cisloPojisteni: '123456/7890',
  datumNarozeni: DateTime(1369, 7, 6),
  jmenoRodice: 'Pan Hus',
  telefonRodice: '558977432',
  emailRodice: 'velmi.dlouha.emailova.edresa@seznam.cz',
  zpusobilost: true,
  bezinfekcnost: true,
  zdravotniPojistovna: 'Český Řízek',
  poznamka: 'Měl moc rád český řízek',
  wasPrinted: false, oddil: null, prisel: null, potvrzeniPath: null,
);
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
];

List<Omezeni> omezeniList = [
  Omezeni(id: 1, omezeni: 'Bezlepková dieta', typOmezeni: 1),
  Omezeni(id: 2, omezeni: 'Alergie na ořechy', typOmezeni: 2),
  Omezeni(id: 3, omezeni: 'Laktózová intolerance', typOmezeni: 1),
  Omezeni(id: 4, omezeni: 'Alergie na pyl', typOmezeni: 2),
  Omezeni(id: 5, omezeni: 'Vegetariánství', typOmezeni: 1),
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
      home: PdfPreviewScreen(),
    );
  }
}

class PdfPreviewScreen extends StatelessWidget {
  const PdfPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Preview'),
      ),
      body: PdfPreview(
        build: (format) async {
          final template = GeneratePdfTemplate();
          final pdf = await template.getPdfWidget( historicalFigure,omezeniList: omezeniList,lekList: lekList, zaznamList: historicalRecords);
          return pdf.save();
        },
        initialPageFormat: PdfPageFormat.a4,
        maxPageWidth: MediaQuery.of(context).size.height / 1.6, // hard coded -by hand
        pdfFileName: "sample.pdf",

      ),
    );
  }
}