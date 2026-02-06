import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:denik_zza/database/in_memory_structures_tmp/memory_zaznam.dart';
import 'package:denik_zza/utils/date_format_utils.dart';
import 'package:denik_zza/print_ops2/pdf_constants.dart';

/// Abstract base for a record row in PDF (person/event)
abstract class PdfRecordRow {
  pw.Widget buildRow();
}

/// Concrete implementation for person record row
class PersonPdfRecordRow extends PdfRecordRow {
  final MemoryZaznam record;
  final bool isHidden;
  final PdfColor? textColor;

  PersonPdfRecordRow(this.record, {this.isHidden = false, this.textColor});

  @override
  pw.Widget buildRow() {
    // Current implementation for MemoryZaznam
    final rowContent = pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Align(
          alignment: pw.Alignment.topLeft,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                formatCzechDate(record.casZaznamu),
                style: pw.TextStyle(
                    fontSize: kPdfRecordDateFontSize, color: textColor),
              ),
              pw.Text(
                formatCzechTime(record.casZaznamu),
                style: pw.TextStyle(
                    fontSize: kPdfRecordTimeFontSize, color: textColor),
              ),
            ],
          ),
        ),
        pw.SizedBox(width: kPdfRecordGapWidth),
        pw.Flexible(
          child: pw.RichText(
            text: pw.TextSpan(
              text: record.nazev != null ? '${record.nazev} - ' : ' ',
              style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold, color: textColor),
              children: <pw.TextSpan>[
                pw.TextSpan(
                  text: record.popis,
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.normal, color: textColor),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    return rowContent;
  }
}

// Future: EventPdfRecordRow for per event print
