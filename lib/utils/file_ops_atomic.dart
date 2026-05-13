import 'dart:io';
import 'dart:typed_data';
import 'dart:async';
import 'package:path/path.dart' as p;
import 'package:denik_zza/utils/file_exceptions.dart';
import 'package:denik_zza/utils/temp_file_helper.dart';

/// Write bytes atomically by writing to a temporary sibling file and renaming.
Future<File> writeBytesAtomic(File target, Uint8List bytes) async {
  final dir = target.parent;
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }

  const int maxAttempts = 3;
  int attempt = 0;
  int delayMs = 50;

  while (true) {
    attempt++;
    final tmp = File(p.join(dir.path, uniqueTempName(p.basename(target.path))));
    try {
      await tmp.writeAsBytes(bytes, flush: true);
      // Try rename (atomic on most platforms)
      try {
        return await tmp.rename(target.path);
      } catch (e) {
        // Fallback: write directly to the final path, then remove the temp file.
        try {
          final written = await target.writeAsBytes(bytes, flush: true);
          try {
            if (await tmp.exists()) await tmp.delete();
          } catch (_) {}
          return written;
        } catch (e2) {
          throw FileOperationException('Failed to move temp file to target', e2);
        }
      }
    } catch (e) {
      try {
        if (await tmp.exists()) await tmp.delete();
      } catch (_) {}
      if (attempt >= maxAttempts) {
        throw FileOperationException('Failed to write atomic bytes to ${target.path}', e);
      }
      // backoff and retry
      await Future.delayed(Duration(milliseconds: delayMs));
      delayMs *= 2;
    }
  }
}

/// Copy source to destination using an atomic move into place where possible.
Future<File> copyAtomic(File source, File destination) async {
  if (!await source.exists()) throw FileOperationException('Source file not found: ${source.path}');
  final destDir = destination.parent;
  if (!await destDir.exists()) await destDir.create(recursive: true);

  const int maxAttempts = 3;
  int attempt = 0;
  int delayMs = 50;

  while (true) {
    attempt++;
    final tmp = File(p.join(destDir.path, uniqueTempName('copy_${p.basename(destination.path)}')));
    try {
      await source.copy(tmp.path);
      try {
        return await tmp.rename(destination.path);
      } catch (e) {
        // rename failed; fall back to a direct copy from the source file.
        final copied = await source.copy(destination.path);
        try {
          if (await tmp.exists()) await tmp.delete();
        } catch (_) {}
        return copied;
      }
    } catch (e) {
      try {
        if (await tmp.exists()) await tmp.delete();
      } catch (_) {}
      if (attempt >= maxAttempts) {
        throw FileOperationException('Failed to perform atomic copy to ${destination.path}', e);
      }
      await Future.delayed(Duration(milliseconds: delayMs));
      delayMs *= 2;
    }
  }
}
