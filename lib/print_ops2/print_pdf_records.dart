import 'package:denik_zza/print_ops2/generate_pdf_template.dart';
import 'package:pdf/widgets.dart' as pw;


import 'pdf_record_row.dart';

class PrintPdfRecords implements PdfSection {
  final List<PdfRecordRow>? recordRows;

  PrintPdfRecords({this.recordRows});

  pw.Widget buildRecordsList(List<PdfRecordRow>? rows) {
    if (rows == null || rows.isEmpty) {
      return pw.Container();
    }
    return pw.Expanded(
      child: pw.Container(
        decoration: pw.BoxDecoration(
          border: pw.Border.all(
            width: 2.0,
            color: GeneratePdfTemplate.headerPrimaryColor,
          ),
        ),
        padding: const pw.EdgeInsets.all(8.0),
        child: pw.Column(
          children: rows.expand((row) => [
            row.buildRow(),
            pw.SizedBox(height: 5),
          ]).toList(),
        ),
      ),
    );
  }

  @override
  pw.Widget buildSection(bool append) {
    return buildRecordsList(recordRows);
  }
}