import 'dart:typed_data';

class PdfPageMetrics {
  final int pageCount;
  final int byteSize;

  const PdfPageMetrics({
    required this.pageCount,
    required this.byteSize,
  });
}

int countPdfPages(Uint8List pdfBytes) {
  final content = String.fromCharCodes(pdfBytes);
  final matches = RegExp(r'/Type\s*/Page\b').allMatches(content);
  if (matches.isEmpty) {
    return 1;
  }
  return matches.length;
}

PdfPageMetrics analyzePdf(Uint8List pdfBytes) {
  return PdfPageMetrics(
    pageCount: countPdfPages(pdfBytes),
    byteSize: pdfBytes.length,
  );
}
