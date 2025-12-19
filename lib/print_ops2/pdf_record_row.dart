import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Abstract base for a record row in PDF (person/event)
abstract class PdfRecordRow {
  pw.Widget buildRow();
}

/// Concrete implementation for person record row
class PersonPdfRecordRow extends PdfRecordRow {
  final dynamic record;
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
                '${record.casZaznamu?.day.toString().padLeft(2, '0')}.${record.casZaznamu?.month.toString().padLeft(2, '0')}.${record.casZaznamu?.year}',
                style: pw.TextStyle(fontSize: 8.0, color: textColor),
              ),
              pw.Text(
                '${record.casZaznamu?.hour.toString().padLeft(2, '0')}:${record.casZaznamu?.minute.toString().padLeft(2, '0')}',
                style: pw.TextStyle(fontSize: 9.0, color: textColor),
              ),
            ],
          ),
        ),
        pw.SizedBox(width: 20),
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
