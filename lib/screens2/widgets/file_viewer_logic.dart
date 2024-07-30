import 'package:flutter/material.dart';
import 'file_viewer_screen_widget.dart';
import 'package:file_picker/file_picker.dart';

class FileViewerLogic extends StatefulWidget {
  const FileViewerLogic({super.key});

  @override
  _FileViewerLogicState createState() => _FileViewerLogicState();
}

class _FileViewerLogicState extends State<FileViewerLogic> {
  String? _filePath;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.path != null) {
      setState(() {
        _filePath = result.files.single.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _filePath != null && _filePath!.isNotEmpty
        ? FileViewerScreen(initialFilePath: _filePath!)
        : Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('soubor nenalezen.'),
                ElevatedButton(
                  onPressed: _pickFile,
                  child: const Text('nahrát soubor'),
                ),
              ],
            ),
          );
  }
}