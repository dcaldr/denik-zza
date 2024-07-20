import 'package:denik_zza/print_ops2/generate_pdf_template.dart';
import 'package:pdf/widgets.dart' as pw;
import '../database/in_memory_structures_tmp/memory_osoba.dart';

class PrintPdfHeader implements PdfSection {
  pw.Widget buildHeader(MemoryOsoba? inOsoba) {
    return pw.Container(
      decoration: _buildHeaderDecoration(),
      child: pw.Padding(
        padding: const pw.EdgeInsets.all(5.0),
        child: pw.Row(
          children: [
            pw.Expanded(flex: 1, child: _buildLeftColumn(inOsoba)),
            pw.SizedBox(width: 10),
            pw.Expanded(flex: 1, child: _buildRightColumn(inOsoba)),
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
    );
  }

  pw.Widget _buildRightColumn(MemoryOsoba? osoba) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Rodič: ${osoba?.jmenoRodice ?? ''}', maxLines: 2, overflow: pw.TextOverflow.clip),
        pw.Text('Tel. rodič: ${osoba?.telefonRodice ?? ''}', maxLines: 2, overflow: pw.TextOverflow.clip),
        pw.Text(
          'Email rodič: ${osoba?.emailRodice ?? ''}',
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
    throw UnimplementedError();
  }
}