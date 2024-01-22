import 'package:denik_zza/print_ops/printer_woodoo.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'dev_pdf_view.dart';

class PageUI extends StatelessWidget {
  PageUI({super.key});
  final PrinterWoodoo printer = PrinterWoodoo();


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tisknutí',
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FutureBuilder<PrintPack>(
                future: printer.printAll(),
                builder: (BuildContext context, AsyncSnapshot<PrintPack> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator(); // Show a loading spinner while waiting
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}'); // Show error if something went wrong
                  } else {
                    var myPDF = snapshot.data!.finishedDocument.save();
                    return ElevatedButton(
                      onPressed: () {
                        myPDF.then((value) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) =>
                                PdfPreview(build: (format) async => value,
                                  allowSharing: true,
                                  allowPrinting: true,
                                  initialPageFormat: PdfPageFormat.a4,
                                  maxPageWidth: MediaQuery.of(context).size.height / 1.6, // hard coded -by hand
                                  pdfFileName: "sample.pdf",)),
                          );
                        });
                      },
                      child: Text('tisk všecho'),
                    );
                  }
                },
              ),
              SizedBox(height: 10), // Add space between buttons
              ElevatedButton(
                onPressed: () {},
                child: Text('dotisk'),
              ),
              SizedBox(height: 10), // Add space between buttons
              ElevatedButton(
                onPressed: null, // Make this button non-clickable
                child: Text('neimplementováno'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}