import 'dart:io';
import 'dart:typed_data';
import 'dart:async';
import 'dart:math';
import 'package:path/path.dart' as p;
import 'package:denik_zza/utils/file_exceptions.dart';
import 'package:denik_zza/utils/temp_file_helper.dart';

/// Write bytes atomically by writing to a temporary sibling file and renaming.
Future<File> writeBytesAtomic(File target, Uint8List bytes) async {
  final dir = target.parent;
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }

  const int maxAttempts = 5;
  int attempt = 0;
  int delayMs = 50;
  final rand = Random();

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
          // If this was a permission error, throw a specific exception
          if (e2 is FileSystemException && _isPermissionError(e2)) {
            throw PermissionDeniedException('Permission denied while moving temp file to target', e2);
          }
          throw FileOperationException('Failed to move temp file to target', e2);
        }
      }
    } catch (e) {
      try {
        if (await tmp.exists()) await tmp.delete();
      } catch (_) {}
      // Non-retryable permission errors should bubble up immediately
      if (e is FileSystemException && _isPermissionError(e)) {
        throw PermissionDeniedException('Permission denied writing atomic bytes to ${target.path}', e);
      }
      if (attempt >= maxAttempts) {
        throw FileOperationException('Failed to write atomic bytes to ${target.path}', e);
      }
      // Exponential backoff with jitter
      final jitter = (rand.nextDouble() * 0.5 + 0.75); // 0.75x - 1.25x
      final waitMs = (delayMs * jitter).toInt();
      await Future.delayed(Duration(milliseconds: waitMs));
      delayMs = (delayMs * 2).clamp(50, 1000).toInt();
    }
  }
}

/// Copy source to destination using an atomic move into place where possible.
Future<File> copyAtomic(File source, File destination) async {
  if (!await source.exists()) throw FileOperationException('Source file not found: ${source.path}');
  final destDir = destination.parent;
  if (!await destDir.exists()) await destDir.create(recursive: true);

  const int maxAttempts = 5;
  int attempt = 0;
  int delayMs = 50;
  final rand = Random();

  while (true) {
    attempt++;
    final tmp = File(p.join(destDir.path, uniqueTempName('copy_${p.basename(destination.path)}')));
    try {
      await source.copy(tmp.path);
      try {
        return await tmp.rename(destination.path);
      } catch (e) {
        // rename failed; fall back to a direct copy from the source file.
        try {
          final copied = await source.copy(destination.path);
          try {
            if (await tmp.exists()) await tmp.delete();
          } catch (_) {}
          return copied;
        } catch (e2) {
          if (e2 is FileSystemException && _isPermissionError(e2)) {
            throw PermissionDeniedException('Permission denied during atomic copy to ${destination.path}', e2);
          }
          throw FileOperationException('Failed to perform atomic copy to ${destination.path}', e2);
        }
      }
    } catch (e) {
      try {
        if (await tmp.exists()) await tmp.delete();
      } catch (_) {}
      if (e is FileSystemException && _isPermissionError(e)) {
        throw PermissionDeniedException('Permission denied during atomic copy to ${destination.path}', e);
      }
      if (attempt >= maxAttempts) {
        throw FileOperationException('Failed to perform atomic copy to ${destination.path}', e);
      }
      final jitter = (rand.nextDouble() * 0.5 + 0.75);
      final waitMs = (delayMs * jitter).toInt();
      await Future.delayed(Duration(milliseconds: waitMs));
      delayMs = (delayMs * 2).clamp(50, 1000).toInt();
    }
  }
}

bool _isPermissionError(FileSystemException e) {
  final osErr = e.osError;
  if (osErr != null) {
    final msg = (osErr.message ?? '').toLowerCase();
    if (msg.contains('permission') || msg.contains('access denied') || osErr.errorCode == 13) {
      return true;
    }
  }
  final message = (e.message ?? '').toLowerCase();
  if (message.contains('permission') || message.contains('access denied')) return true;
  return false;
}
