import 'dart:typed_data';

class PdfPageMetrics {
  final int pageCount;
  final int byteSize;
  final List<int> perPageByteSizes;

  const PdfPageMetrics({
    required this.pageCount,
    required this.byteSize,
    required this.perPageByteSizes,
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
  final pageCount = countPdfPages(pdfBytes);
  final byteSize = pdfBytes.length;
  final avg = pageCount > 0 ? (byteSize / pageCount).round() : byteSize;
  return PdfPageMetrics(
    pageCount: pageCount,
    byteSize: byteSize,
    perPageByteSizes: List<int>.filled(pageCount, avg),
  );
}
