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
//TODO: ref: file name
class GeneratePdfTemplate {
  late pw.Widget header;
  static const headerPrimaryColor = PdfColor(0, 0, 0);

  getPdfWidget(MemoryOsoba osoba, {List<Omezeni>? omezeniList, List<MemoryLek>? lekList, List<MemoryZaznam>? zaznamList}) async {
    header = PrintPdfHeader().buildHeader(osoba);
    pw.Widget? restrictions;

    if (omezeniList != null && lekList != null) {
      restrictions = PrintPdfRestrictions().buildRestrictions(omezeniList, lekList);
    }

    return pw.Document(
      theme: pw.ThemeData.withFont(
        base: pw.Font.ttf(await rootBundle.load('fonts/CourierPrime-Regular.ttf')),
        bold: pw.Font.ttf(await rootBundle.load('fonts/CourierPrime-Bold.ttf')),
        italic: pw.Font.ttf(await rootBundle.load('fonts/CourierPrime-Italic.ttf')),
        boldItalic: pw.Font.ttf(await rootBundle.load('fonts/CourierPrime-BoldItalic.ttf')),
      ),
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
}

abstract class PdfSection {
  pw.Widget buildSection(bool append);
}