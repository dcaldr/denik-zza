import 'package:denik_zza/print_ops2/print_pdf_header.dart';
import 'package:denik_zza/print_ops2/print_pdf_records.dart';
import 'package:denik_zza/print_ops2/print_pdf_restrictions.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../database/in_memory_structures_tmp/memory_lek.dart';
import '../database/in_memory_structures_tmp/memory_omezeni.dart';
import '../database/in_memory_structures_tmp/memory_osoba.dart';
import '../database/in_memory_structures_tmp/memory_zaznam.dart';

class GeneratePdfTemplate {
  late pw.Widget header;
  static const headerPrimaryColor = PdfColor(0, 0, 0);
  static const hiddenColor = PdfColor(0, 0, 0, 0);

  MemoryOsoba? osoba;
  List<Omezeni>? omezeniList;
  List<MemoryLek>? lekList;
  List<MemoryZaznam>? zaznamList;

  GeneratePdfTemplate();
/// Constructor for storing data
  GeneratePdfTemplate.named({
    required this.osoba,
    this.omezeniList,
    this.lekList,
    this.zaznamList,
  });

  Future<pw.Document> getPdfWidget({
    required MemoryOsoba osoba,
    List<Omezeni>? omezeniList,
    List<MemoryLek>? lekList,
    List<MemoryZaznam>? zaznamList,
  }) async {
    header = PrintPdfHeader().buildHeader(osoba);
    final restrictions = _buildRestrictions(omezeniList, lekList);

    return pw.Document(
      theme: await _loadFonts(),
    )..addPage(
        pw.Page(
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
      );
  }

  pw.Widget? _buildRestrictions(List<Omezeni>? omezeniList, List<MemoryLek>? lekList) {
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