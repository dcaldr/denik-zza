import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/widgets.dart' as pw;

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

  /// Loads CourierPrime font family with Czech character support.
  /// 
  /// Returns [pw.ThemeData] configured with base, bold, italic, and boldItalic variants.
  static Future<pw.ThemeData> loadTheme() async {
    return pw.ThemeData.withFont(
      base: pw.Font.ttf(await rootBundle.load('fonts/CourierPrime-Regular.ttf')),
      bold: pw.Font.ttf(await rootBundle.load('fonts/CourierPrime-Bold.ttf')),
      italic: pw.Font.ttf(await rootBundle.load('fonts/CourierPrime-Italic.ttf')),
      boldItalic: pw.Font.ttf(await rootBundle.load('fonts/CourierPrime-BoldItalic.ttf')),
    );
  }
}
