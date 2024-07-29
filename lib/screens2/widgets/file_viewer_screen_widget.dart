import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:printing/printing.dart';
import 'dart:io';

class FileViewerScreen extends StatefulWidget {
  final String initialFilePath;

  const FileViewerScreen({super.key, required this.initialFilePath});

  @override
  _FileViewerScreenState createState() => _FileViewerScreenState();
}

class _FileViewerScreenState extends State<FileViewerScreen> {
  late String filePath;

  @override
  void initState() {
    super.initState();
    filePath = widget.initialFilePath;
  }

  void updateFilePath(String newFilePath) {
    setState(() {
      filePath = newFilePath;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String extension = path.extension(filePath).toLowerCase();

    return Scaffold(
      body: _buildView(extension),
    );
  }

  Widget _buildView(String extension) {
    if (extension == '.pdf') {
      return _buildPDFView();
    } else if (extension == '.jpg' || extension == '.jpeg' || extension == '.png') {
      return _buildImageView();
    } else {
      return const Center(child: Text('Unsupported file type'));
    }
  }

  Widget _buildPDFView() {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height,
      ),
      child: PdfPreview(
        build: (format) => File(filePath).readAsBytesSync(),
      ),
    );
  }

  Widget _buildImageView() {
    return InteractiveViewer(
      minScale: 0.2,
      maxScale: 10,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height,
        ),
        child: Image.file(
          File(filePath),
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}