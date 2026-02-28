import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/widgets.dart' as pw;

/// Holds raw font bytes loaded from assets.
/// Used to pass font data into Isolates, as Isolates cannot access rootBundle directly.
class FontByteData {
  final ByteData base;
  final ByteData bold;
  final ByteData italic;
  final ByteData boldItalic;

  FontByteData({
    required this.base,
    required this.bold,
    required this.italic,
    required this.boldItalic,
  });
}

/// Shared PDF font loading utility.
/// 
/// Provides CourierPrime fonts with Czech diacritic support for all PDF generators.
/// 
/// Usage:
/// ```dart
/// final doc = pw.Document(theme: await PdfFonts.loadTheme());
/// // or
/// pw.MultiPage(theme: await PdfFonts.loadTheme(), ...)
/// ```
class PdfFonts {
  PdfFonts._(); // Private constructor - static only

  /// Loads raw font bytes from the rootBundle on the main thread.
  static Future<FontByteData> loadFontData() async {
    return FontByteData(
      base: await rootBundle.load('fonts/CourierPrime-Regular.ttf'),
      bold: await rootBundle.load('fonts/CourierPrime-Bold.ttf'),
      italic: await rootBundle.load('fonts/CourierPrime-Italic.ttf'),
      boldItalic: await rootBundle.load('fonts/CourierPrime-BoldItalic.ttf'),
    );
  }

  /// Builds a [pw.ThemeData] synchronously given raw font bytes.
  static pw.ThemeData buildTheme(FontByteData data) {
    return pw.ThemeData.withFont(
      base: pw.Font.ttf(data.base),
      bold: pw.Font.ttf(data.bold),
      italic: pw.Font.ttf(data.italic),
      boldItalic: pw.Font.ttf(data.boldItalic),
    );
  }

  /// Loads CourierPrime font family with Czech character support.
  /// Convenience method that combines loading and building.
  static Future<pw.ThemeData> loadTheme() async {
    final data = await loadFontData();
    return buildTheme(data);
  }
}
