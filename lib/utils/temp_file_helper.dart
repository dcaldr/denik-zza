import 'dart:io';
import 'package:path/path.dart' as p;

String uniqueTempName(String baseName) {
  final ts = DateTime.now().toUtc().microsecondsSinceEpoch;
  final safe = baseName.replaceAll(RegExp(r'[^A-Za-z0-9_.-]'), '_');
  return '.tmp_${ts}_$safe';
}

/// Delete temp files in [dir] with optional [prefix] older than [maxAgeDays].
Future<void> cleanupOldTemps(Directory dir, {String prefix = '.tmp_', int maxAgeDays = 7}) async {
  if (!await dir.exists()) return;
  final cutoff = DateTime.now().subtract(Duration(days: maxAgeDays));
  try {
    await for (var entity in dir.list(followLinks: false)) {
      if (entity is File) {
        final name = p.basename(entity.path);
        if (!name.startsWith(prefix)) continue;
        final stat = await entity.stat();
        if (stat.modified.isBefore(cutoff)) {
          try {
            await entity.delete();
          } catch (_) {}
        }
      }
    }
  } catch (_) {}
}
