import 'dart:io';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:open_file/open_file.dart';

class PDFGenerator {
  bool _hideHeader = true;
  bool hideSquares = false;
  bool hideBody = false;
  //Colors // FIXME: to be refractored to a better place
  PdfColor myTransparentColor =  PdfColor.fromHex("#FFFFFF00"); //transaprent
  PdfColor myPrimaryColor = PdfColor.fromHex('#FF0000'); // black
  PdfColor mySecondaryColor = PdfColor.fromHex('#00FF00'); //black

  pw.Widget _generateHeader() {
    pw.Widget headerWidget;

    if (_hideHeader) {
      headerWidget = pw.Container(
        color: myTransparentColor,
        /* decoration: pw.BoxDecoration(

          border: pw.Border.all(width: 2.0), // Set border width to 0
          color: myTransparentColor, // Set container color to white
        ), */
        child: pw.Center(
          child: pw.Text(
            'Dan bez hlavy 2ky atd',
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
              //  color: PdfColors.red, // Set text color to white
              //   color: myTransparentColor
            ),
          ),
        ),
      );
    } else {
      headerWidget = pw.Container(
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
    return headerWidget;
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