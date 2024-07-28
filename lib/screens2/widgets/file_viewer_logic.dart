import 'package:flutter/material.dart';
import 'file_viewer_screen_widget.dart';
import 'package:file_picker/file_picker.dart';

class FileViewerLogic extends StatelessWidget {
  final String? filePath;

  const FileViewerLogic({super.key, this.filePath});

  @override
  Widget build(BuildContext context) {
    return filePath != null && filePath!.isNotEmpty
        ? FileViewerScreen(initialFilePath: filePath!)
        : Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('soubor nenalezen.'),
                ElevatedButton(
                  onPressed: () => _pickFile(context),
                  child: const Text('nahrát soubor '),
                ),
              ],
            ),
          );
  }

  Future<void> _pickFile(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.path != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => FileViewerLogic(filePath: result.files.single.path),
        ),
      );
    }
  }
}