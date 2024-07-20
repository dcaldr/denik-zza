import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../database/in_memory_structures_tmp/memory_lek.dart';
import '../database/in_memory_structures_tmp/memory_omezeni.dart';
import '../database/in_memory_structures_tmp/memory_osoba.dart';

import '../database/in_memory_structures_tmp/memory_zaznam.dart';
//TODO: ref: file name
class GeneratePdfTemplate {
  late pw.Widget header;
  static const headerPrimaryColor = PdfColor(0, 0, 0);

  getPdfWidget(MemoryOsoba osoba, {List<Omezeni>? omezeniList, List<MemoryLek>? lekList, List<MemoryZaznam>? zaznamList}) async {
    header = PrintPdfHeader().buildHeader(osoba);
    pw.Widget? restrictions;

    if (omezeniList != null && lekList != null) {
      restrictions = PrintPdfRestrictions().buildRestrictions(omezeniList, lekList);
    }

    return pw.Document(
      theme: pw.ThemeData.withFont(
        base: pw.Font.ttf(await rootBundle.load('fonts/CourierPrime-Regular.ttf')),
        bold: pw.Font.ttf(await rootBundle.load('fonts/CourierPrime-Bold.ttf')),
        italic: pw.Font.ttf(await rootBundle.load('fonts/CourierPrime-Italic.ttf')),
        boldItalic: pw.Font.ttf(await rootBundle.load('fonts/CourierPrime-BoldItalic.ttf')),
      ),
    )..addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              header,
              pw.SizedBox(height: 20),
              if (restrictions != null) restrictions,
              if (zaznamList != null) PrintPdfRecords().buildRecordsList(zaznamList),
            ],
          );
        },
      ),
    );
  }
}

class PrintPdfHeader implements PdfSection {
  pw.Widget buildHeader(MemoryOsoba? inOsoba) {
    return pw.Container(
      decoration: _buildHeaderDecoration(),
      child: pw.Padding(
        padding: const pw.EdgeInsets.all(5.0),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            _buildLeftColumn(inOsoba),
            _buildRightColumn(inOsoba),
          ],
        ),
      ),
    );
  }

  pw.BoxDecoration _buildHeaderDecoration() {
    return pw.BoxDecoration(
      border: pw.Border.all(
        width: 2.0,
        color: GeneratePdfTemplate.headerPrimaryColor,
      ),
    );
  }

  pw.Widget _buildLeftColumn(MemoryOsoba? osoba) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.RichText(
          text: pw.TextSpan(
            text: 'Jméno: ',
            style: pw.TextStyle(fontWeight: pw.FontWeight.normal),
            children: <pw.TextSpan>[
              pw.TextSpan(
                text: '${osoba?.jmeno ?? ''} ${osoba?.prijmeni ?? ''}',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ],
          ),
        ),
        pw.Text('Datum narození: ${_formatDate(osoba?.datumNarozeni)}'),
        pw.Text(
          'Pojištění: ${osoba?.cisloPojisteni ?? ''}${_formatZdravotniPojistovna(osoba?.zdravotniPojistovna)}',
          maxLines: 2,
          overflow: pw.TextOverflow.clip,
        ),
        pw.Text(
          'Adresa: ${osoba?.adresa ?? ''}',
          maxLines: 2,
          overflow: pw.TextOverflow.clip,
        ),
      ],
    );
  }

  pw.Widget _buildRightColumn(MemoryOsoba? osoba) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Rodič: ${osoba?.jmenoRodice ?? ''}'),
        pw.Text('Tel. rodič: ${osoba?.telefonRodice ?? ''}'),
        pw.Text(
          'Email rodič: ${osoba?.emailRodice ?? ''}',
          maxLines: 2,
          overflow: pw.TextOverflow.clip,
        ),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  String _formatZdravotniPojistovna(String? zdravotniPojistovna) {
    return zdravotniPojistovna != null ? ' ($zdravotniPojistovna)' : '';
  }

  @override
  pw.Widget buildSection(bool append) {
    // TODO: implement buildSection
    throw UnimplementedError();
  }
}

class PrintPdfRestrictions  implements PdfSection{
   List<Omezeni>? omezeniList;
   List<MemoryLek>? lekList;

   PrintPdfRestrictions({this.omezeniList, this.lekList});

  pw.Widget buildRestrictions(List<Omezeni>? omezeniList, List<MemoryLek>? lekList) {
    return pw.Container(
      decoration: _buildRestrictionsDecoration(),
      child: pw.Padding(
        padding: const pw.EdgeInsets.all(5.0),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Omezení:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ...?omezeniList?.map((omezeni) => pw.Text('- ${omezeni.omezeni}')),
                ],
              ),
            ),
            pw.SizedBox(width: 10),
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Léky:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ...?lekList?.map((lek) => pw.Text('- ${lek.nazev}')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  pw.BoxDecoration _buildRestrictionsDecoration() {
    return pw.BoxDecoration(
      border: pw.Border.all(
        width: 2.0,
        color: GeneratePdfTemplate.headerPrimaryColor,
      ),
    );
  }

  @override
  pw.Widget buildSection(bool append) {
    // TODO: implement buildSection
    throw UnimplementedError();
  }
}


class PrintPdfRecords implements PdfSection {
  final List<MemoryZaznam>? records;

  PrintPdfRecords({this.records});

  pw.Widget buildRecordsList(List<MemoryZaznam>? zaznamList) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(
          width: 2.0,
          color: GeneratePdfTemplate.headerPrimaryColor,
        ),
      ),
      padding: const pw.EdgeInsets.all(8.0),
      child: pw.Column(
        children: zaznamList!.expand((record) => [
          _noteItem(record),
          pw.SizedBox(height: 5),
        ]).toList(),
      ),
    );
  }

  pw.Widget _noteItem(MemoryZaznam note) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Align(
          alignment: pw.Alignment.topLeft,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                '${note.casZaznamu?.day.toString().padLeft(2, '0')}.${note.casZaznamu?.month.toString().padLeft(2, '0')}.${note.casZaznamu?.year}',
                style: const pw.TextStyle(fontSize: 8.0),
              ),
              pw.Text(
                '${note.casZaznamu?.hour.toString().padLeft(2, '0')}:${note.casZaznamu?.minute.toString().padLeft(2, '0')}',
                style: const pw.TextStyle(fontSize: 9.0),
              ),
            ],
          ),
        ),
        pw.SizedBox(width: 20),
        pw.Flexible(
          child: pw.RichText(
            text: pw.TextSpan(
              text: note.nazev != null ? '${note.nazev} - ' : ' ',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              children: <pw.TextSpan>[
                pw.TextSpan(
                  text: note.popis,
                  style: pw.TextStyle(fontWeight: pw.FontWeight.normal),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  pw.Widget buildSection(bool append) {
    // TODO: implement buildSection
    throw UnimplementedError();
  }
}

abstract class PdfSection {
  pw.Widget buildSection(bool append);
}