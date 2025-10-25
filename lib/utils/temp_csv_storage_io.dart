import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

Future<String> writeBytes(Uint8List bytes, {required String suggestedName}) async {
  final Directory tempDir = await getTemporaryDirectory();
  final String sanitized = _sanitizeFileName(suggestedName);
  final String resolvedName = sanitized.isEmpty ? 'import.csv' : sanitized;
  final File target = File(path.join(tempDir.path, resolvedName));
  await target.writeAsBytes(bytes, flush: true);
  return target.path;
}

Future<void> deleteFile(String filePath) async {
  final File file = File(filePath);
  if (await file.exists()) {
    try {
      await file.delete();
    } catch (_) {
      // Swallow deletion errors; temporary files may be cleaned up by the OS later.
    }
  }
}

String _sanitizeFileName(String input) {
  final String trimmed = input.trim();
  if (trimmed.isEmpty) {
    return '';
  }
  final String withoutSeparators = trimmed.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
  return withoutSeparators.endsWith('.csv') ? withoutSeparators : '$withoutSeparators.csv';
}
