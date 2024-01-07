import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:typed_data';

class DevPdfView extends StatefulWidget {
  final pw.Document pdf;

  const DevPdfView({required this.pdf, super.key});

  @override
  _DevPdfViewState createState() => _DevPdfViewState();
}

class _DevPdfViewState extends State<DevPdfView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PDF Preview"),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: _displayPdf,
              child: const Text('Display PDF'),
            ),
          ],
        ),
      ),
    );
  }

  void _displayPdf() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PreviewScreen(pdf: widget.pdf)),
    );
  }
}

class PreviewScreen extends StatelessWidget {
  final pw.Document pdf;

  const PreviewScreen({required this.pdf, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_outlined),
        ),
        centerTitle: true,
        title: const Text("Preview"),
      ),
      body: PdfPreview(
        build: (format) async => pdf.save(),
        allowSharing: true,
        allowPrinting: true,
        initialPageFormat: PdfPageFormat.a4,
        pdfFileName: "sample.pdf",
      ),
    );
  }
}
