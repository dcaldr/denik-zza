import 'package:pdf/widgets.dart' as pw;

/// Helper class for PDF document with page count.
class DocWithCount {
  /// The PDF document
  final pw.Document document;
  
  /// Number of pages in the document
  final int pageCount;
  
  /// Generated PDF bytes
  final List<int> bytes;
  
  DocWithCount(this.document, this.pageCount, this.bytes);
}