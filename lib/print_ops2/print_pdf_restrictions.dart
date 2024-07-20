import 'package:pdf/widgets.dart' as pw;
import 'package:denik_zza/print_ops2/generate_pdf_template.dart';
import '../database/in_memory_structures_tmp/memory_lek.dart';
import '../database/in_memory_structures_tmp/memory_omezeni.dart';


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