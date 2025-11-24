import 'dart:io';

import 'package:flutter/material.dart';
import '../../input/file_manager.dart';
import 'file_viewer_screen_widget.dart';
import 'package:file_picker/file_picker.dart';

class FileViewerLogic extends StatefulWidget {
  final Function(String) onFileUploaded;

  const FileViewerLogic({super.key, required this.onFileUploaded});

  @override
  _FileViewerLogicState createState() => _FileViewerLogicState();
}

class _FileViewerLogicState extends State<FileViewerLogic> {
  String? _filePath;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.path != null) {
      final pickedFile = File(result.files.single.path!);
      setState(() {
        _filePath = pickedFile.path;
      });
      final newFilePath = await FileManager().putZpusobilost(pickedFile);
      if (newFilePath != null) {
        widget.onFileUploaded(newFilePath);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _filePath != null && _filePath!.isNotEmpty
        ? FileViewerScreen(initialFilePath: _filePath!)
        : LayoutBuilder(
            builder: (context, constraints) {
              // If height is too small, show a simplified version
              if (constraints.maxHeight < 60) {
                return const Center(
                  child: Text(
                    'no file',
                    style: TextStyle(fontSize: 10),
                    textAlign: TextAlign.center,
                  ),
                );
              }

              // For normal heights, wrap in SingleChildScrollView to prevent overflow
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('soubor nenalezen.'),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _pickFile,
                          child: const Text('nahrát soubor'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
  }
}
