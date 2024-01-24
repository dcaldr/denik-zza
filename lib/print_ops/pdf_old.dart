import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;



 // Class representing an older PDF generator (deprecated for development-only use)
@Deprecated("Development-Only Use PDFGenerator instead")
class PDFGeneratorOLD {
  final bool _hideHeader = false;
  final bool _hideBorders = false;
  bool hideBody = false;
  //Colors // FIXME: to be refractored to a better place
  PdfColor myTransparentColor = PdfColor.fromHex("#FFFFFF00"); //transaprent
  PdfColor myPrimaryColor = PdfColors.black;
  PdfColor mySecondaryColor = PdfColors.black;

  pw.Widget _generateHeader() {
    pw.Widget headerWidget;
    PdfColor headerPrimaryColor = myPrimaryColor;
    if (_hideHeader) {
      //FIXME: ref
      headerPrimaryColor = myTransparentColor;
    }

    headerWidget = pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(
          width: 2.0,
          color: _hideBorders
              ? myTransparentColor
              : headerPrimaryColor, // Set border color conditionally, _hideHeader has priority
        ),

      ),
      child: pw.Center(
        child: pw.Text(
          'Dan bez hlavy 2ky atd',
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
            color: headerPrimaryColor,
          ),
        ),
      ),
    );

    return headerWidget;
  }

  List<pw.Widget> _generateNotes(List<String> notes, [List<int> toSkip = const []]) {
    List<pw.Widget> noteTextWidgets = [];
    PdfColor notePrimaryColor = myPrimaryColor;
    for (final note in notes) {
      print(notes.indexOf(note));
      if (toSkip.contains(notes.indexOf(note))) {
        print("skipping note $note");
        notePrimaryColor = myTransparentColor;
      } else{
        notePrimaryColor = myPrimaryColor;
      }
      noteTextWidgets.add(
        pw.Text(
          note,
          style: pw.TextStyle(
            fontSize: 16,
            color: notePrimaryColor,
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
        border: pw.Border.all(
          width: 2.0,
          color: _hideBorders
              ? myTransparentColor
              : myPrimaryColor, // Set border color conditionally, //TODO: add more color logic
        ),
      ),
      child: pw.Column(
        children: noteTextWidgets,
      ),
    );
  }

  Future<pw.Document> generatePDF(String fileName, List<String> notes, [List<int> toSkip = const [2]]) async {
   // final mSafeFont = await PdfGoogleFonts.nunitoExtraLight();
    final pdf = pw.Document(
      // theme: pw.ThemeData.withFont(
      //  // base: mSafeFont,
      // ),
    );

    pw.Widget headerWidget = _generateHeader();

    List<pw.Widget> noteTextWidgets = _generateNotes(notes,toSkip);
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

/*     final output = await pdf.save();
    final file = File(fileName);
    await file.writeAsBytes(output);

    OpenFile.open(fileName);*/
    return pdf;
  }

  generatePDFasSomething( List<String> notes,[List<int> toSkip = const [2]]) async {
  //  final mSafeFont = await PdfGoogleFonts.nunitoExtraLight();
    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: pw.Font.ttf(await rootBundle.load('fonts/CourierPrime-Regular.ttf')),
        bold: pw.Font.ttf(await rootBundle.load('fonts/CourierPrime-Bold.ttf')),
        italic: pw.Font.ttf(await rootBundle.load('fonts/CourierPrime-Italic.ttf')),
        boldItalic: pw.Font.ttf(await rootBundle.load('fonts/CourierPrime-BoldItalic.ttf')),
      ),
    );

    pw.Widget headerWidget = _generateHeader();

    List<pw.Widget> noteTextWidgets = _generateNotes(notes,toSkip);
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
    return pdf.save();
  }
}