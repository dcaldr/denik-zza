import 'package:flutter/material.dart';
import 'package:denik_zza/utils/app_logger.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:printing/printing.dart';
import 'dart:io';

class FileViewerScreen extends StatefulWidget {
  final String initialFilePath;

  const FileViewerScreen({super.key, required this.initialFilePath});

  @override
  State<FileViewerScreen> createState() => _FileViewerScreenState();
}

class _FileViewerScreenState extends State<FileViewerScreen> {
  late String filePath;
  final Logger _logger = AppLogger.l;

  @override
  void initState() {
    super.initState();
    filePath = widget.initialFilePath;
    _logger.i('filePath in init: $filePath');
  }

  void updateFilePath(String newFilePath) {
    setState(() {
      filePath = newFilePath;
      _logger.i('filePath in update: $filePath');
    });
  }

  @override
  Widget build(BuildContext context) {
    final String extension = path.extension(filePath).toLowerCase();
    _logger.i('extension: $extension');

    return Scaffold(
      body: _buildView(extension),
    );
  }

  Widget _buildView(String extension) {
    if (extension == '.pdf') {
      return _buildPDFView();
    } else if (extension == '.jpg' ||
        extension == '.jpeg' ||
        extension == '.png') {
      return _buildImageView();
    } else {
      return const Center(child: Text('Unsupported file type'));
    }
  }

  Widget _buildPDFView() {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height /
            1.3, //note: eye balling the height
        maxWidth: MediaQuery.of(context).size.width / 2,
      ),
      child: PdfPreview(
        build: (format) => File(filePath).readAsBytesSync(),
        maxPageWidth: MediaQuery.of(context).size.width * 4,
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
