import 'package:denik_zza/database/in_memory_structures_tmp/memory_zaznam.dart';
import 'package:denik_zza/print_ops/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../database/database_interface.dart';
import '../database/database_wrapper.dart';
import '../database/in_memory_structures_tmp/memory_osoba.dart';


class PrinterWoodoo{
final PDFGenerator _pdfGeneratorAll = PDFGenerator();
final PDFGenerator _pdfGeneratorAppend = PDFGenerator(append: true);
PDFGenerator selectedGenerator = PDFGenerator();
DatabaseInterface db = DatabaseWrapper.getDatabase();



  Future<PrintPack> printAll() async {

  // 1) get all persons from database
    List<MemoryOsoba> seznamOsob = await db.getParticipantsByPinnedEvent();
  // 2) printSelected() for each person
  return  printSelected(seznamOsob);
  // 3) _sendToPrinter() resulting file // doing outside of this class
  }
Future<PrintPack> printSelected(List<MemoryOsoba> seznamOsob ) async {
    selectedGenerator = _pdfGeneratorAll;
    // change all [wasPrinted] to false -> so all are printed
    // no need to copy the list, if fails it won't be updated
return _convertor(seznamOsob);


  }

Future<PrintPack> appendPrintOne(MemoryOsoba osoba) async {
selectedGenerator = _pdfGeneratorAppend;
return _convertor([osoba]);

}
Future<PrintPack> _convertor (List<MemoryOsoba> seznamOsob) async {
  final mSafeFont = await PdfGoogleFonts.nunitoExtraLight();

  final pdf = pw.Document(
    //TODO:add metadata
    theme: pw.ThemeData.withFont(
      base: mSafeFont,
      fontFallback: [mSafeFont],
  )
  );

    List <pw.Page> skelets = [];
    for (MemoryOsoba osoba in seznamOsob) {
      List<MemoryZaznam> zaznamy = await db.getRecordsByParticipantID(osoba.id);
      skelets.add( await selectedGenerator.generatePDFSkeleton(osoba : osoba, zaznamy: zaznamy));
    }
   // merge all documents to one

    for (pw.Page skelet in skelets) {
      pdf.addPage(skelet);
    }
    return  PrintPack(finishedDocument: pdf, osoby: seznamOsob);
    // send to printer

}
Future<List<MemoryOsoba>> getOsobyForPrint(){
    return  db.getParticipantsByPinnedEvent();
}





}
class PrintPack{
  pw.Document finishedDocument;
   List<MemoryOsoba> osoby;

  PrintPack({required this.finishedDocument, required this.osoby});
}