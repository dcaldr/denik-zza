import 'dart:io';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:open_file/open_file.dart';

class PDFGenerator {
  bool _hideHeader = false;
  bool hideSquares = false;

  pw.Widget _generateHeader() {
    return _hideHeader
        ? pw.SizedBox.shrink()
        : pw.Container(
      //color: PdfColors.white,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(width: 2.0),
      ),
      child: pw.Center(
        child: pw.Text(
          'Dan bez hlavy 2ky atd',
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ),
    );
  }

  List<pw.Widget> _generateNotes(List<String> notes) {
    List<pw.Widget> noteTextWidgets = [];
    for (final note in notes) {
      noteTextWidgets.add(
        pw.Text(
          note,
          style: pw.TextStyle(
            fontSize: 16,
          ),
        ),
      );
      noteTextWidgets.add(pw.SizedBox(height: 10));
    }
    return noteTextWidgets;
  }

  pw.Widget _generateNotesWidget(List<pw.Widget> noteTextWidgets) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(width: 2.0),
      ),
      child: pw.Column(
        children: noteTextWidgets,
      ),
    );
  }

  Future<void> generatePDF(String fileName, List<String> notes) async {
    final mSafeFont = await PdfGoogleFonts.nunitoExtraLight();
    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: mSafeFont,
      ),
    );

    pw.Widget headerWidget = _generateHeader();

    List<pw.Widget> noteTextWidgets = _generateNotes(notes);
    pw.Widget notesWidget = _generateNotesWidget(noteTextWidgets);

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          children: [
            headerWidget,
            pw.SizedBox(height: 20),
            notesWidget,
          ],
        ),
      ),
    );

    final output = await pdf.save();
    final file = File(fileName);
    await file.writeAsBytes(output);

    OpenFile.open(fileName);
  }
}