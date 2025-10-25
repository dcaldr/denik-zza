import 'dart:typed_data';

import 'temp_csv_storage_stub.dart'
    if (dart.library.io) 'temp_csv_storage_io.dart' as impl;

/// Provides platform-aware helpers for storing temporary CSV data.
class TempCsvStorage {
  TempCsvStorage._();

  /// Persists CSV bytes into a temporary file and returns its absolute path.
  static Future<String> writeBytes(
    Uint8List bytes, {
    required String suggestedName,
  }) {
    return impl.writeBytes(bytes, suggestedName: suggestedName);
  }

  /// Removes a file previously created via [writeBytes].
  static Future<void> deleteFile(String path) {
    return impl.deleteFile(path);
  }
}
