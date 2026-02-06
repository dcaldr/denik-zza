import 'package:denik_zza/print_ops2/generate_pdf_template.dart';
import 'package:denik_zza/print_ops2/pdf_constants.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'pdf_record_row.dart';

class PrintPdfRecords {
  final List<PdfRecordRow>? recordRows;
  final PdfColor borderColor;

  PrintPdfRecords({
    this.recordRows,
    this.borderColor = GeneratePdfTemplate.headerPrimaryColor,
  });

  pw.Widget buildRecordsList(List<PdfRecordRow>? rows,
      {bool forMultiPage = false}) {
    if (rows == null || rows.isEmpty) {
      return pw.Container();
    }

    final container = pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(
          width: kPdfBorderWidth,
          color: borderColor,
        ),
      ),
      padding: const pw.EdgeInsets.all(kPdfRecordsPadding),
      child: pw.Column(
        children: rows
            .expand((row) => [
                  row.buildRow(),
                  pw.SizedBox(height: kPdfHeaderRecordsGap),
                ])
            .toList(),
      ),
    );

    // For MultiPage, return container directly (no Expanded wrapper)
    if (forMultiPage) {
      return container;
    }

    // For single page, use Expanded as before
    return pw.Expanded(child: container);
  }
}
