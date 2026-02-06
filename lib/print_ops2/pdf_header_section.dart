import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_omezeni.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_lek.dart';
import 'package:denik_zza/utils/date_format_utils.dart';
import 'package:denik_zza/print_ops2/pdf_constants.dart';

/// Abstract base for PDF header section (person/event)
abstract class PdfHeaderSection {
  pw.Widget buildHeader();
}

/// Concrete implementation for person header (includes restrictions)
class PersonPdfHeaderSection extends PdfHeaderSection {
  final MemoryOsoba osoba;
  final List<MemoryOmezeni>? omezeniList;
  final List<MemoryLek>? lekList;
  final PdfColor? textColor;

  PersonPdfHeaderSection(this.osoba,
      {this.omezeniList, this.lekList, this.textColor});

  @override
  pw.Widget buildHeader() {
    // Implementation similar to PrintPdfHeader.buildHeader
    String formatZdravotniPojistovna(String? zdravotniPojistovna) {
      return zdravotniPojistovna != null ? ' ($zdravotniPojistovna)' : '';
    }

    return pw.Column(
      children: [
        // Person info section
        pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border.all(
                width: kPdfBorderWidth, color: textColor ?? PdfColor(0, 0, 0)),
          ),
          child: pw.Padding(
            padding: const pw.EdgeInsets.all(kPdfHeaderPadding),
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
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.normal,
                              color: textColor),
                          children: [
                            pw.TextSpan(
                              text: '${osoba.jmeno} ${osoba.prijmeni}',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  color: textColor),
                            ),
                          ],
                        ),
                      ),
                      pw.Text(
                          'Datum narození: ${formatCzechDate(osoba.datumNarozeni)}',
                          style: pw.TextStyle(color: textColor)),
                      pw.Text(
                        'Pojištění: ${osoba.cisloPojisteni ?? ''}${formatZdravotniPojistovna(osoba.zdravotniPojistovna)}',
                        maxLines: 2,
                        overflow: pw.TextOverflow.clip,
                        style: pw.TextStyle(color: textColor),
                      ),
                      pw.Text(
                        'Adresa: ${osoba.adresa ?? ''}',
                        maxLines: 2,
                        overflow: pw.TextOverflow.clip,
                        style: pw.TextStyle(color: textColor),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(width: kPdfHeaderColumnGap),
                pw.Expanded(
                  flex: 1,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Rodič: ${osoba.jmenoRodice ?? ''}',
                          maxLines: 2,
                          overflow: pw.TextOverflow.clip,
                          style: pw.TextStyle(color: textColor)),
                      pw.Text('Tel. rodič: ${osoba.telefonRodice ?? ''}',
                          maxLines: 2,
                          overflow: pw.TextOverflow.clip,
                          style: pw.TextStyle(color: textColor)),
                      pw.Text('Email rodič: ${osoba.emailRodice ?? ''}',
                          style: pw.TextStyle(color: textColor)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Restrictions section (only for person headers)
        if (omezeniList != null || lekList != null) ...[
          pw.SizedBox(height: kPdfHeaderRecordsGap),
          pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(
                  width: kPdfBorderWidth,
                  color: textColor ?? PdfColor(0, 0, 0)),
            ),
            child: pw.Padding(
              padding: const pw.EdgeInsets.all(kPdfHeaderPadding),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Omezení:',
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                color: textColor)),
                        ...?omezeniList?.map((omezeni) => pw.Text(
                              '- ${omezeni.omezeni}',
                              style: pw.TextStyle(color: textColor),
                            )),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: kPdfHeaderColumnGap),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Léky:',
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                color: textColor)),
                        ...?lekList?.map((lek) => pw.Text(
                              '- ${lek.nazev}',
                              style: pw.TextStyle(color: textColor),
                            )),
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
