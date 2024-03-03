import 'dart:typed_data';

import 'package:denik_zza/print_ops/confirm_print.dart';
import 'package:denik_zza/print_ops/printer_woodoo.dart';
import 'package:denik_zza/print_ops/select_person_to_append.dart';
import 'package:denik_zza/print_ops/select_person_to_print.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../database/in_memory_structures_tmp/memory_osoba.dart';

/// UI for the printing page.
class PageUI extends StatelessWidget {
  PageUI({super.key});

  final PrinterWoodoo printer = PrinterWoodoo();

  /// Navigates to the PDF preview page.
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
              canChangePageFormat: false,
              canChangeOrientation: false,
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
 return Scaffold(
   appBar: AppBar(
     leading: IconButton( // todo : investigate if default appbar has return
       icon: const Icon(Icons.arrow_back),
       //good check prevent returning out of app
       onPressed: Navigator.canPop(context) ? () => Navigator.pop(context) : null,
     ),
     title: const Text('Tisk Centrum'),
   ),
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
                onPressed: () {
                  navigateToPdfPreview(context, myPDF);
                  //ShowConfirmPrintDialog();
                  ConfirmPrint().showConfirmPrintDialog(context, snapshot.requireData);
                },

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
            //print("počet je ${selectedOsoby.length}");
            if (selectedOsoby.isNotEmpty) {
              PrintPack packedPDF =
                  await printer.printSelected(selectedOsoby);

              navigateToPdfPreview(
                  context, packedPDF.finishedDocument.save());
              ConfirmPrint().showConfirmPrintDialog(context,packedPDF);
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
              PrintPack packedPDFOne =
                  await printer.appendPrintOne(selectedOsoba);
              final pdfData = packedPDFOne.finishedDocument.save();
              await Printing.layoutPdf(
                onLayout: (PdfPageFormat format) async => pdfData,
              );
              ConfirmPrint().showConfirmPrintDialog(context,packedPDFOne);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Nebyla vybrána žádná osoba')),
              );
            }
          },
          child: const Text('Vybrat osobu k dostisknutí jejích záznamů'),
        ),
      ],
    ),
  ),
);
  }
}
