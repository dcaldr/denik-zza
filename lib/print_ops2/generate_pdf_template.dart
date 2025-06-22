import 'package:denik_zza/print_ops2/print_pdf_header.dart';
import 'package:denik_zza/print_ops2/print_pdf_records.dart';
import 'package:denik_zza/print_ops2/print_pdf_restrictions.dart';
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
  List<MemoryOmezeni>? _omezeniList;
  List<MemoryLek>? _lekList;
  List<MemoryZaznam>? _zaznamList;
  /// status for the restrictions
  OkCodes _omezeniStatus =OkCodes.unset;
  /// status for the medications
  OkCodes _lekStatus = OkCodes.unset;
  /// status for both restrictions and medications
  OkCodes _allRestrictionsStatus = OkCodes.unset;
/// status for the records
  OkCodes _recordStatus = OkCodes.unset;

  set osoba (MemoryOsoba? inOsoba){
    if(inOsoba != _osoba){
      _omezeniStatus = OkCodes.unset;
      _lekStatus = OkCodes.unset;
      _allRestrictionsStatus = OkCodes.unset;
      _recordStatus = OkCodes.unset;
    }
    osoba = _osoba;
  }
  set omezeniList (List<MemoryOmezeni>? inOmezeniList){
      _omezeniStatus = OkCodes.unset;
      _allRestrictionsStatus = OkCodes.unset;
    omezeniList = _omezeniList;
  }
  set lekList (List<MemoryLek>? inLekList){
      _lekStatus = OkCodes.unset;
      _allRestrictionsStatus = OkCodes.unset;
    lekList = _lekList;
  }

  GeneratePdfTemplate();

  GeneratePdfTemplate.named({
    required MemoryOsoba? osoba,
    List<MemoryOmezeni>? omezeniList,
    List<MemoryLek>? lekList,
    List<MemoryZaznam>? zaznamList,
  }) : _zaznamList = zaznamList, _lekList = lekList, _omezeniList = omezeniList, _osoba = osoba;

  /// tests if appending is possible or needs to be completely recreated
  ///
  /// returns true if the given wasPrinted flags are in good configuration
  /// Header T -> Restrictions(all) T -> Records T(all but lasts) - ok
  /// Header T -> Restrictions(all) F -> Records F - ok
  /// Header T -> Restrictions(some) F -> Records T - not ok
  bool canAppend(){
   if (_osoba == null || !(_osoba?.wasPrinted ?? false)) {
  return false;
}
   // here osoba(header) always printed
    isRestrictionsOk();
    isRecordsOk();
    // if any is broken return false
    if(_allRestrictionsStatus == OkCodes.broken || _recordStatus == OkCodes.broken){
      return false;
    }

    // restriction block - false && records block - false --> ok
    if(_allRestrictionsStatus == OkCodes.unprinted && _recordStatus == OkCodes.unprinted){
      return true;
    }
    // restriction block - true && records block - true --> ok
    if(_allRestrictionsStatus == OkCodes.printed && _recordStatus == OkCodes.printed){
      return true;
    }

    return false;
  }


/// tests if restrictions and medications aren't blocking appending
  void isRestrictionsOk(){
    // preventive
    // if(_allRestrictionsStatus != OkCodes.unset){
    //   return;
    // }
    if (_omezeniStatus == OkCodes.unset) {
      bool start = _omezeniList!.first.wasPrinted;
      for (var item in _omezeniList!) {
        // if start changes value return broken
        if(start != item.wasPrinted){
          _omezeniStatus = OkCodes.broken;
          return;
        }
      }
       _omezeniStatus = start ? OkCodes.printed : OkCodes.unprinted;
    }
    if (_lekStatus == OkCodes.unset) {
      bool start = _lekList!.first.wasPrinted;
      for (var item in _lekList!) {
        // if start changes value return broken
        if(start != item.wasPrinted){
          _lekStatus = OkCodes.broken;
          return;
        }
      }
       _lekStatus = start ? OkCodes.printed : OkCodes.unprinted;
    }
    /// either both are the same or are broken
    _allRestrictionsStatus = _omezeniStatus == _lekStatus ? _omezeniStatus : OkCodes.broken;


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
    bool start = _zaznamList!.first.isPrinted;
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
    header = PrintPdfHeader().buildHeader(osoba);
    final restrictions = _buildRestrictions(omezeniList, lekList);

    return [
      pw.Page(
        theme: await _loadFonts(),
        build: (pw.Context context) {
          return pw.Column(
            children: [
              header,
              pw.SizedBox(height: 5),
              if (restrictions != null) restrictions,
              if (restrictions != null) pw.SizedBox(height: 5),
              if (zaznamList != null) PrintPdfRecords().buildRecordsList(zaznamList),
            ],
          );
        },
      ),
    ];
  }

  pw.Widget? _buildRestrictions(List<MemoryOmezeni>? omezeniList, List<MemoryLek>? lekList) {
    if (omezeniList != null && lekList != null) {
      return PrintPdfRestrictions().buildRestrictions(omezeniList, lekList);
    }
    return null;
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