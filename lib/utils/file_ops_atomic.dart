import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as p;
import 'package:denik_zza/utils/file_exceptions.dart';

/// Write bytes atomically by writing to a temporary sibling file and renaming.
Future<File> writeBytesAtomic(File target, Uint8List bytes) async {
  final dir = target.parent;
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  final tmp = File(p.join(dir.path, '.tmp_${DateTime.now().microsecondsSinceEpoch}_${p.basename(target.path)}'));
  try {
    await tmp.writeAsBytes(bytes, flush: true);
    // Try rename (atomic on most platforms)
    try {
      return await tmp.rename(target.path);
    } catch (e) {
      // Fallback: copy then delete
      try {
        final copied = await tmp.copy(target.path);
        try {
          await tmp.delete();
        } catch (_) {}
        return copied;
      } catch (e2) {
        throw FileOperationException('Failed to move temp file to target', e2);
      }
    }
  } catch (e) {
    try {
      if (await tmp.exists()) await tmp.delete();
    } catch (_) {}
    throw FileOperationException('Failed to write atomic bytes to ${target.path}', e);
  }
}

/// Copy source to destination using an atomic move into place where possible.
Future<File> copyAtomic(File source, File destination) async {
  if (!await source.exists()) throw FileOperationException('Source file not found: ${source.path}');
  final destDir = destination.parent;
  if (!await destDir.exists()) await destDir.create(recursive: true);

  // Copy to temp in destination directory, then rename
  final tmp = File(p.join(destDir.path, '.tmp_copy_${DateTime.now().microsecondsSinceEpoch}_${p.basename(destination.path)}'));
  try {
    await source.copy(tmp.path);
    try {
      return await tmp.rename(destination.path);
    } catch (e) {
      // rename failed; try copy then delete
      final copied = await tmp.copy(destination.path);
      try {
        await tmp.delete();
      } catch (_) {}
      return copied;
    }
  } catch (e) {
    try {
      if (await tmp.exists()) await tmp.delete();
    } catch (_) {}
    throw FileOperationException('Failed to perform atomic copy to ${destination.path}', e);
  }
}
