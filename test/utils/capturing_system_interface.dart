import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:path/path.dart' as path;
import 'package:denik_zza/services/system/system_interface.dart';
import 'package:denik_zza/utils/mode_coordinator.dart';

import 'pdf_page_counter.dart';

class CapturedPdf {
  final Uint8List bytes;
  final String name;
  final int pageCount;
  final int callIndex;
  final DateTime timestamp;
  final String? savedPath;
  final PdfPageFormat format;

  const CapturedPdf({
    required this.bytes,
    required this.name,
    required this.pageCount,
    required this.callIndex,
    required this.timestamp,
    required this.savedPath,
    required this.format,
  });
}

class CapturingSystemInterface implements SystemInterface {
  final List<CapturedPdf> capturedPdfs = [];
  final bool saveToDisk;
  final Directory? outputDir;
  int printCallCount = 0;

  CapturingSystemInterface({
    this.saveToDisk = true,
    this.outputDir,
  });

  CapturedPdf? get lastCaptured {
    if (capturedPdfs.isEmpty) return null;
    return capturedPdfs.last;
  }

  static CapturingSystemInterface forCurrentTest({
    bool saveToDisk = true,
  }) {
    final testDir = ModeCoordinator.currentTestDirectory;
    if (testDir == null) {
      return CapturingSystemInterface(saveToDisk: false);
    }

    final outputDir = Directory(path.join(testDir.path, 'pdf_artifacts'));
    return CapturingSystemInterface(
      saveToDisk: saveToDisk,
      outputDir: outputDir,
    );
  }

  @override
  Future<FilePickerResult?> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    dynamic onFileLoading,
    bool allowMultiple = false,
    bool withData = false,
    bool withReadStream = false,
    bool lockParentWindow = false,
    bool readSequential = false,
  }) async {
    return null;
  }

  @override
  Future<void> printPdf({
    required String name,
    required Future<Uint8List> Function(PdfPageFormat format) onLayout,
    PdfPageFormat format = PdfPageFormat.standard,
    bool usePrinterSettings = false,
    bool dynamicLayout = true,
  }) async {
    final bytes = await onLayout(format);
    final pageCount = countPdfPages(bytes);
    final timestamp = DateTime.now();
    final callIndex = ++printCallCount;

    String? savedPath;
    if (saveToDisk && outputDir != null) {
      if (!outputDir!.existsSync()) {
        outputDir!.createSync(recursive: true);
      }
      final safeName = _sanitizeFileName(name);
        final subdirName =
          'print_${callIndex.toString().padLeft(3, '0')}_$safeName';
      final subdir = Directory(path.join(outputDir!.path, subdirName));
      if (!subdir.existsSync()) {
        subdir.createSync(recursive: true);
      }
      final fileName = '$safeName.pdf';
      final filePath = path.join(subdir.path, fileName);
      final file = File(filePath);
      await file.writeAsBytes(bytes, flush: true);
      savedPath = filePath;
    }

    capturedPdfs.add(CapturedPdf(
      bytes: bytes,
      name: name,
      pageCount: pageCount,
      callIndex: callIndex,
      timestamp: timestamp,
      savedPath: savedPath,
      format: format,
    ));
  }

  static Future<void> cleanupOldArtifacts({
    required String baseDir,
    int keepLast = 5,
  }) async {
    final directory = Directory(baseDir);
    if (!await directory.exists()) return;
    final entities = await directory.list().toList();
    final directories = entities.whereType<Directory>().toList();

    if (directories.isNotEmpty) {
      directories.sort(
        (a, b) => b.path.compareTo(a.path),
      );

      for (var i = keepLast; i < directories.length; i++) {
        await directories[i].delete(recursive: true);
      }
      return;
    }

    final files = entities.whereType<File>().toList();
    files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));

    for (var i = keepLast; i < files.length; i++) {
      await files[i].delete();
    }
  }

  String _sanitizeFileName(String input) {
    final sanitized = input.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]+'), '_');
    return sanitized.isEmpty ? 'print' : sanitized;
  }
}
