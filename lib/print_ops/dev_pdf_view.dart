import 'package:denik_zza/database/dummy_data.dart';
import 'package:denik_zza/print_ops/pdf.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../main.dart';

class DevPdfView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PDF Preview"),
      ),
      body: PdfPreview(
        build: (format) async => await PDFGenerator().generatePDFasSomething( notes)/* .save() */, // again hardcded
        allowSharing: true,
        allowPrinting: true,
        initialPageFormat: PdfPageFormat.a4,
        maxPageWidth: MediaQuery.of(context).size.height / 1.6, // hard coded -by hand
        pdfFileName: "sample.pdf",
      ),
    );
  }
}