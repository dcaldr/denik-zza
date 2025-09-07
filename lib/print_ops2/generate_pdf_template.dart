import 'package:denik_zza/print_ops2/print_pdf_header.dart';
import 'package:denik_zza/print_ops2/print_pdf_records.dart';
import 'package:denik_zza/print_ops2/pdf_record_row.dart';
import 'package:denik_zza/print_ops2/pdf_header_section.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:logger/logger.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../database/in_memory_structures_tmp/memory_lek.dart';
import '../database/in_memory_structures_tmp/memory_omezeni.dart';
import '../database/in_memory_structures_tmp/memory_osoba.dart';
import '../database/in_memory_structures_tmp/memory_zaznam.dart';
/// Generates a pdf template for the given person WARNING: still missing hiding logic
///
/// The template consists of a header, restrictions, and records.
/// The class doesn't check if the provided inputs match each other,
/// it is the responsibility of the caller to provide the correct data.
class GeneratePdfTemplate {
  late pw.Widget header;
  static const headerPrimaryColor = PdfColor(0, 0, 0);
  static const hiddenColor = PdfColor(0, 0, 0, 0);

  MemoryOsoba? _osoba;
  List<MemoryZaznam>? _zaznamList;
  /// status for the records
  OkCodes _recordStatus = OkCodes.unset;

  set osoba (MemoryOsoba? inOsoba){
    if(inOsoba != _osoba){
      _recordStatus = OkCodes.unset;
    }
    _osoba = inOsoba;
  }

  GeneratePdfTemplate();

  GeneratePdfTemplate.named({
    required MemoryOsoba? osoba,
    List<MemoryZaznam>? zaznamList,
  }) : _zaznamList = zaznamList, _osoba = osoba;

  /// tests if appending is possible or needs to be completely recreated
  ///
  /// returns true if the given wasPrinted flags are in good configuration
  /// Header T -> Records T(all but lasts) - ok
  /// Header T -> Records F - ok
  bool canAppend(){
   if (_osoba == null || !(_osoba?.wasPrinted ?? false)) {
  return false;
}
   // here osoba(header) always printed
    isRecordsOk();
    // if records are broken return false
    if(_recordStatus == OkCodes.broken){
      return false;
    }

    return true;
  }


  /// tests if records aren't blocking appending
  ///
  /// for entire safety it will order the list by time (but it should be already ordered)
  void isRecordsOk(){
    if(_recordStatus != OkCodes.unset){
      return;
    }
    if(_zaznamList == null){
      _recordStatus = OkCodes.unprinted;
      return;
    }

    // if in testing mode check and Logger warn if not ordered
 assert(() {
  var cmpList = List<MemoryZaznam>.from(_zaznamList!);
  _zaznamList!.sort((a, b) => a.casZaznamu!.compareTo(b.casZaznamu!));
  for (int i = 0; i < cmpList.length; i++) {
    if (cmpList[i] != _zaznamList![i]) {
      Logger().w("Records are not ordered by time, where expected in GeneratePdfTemplate");
      return true;
    }
  }
  return true;
}());


    /// order by time of the record (oldest first)
    _zaznamList!.sort((a, b) => a.casZaznamu!.compareTo(b.casZaznamu!));





  /// after finding first true all the rest should be true or its broken
  bool prevItem = _zaznamList!.first.isPrinted;
    for (var item in _zaznamList!) {
      // if isPrinted after some that wasn't printed
      if(item.isPrinted && !prevItem){
        _recordStatus = OkCodes.broken;
        return;
      }
      prevItem = item.isPrinted;
    }


    /// for here : if last item is printed then all are printed
    _recordStatus = prevItem ? OkCodes.printed : OkCodes.unprinted;
  }


/// generates list of pages for pdf from the given person
  Future<List<pw.Page>> getPdfPages({
    required MemoryOsoba osoba,
    List<MemoryOmezeni>? omezeniList,
    List<MemoryLek>? lekList,
    List<MemoryZaznam>? zaznamList,
  }) async {
    // Use new abstractions - header includes restrictions for person
    final headerSection = PersonPdfHeaderSection(osoba, omezeniList: omezeniList, lekList: lekList);
    header = PrintPdfHeader(headerSection).buildHeader();

    // Convert MemoryZaznam to PersonPdfRecordRow
    final recordRows = zaznamList?.map((z) => PersonPdfRecordRow(z)).toList();

    return [
      pw.Page(
        theme: await _loadFonts(),
        build: (pw.Context context) {
          return pw.Column(
            children: [
              header,
              pw.SizedBox(height: 5),
              if (recordRows != null) PrintPdfRecords(recordRows: recordRows).buildRecordsList(recordRows),
            ],
          );
        },
      ),
    ];
  }

  Future<pw.ThemeData> _loadFonts() async {
    return pw.ThemeData.withFont(
      base: pw.Font.ttf(await rootBundle.load('fonts/CourierPrime-Regular.ttf')),
      bold: pw.Font.ttf(await rootBundle.load('fonts/CourierPrime-Bold.ttf')),
      italic: pw.Font.ttf(await rootBundle.load('fonts/CourierPrime-Italic.ttf')),
      boldItalic: pw.Font.ttf(await rootBundle.load('fonts/CourierPrime-BoldItalic.ttf')),
    );
  }
}

abstract class PdfSection {
  pw.Widget buildSection(bool append);
}
enum OkCodes {
  unprinted,
  printed,
  broken,
  unset,
}