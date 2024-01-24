import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

/// The main entry point for the Flutter application.
void main() {
  runApp(MyApp());
}

/// The root widget of the application.
class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey<ScaffoldMessengerState>();



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      scaffoldMessengerKey: _scaffoldKey,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Demo Home Page'),
        ),
        body: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Column(
                children: <Widget>[
                  FutureBuilder<PrintingInfo>(
                    future: Printing.info(),
                    builder: (BuildContext context, AsyncSnapshot<PrintingInfo> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        return Text('Printing Info: ${snapshot.data}');
                      }
                    },
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final pdf = pw.Document();

                      pdf.addPage(
                        pw.Page(
                          build: (pw.Context context) => pw.Center(
                            child: pw.Text('Hello World', style: const pw.TextStyle(fontSize: 40)),
                          ),
                        ),
                      );

                      final bytes = await pdf.save();

                      try {
                        await Printing.layoutPdf(
                          onLayout: (PdfPageFormat format) async => bytes,
                        );
                        _scaffoldKey.currentState!.showSnackBar(
                          const SnackBar(content: Text('Printing succeeded')),
                        );

                        final directory = await getApplicationDocumentsDirectory();
                        final file = File('${directory.path}/print_log.txt');
                        await file.writeAsString('Printing succeeded\n', mode: FileMode.append);
                      } catch (e) {
                        _scaffoldKey.currentState!.showSnackBar(
                          SnackBar(content: Text('Printing failed: $e')),
                        );

                        final directory = await getApplicationDocumentsDirectory();
                        final file = File('${directory.path}/print_log.txt');
                        await file.writeAsString('Printing failed: $e\n', mode: FileMode.append);
                      }
                    },
                    child: const Text('Print Hello, World!'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final pdf = pw.Document();

                      pdf.addPage(
                        pw.Page(
                          build: (pw.Context context) => pw.Center(
                            child: pw.Text('Hello World', style: const pw.TextStyle(fontSize: 40)),
                          ),
                        ),
                      );
                      pdf.addPage(
                        pw.Page(
                          build: (pw.Context context) => pw.Center(
                            child: pw.Text('Hello World', style: const pw.TextStyle(fontSize: 40)),
                          ),
                        ),
                      );

                      final bytes = await pdf.save();

                      try {
                        final printers = await Printing.listPrinters();
                        final defaultPrinter = printers.firstWhere((p) => p.isDefault);

                        await Printing.directPrintPdf(
                          printer: defaultPrinter,
                          onLayout: (PdfPageFormat format) async => bytes,
                        );
                        _scaffoldKey.currentState!.showSnackBar(
                          const SnackBar(content: Text('Direct printing succeeded')),
                        );

                        final directory = await getApplicationDocumentsDirectory();
                        final file = File('${directory.path}/print_log.txt');
                        final printerInfo = printers.map((p) => 'Name: ${p.name}, URL: ${p.url}, Available: ${p.isAvailable}, Default: ${p.isDefault}').join('\n');
                        await file.writeAsString('Direct printing succeeded\n$printerInfo', mode: FileMode.append);
                      } catch (e) {
                        _scaffoldKey.currentState!.showSnackBar(
                          SnackBar(content: Text('Direct printing failed: $e')),
                        );

                        final directory = await getApplicationDocumentsDirectory();
                        final file = File('${directory.path}/print_log.txt');
                        await file.writeAsString('Direct printing failed: $e\n', mode: FileMode.append);
                      }
                    },
                    child: const Text('Direct Print Hello, World!'),
                  ),
                ],
              ),
              FutureBuilder<List<Printer>>(
                future: Printing.listPrinters(),
                builder: (BuildContext context, AsyncSnapshot<List<Printer>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return Column(
                      children: snapshot.data!.map((printer) => RichText(
                        text: TextSpan(
                          style: DefaultTextStyle.of(context).style,
                          children: [
                            TextSpan(
                              text: printer.name,
                              style: DefaultTextStyle.of(context).style.copyWith(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text: ' - URL: ${printer.url}, Available: ${printer.isAvailable}',
                            ),
                          ],
                        ),
                      )).toList(),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
