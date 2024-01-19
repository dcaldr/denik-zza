
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../database/dummy_data.dart';
import '../database/in_memory_structures_tmp/memory_zaznam.dart';


class PDFGenerator{
MemoryOsoba osoba = DummyData().osobnostiBard[0] ;
PdfColor myTransparentColor = PdfColor.fromHex("#FFFFFF00"); //transaprent
PdfColor myPrimaryColor = PdfColors.black;
PdfColor mySecondaryColor = PdfColors.black;

//PDFGenerator(this.osoba);
final bool _hideHeader = false;
final bool _hideBorders = false;
bool hideBody = false;
//Colors // FIXME: to be refractored to a better place



//FIXME: temporary set
List<pw.Widget> _generateNotes(List<MemoryZaznam> notes,) {

  List<pw.Widget> noteTextWidgets = [];
  for (final note in notes) {

    noteTextWidgets.add( _noteItem(note) );
    noteTextWidgets.add(pw.SizedBox(height: 5));
  }
  return noteTextWidgets;
}

pw.Widget _generateNotesWidget(List<pw.Widget> noteTextWidgets) {
  return pw.Expanded(
    child: pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(
          width: 2.0,
          color: _hideBorders || hideBody
              ? myTransparentColor
              : myPrimaryColor, // Set border color conditionally
        ),
      ),
      child: pw.Padding(
        padding: const pw.EdgeInsets.all(5), // Add padding here
        child: pw.Column(
          children: noteTextWidgets,
        ),
      ),
    ),
  );
}



pw.Widget _noteItem(MemoryZaznam note) {
  PdfColor notePrimaryColor = myPrimaryColor;
  if (note.isPrinted || hideBody) {
    print("skipping note ${note.idZaznamu}.");
    notePrimaryColor = myTransparentColor;
  } else{
    notePrimaryColor = myPrimaryColor;
  }
  pw.Widget a = pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.start, // Align items to the start
    children: [
      pw.Align(
        alignment: pw.Alignment.topLeft, // Align to the top
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              '${note.casZaznamu?.day.toString().padLeft(2, '0')}.${note.casZaznamu?.month.toString().padLeft(2, '0')}.${note.casZaznamu?.year}',
              style: pw.TextStyle(fontSize: 8.0, color: notePrimaryColor),
            ),
            pw.Text(
              '${note.casZaznamu?.hour.toString().padLeft(2, '0')}:${note.casZaznamu?.minute.toString().padLeft(2, '0')}',
              style: pw.TextStyle(fontSize: 9.0, color: notePrimaryColor),
            ),
          ],
        ),
      ),
      pw.SizedBox(width: 20),
      pw.Flexible( // Wrap the RichText widget with Flexible
        child: pw.RichText(
          text: pw.TextSpan(
            text: note.nazev != null ? '${note.nazev} - ' : ' ',
            style: pw.TextStyle(color: notePrimaryColor, fontWeight: pw.FontWeight.bold),
            children: <pw.TextSpan>[
              pw.TextSpan(
                text: note.popis,
                style: pw.TextStyle(color: notePrimaryColor, fontWeight: pw.FontWeight.normal),
              ),
            ],
          ),
        ),
      ),
    ],
  );

  return a ;

        //DIFFERENT STYLE
  // pw.Text(
  //   note.nazev != null ? '${note.nazev} - ' : ' ',
  //   style: pw.TextStyle(color: notePrimaryColor, fontWeight: pw.FontWeight.bold),
  // ),
  // pw.Flexible( // Wrap the Text widget with Flexible
  // child: pw.Text(note.popis, style: pw.TextStyle(color: notePrimaryColor)),
  // ),
}

pw.Widget _generateHeader() {
  pw.Widget headerWidget;
  PdfColor headerPrimaryColor = myPrimaryColor;
  if (_hideHeader) {
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
    child: pw.Padding( // Add Padding widget here
      padding: const pw.EdgeInsets.all(10.0), // Set inner padding
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.RichText(
                text: pw.TextSpan(
                  text: 'Jméno: ', // Make 'Jméno:' normal
                  style: pw.TextStyle(fontWeight: pw.FontWeight.normal),
                  children: <pw.TextSpan>[
                    pw.TextSpan(
                      text: '${osoba.jmeno} ${osoba.prijmeni}', // Make variables bold
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
              ),
              pw.Text('Datum narození: ${osoba.datumNarozeni?.day.toString().padLeft(2, '0')}.${osoba.datumNarozeni?.month.toString().padLeft(2, '0')}.${osoba.datumNarozeni?.year}'), // Format datumNarozeni
              pw.Text('Číslo pojištění: ${osoba.cisloPojisteni}${osoba.zdravotniPojistovna != null ? ' (${osoba.zdravotniPojistovna})' : ''}'), // Add zdravotniPojistovna if not null
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Adresa: ${osoba.adresa}'),
              pw.Text('Telefonní číslo: ${osoba.telefonniCislo}'),
            ],
          ),
        ],
      ),
    ),
  );

  return headerWidget;
}

generatePDFasSomething( List<String> notes,[List<int> toSkip = const [2]]) async {
    final mSafeFont = await PdfGoogleFonts.nunitoExtraLight();
    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: mSafeFont,
      ),
    );

    pw.Widget headerWidget = _generateHeader();
    List<MemoryZaznam> corrected =[];
    for(int i=0; i<MemoryZaznamHolder().memoryZaznamList.length;i++ ){
      MemoryZaznam tmp = MemoryZaznamHolder().memoryZaznamList[i];
      tmp.idZaznamu = i;
      corrected.add(tmp);
    }
    List<pw.Widget> noteTextWidgets = _generateNotes(corrected);
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