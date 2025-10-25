import 'dart:typed_data';

Future<String> writeBytes(Uint8List bytes, {required String suggestedName}) {
  throw UnsupportedError(
    'Dočasné ukládání CSV souborů není na této platformě podporováno.',
  );
}

Future<void> deleteFile(String path) async {
  // No-op on unsupported platforms.
}
