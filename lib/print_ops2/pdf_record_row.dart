import 'package:pdf/widgets.dart' as pw;

/// Abstract base for a record row in PDF (person/event)
abstract class PdfRecordRow {
  pw.Widget buildRow();
}

/// Concrete implementation for person record row
class PersonPdfRecordRow extends PdfRecordRow {
  final dynamic record; // Should be MemoryZaznam, but kept dynamic for future event
  PersonPdfRecordRow(this.record);

  @override
  pw.Widget buildRow() {
    // Current implementation for MemoryZaznam
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Align(
          alignment: pw.Alignment.topLeft,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                '${record.casZaznamu?.day.toString().padLeft(2, '0')}.${record.casZaznamu?.month.toString().padLeft(2, '0')}.${record.casZaznamu?.year}',
                style: const pw.TextStyle(fontSize: 8.0),
              ),
              pw.Text(
                '${record.casZaznamu?.hour.toString().padLeft(2, '0')}:${record.casZaznamu?.minute.toString().padLeft(2, '0')}',
                style: const pw.TextStyle(fontSize: 9.0),
              ),
            ],
          ),
        ),
        pw.SizedBox(width: 20),
        pw.Flexible(
          child: pw.RichText(
            text: pw.TextSpan(
              text: record.nazev != null ? '${record.nazev} - ' : ' ',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              children: <pw.TextSpan>[
                pw.TextSpan(
                  text: record.popis,
                  style: pw.TextStyle(fontWeight: pw.FontWeight.normal),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Future: EventPdfRecordRow for per event print