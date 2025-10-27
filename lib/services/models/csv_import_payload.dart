import 'dart:typed_data';

/// Describes the selected CSV input in a way that supports both offline files
/// and in-memory uploads.
///
/// Widgets use this payload instead of passing raw paths so the import flow can
/// remain offline-capable across platforms.
class CsvImportPayload {
  CsvImportPayload._({
    required this.displayName,
    this.path,
    this.bytes,
  }) {
    // Validate that we have either bytes or path, but not both empty
    if (bytes != null && bytes!.isEmpty) {
      throw ArgumentError('Bytes cannot be empty');
    }
    if (path != null && path!.isEmpty) {
      throw ArgumentError('Path cannot be empty string');
    }
    if (bytes == null && path == null) {
      throw ArgumentError('Either bytes or path must be provided');
    }
    if (bytes == null && (path == null || path!.isEmpty)) {
      throw ArgumentError('Must provide either valid bytes or valid path');
    }
  }

  /// Short label surfaced in the UI, typically the original filename.
  final String displayName;

  /// Absolute filesystem path for the CSV when available.
  final String? path;

  /// Raw CSV bytes when the file originates from an in-memory source (e.g. web).
  final Uint8List? bytes;

  /// True when the payload carries in-memory bytes instead of a path.
  bool get isBytes => bytes != null && bytes!.isNotEmpty;

  /// True when the payload references a persisted file path.
  bool get hasPath => path != null && path!.isNotEmpty;

  /// Creates a payload representing a file available on disk.
  factory CsvImportPayload.fromPath({
    required String path,
    required String displayName,
  }) {
    return CsvImportPayload._(
      displayName: displayName,
      path: path,
    );
  }

  /// Creates a payload backed by in-memory bytes (e.g. browser uploads).
  factory CsvImportPayload.fromBytes({
    required Uint8List bytes,
    required String displayName,
  }) {
    return CsvImportPayload._(
      displayName: displayName,
      bytes: bytes,
    );
  }
}
