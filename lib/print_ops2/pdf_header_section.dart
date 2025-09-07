import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Abstract base for PDF header section (person/event)
abstract class PdfHeaderSection {
  pw.Widget buildHeader();
}

/// Concrete implementation for person header (includes restrictions)
class PersonPdfHeaderSection extends PdfHeaderSection {
  final dynamic osoba; // Should be MemoryOsoba, but kept dynamic for future event
  final List<dynamic>? omezeniList; // MemoryOmezeni list
  final List<dynamic>? lekList; // MemoryLek list
  
  PersonPdfHeaderSection(this.osoba, {this.omezeniList, this.lekList});

  @override
  pw.Widget buildHeader() {
    // Implementation similar to PrintPdfHeader.buildHeader
    String _formatDate(DateTime? date) {
      if (date == null) return '';
      return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
    }
    String _formatZdravotniPojistovna(String? zdravotniPojistovna) {
      return zdravotniPojistovna != null ? ' ($zdravotniPojistovna)' : '';
    }
    
    return pw.Column(
      children: [
        // Person info section
        pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border.all(width: 2.0, color: PdfColor(0, 0, 0)),
          ),
          child: pw.Padding(
            padding: const pw.EdgeInsets.all(5.0),
            child: pw.Row(
              children: [
                pw.Expanded(
                  flex: 1,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.RichText(
                        text: pw.TextSpan(
                          text: 'Jméno: ',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.normal),
                          children: [
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
                  ),
                ),
                pw.SizedBox(width: 10),
                pw.Expanded(
                  flex: 1,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Rodič: ${osoba?.jmenoRodice ?? ''}', maxLines: 2, overflow: pw.TextOverflow.clip),
                      pw.Text('Tel. rodič: ${osoba?.telefonRodice ?? ''}', maxLines: 2, overflow: pw.TextOverflow.clip),
                      pw.Text('Email rodič: ${osoba?.emailRodice ?? ''}'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Restrictions section (only for person headers)
        if (omezeniList != null || lekList != null) ...[
          pw.SizedBox(height: 5),
          pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(width: 2.0, color: PdfColor(0, 0, 0)),
            ),
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
          ),
        ],
      ],
    );
  }
}

// Future: EventPdfHeaderSection for per event print