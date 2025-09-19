import 'package:pdf/widgets.dart' as pw;
import 'append_analysis.dart';

/// Result of a PDF build operation with append analysis.
class AppendBuildResult {
  /// Analysis results of the append operation
  final AppendAnalysis analysis;
  
  /// Generated PDF document bytes
  final List<int> pdfBytes;
  
  /// The PDF document (for further processing if needed)
  final pw.Document document;

  AppendBuildResult({
    required this.analysis,
    required this.pdfBytes,
    required this.document,
  });
}