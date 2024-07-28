import 'package:flutter/material.dart';
import 'file_viewer_logic.dart';
import 'package:file_picker/file_picker.dart';

class FileUploader extends StatefulWidget {
  const FileUploader({super.key});

  @override
  _FileUploaderState createState() => _FileUploaderState();
}

class _FileUploaderState extends State<FileUploader> {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('File Uploader'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _pickFile,
              child: const Text('nahrát soubor'),
            ),
            if (_filePath != null)
              Flexible(
                fit: FlexFit.loose,
                child: FileViewerLogic(filePath: _filePath),
              ),
          ],
        ),
      ),
    );
  }
}