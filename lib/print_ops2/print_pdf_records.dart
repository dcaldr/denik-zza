import 'package:denik_zza/print_ops2/generate_pdf_template.dart';
import 'package:pdf/widgets.dart' as pw;

import '../database/in_memory_structures_tmp/memory_zaznam.dart';


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