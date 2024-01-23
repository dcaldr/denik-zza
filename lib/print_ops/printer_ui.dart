import 'dart:typed_data';

import 'package:denik_zza/print_ops/printer_woodoo.dart';
import 'package:denik_zza/print_ops/select_person_to_append.dart';
import 'package:denik_zza/print_ops/select_person_to_print.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../database/in_memory_structures_tmp/memory_osoba.dart';
import 'dev_pdf_view.dart';

class PageUI extends StatelessWidget {
  PageUI({super.key});
  final PrinterWoodoo printer = PrinterWoodoo();

  void navigateToPdfPreview(BuildContext context, Future<Uint8List> myPDF) {
    myPDF.then((value) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: const Text("Náhled PDF prosím zvolte tisk z menu"),
            ),
            body: PdfPreview(
              build: (format) async => value,
              allowSharing: true,
              allowPrinting: true,
              initialPageFormat: PdfPageFormat.a4,
              maxPageWidth: MediaQuery.of(context).size.height / 1.6,
              pdfFileName: "sample.pdf",
            ),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tisknutí',
      home: Builder(
        // Add Builder here
        builder: (BuildContext context) => Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FutureBuilder<PrintPack>(
                  future: printer.printAll(),
                  builder: (BuildContext context,
                      AsyncSnapshot<PrintPack> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      var myPDF = snapshot.data!.finishedDocument.save();
                      return ElevatedButton(
                        onPressed: () => navigateToPdfPreview(context, myPDF),
                        child: const Text('tisk všech osob'),
                      );
                    }
                  },
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    List<MemoryOsoba> selectedOsoby = await showOsobyDialog(
                        context, printer.getOsobyForPrint());
                    print("počet je ${selectedOsoby.length}");
                    if (selectedOsoby.isNotEmpty) {
                      PrintPack packedPDF =
                          await printer.printSelected(selectedOsoby);

                      navigateToPdfPreview(
                          context, packedPDF.finishedDocument.save());
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Nebyly vybrány žádné osoby')),
                      );
                    }
                  },
                  child: const Text('dotisk chybějících/vybraných osob'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    MemoryOsoba? selectedOsoba = await showSingleOsobaDialog(
                        context, printer.getOsobyForAppend());
                    if (selectedOsoba != null) {
                      PrintPack packedPDFOne = await printer.appendPrintOne(selectedOsoba);
                      final pdfData = packedPDFOne.finishedDocument.save();
                      await Printing.layoutPdf(
                        onLayout: (PdfPageFormat format) async => pdfData,
                      );



                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Nebyla vybrána žádná osoba')),
                      );
                    }
                  },
                  child: const Text('Přidat osobu'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
