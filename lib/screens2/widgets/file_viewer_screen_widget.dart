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
    // Use LayoutBuilder for parent-relative sizing.
    // MediaQuery.of(context).size gives global screen size, not available space.
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: constraints.maxHeight * 0.8,
            maxWidth: constraints.maxWidth * 0.9,
          ),
          child: PdfPreview(
            build: (format) => File(filePath).readAsBytesSync(),
            maxPageWidth: constraints.maxWidth * 2,
          ),
        );
      },
    );
  }

  Widget _buildImageView() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return InteractiveViewer(
          minScale: 0.2,
          maxScale: 10,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: constraints.maxHeight,
              maxWidth: constraints.maxWidth,
            ),
            child: Image.file(
              File(filePath),
              fit: BoxFit.contain,
            ),
          ),
        );
      },
    );
  }
}
