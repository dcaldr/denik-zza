import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:typed_data';
import 'package:denik_zza/print_ops2/pdf_fonts.dart';

/// Generates test PDFs for the FirstPrint calibration wizard.
/// 
/// This creates simplified test pages that mimic the actual print format,
/// helping users understand how their printer stacks pages.
/// 
/// Used in:
/// - Step 3: Initial calibration print (2 pages, pass 1)
/// - Step 7: Append test print (adds pass 2 records to existing pages)
class CalibrationPdfGenerator {
  
  /// Generates calibration test pages.
  /// 
  /// [passNumber] - Which print pass this is (1 = initial, 2 = append test)
  /// [pageCount] - Number of pages to generate (typically 2)
  /// [hideContentOnPages] - Pages where content should be transparent (for append simulation)
  /// 
  /// Returns PDF bytes ready for printing.
  static Future<Uint8List> generateCalibrationPdf({
    required int passNumber,
    int pageCount = 2,
    Set<int> hideContentOnPages = const {},
  }) async {
    final doc = pw.Document(theme: await PdfFonts.loadTheme());
    
    for (int pageNum = 1; pageNum <= pageCount; pageNum++) {
      final isHidden = hideContentOnPages.contains(pageNum);
      doc.addPage(_buildCalibrationPage(
        pageNumber: pageNum,
        totalPages: pageCount,
        passNumber: passNumber,
        isTransparent: isHidden,
      ));
    }
    
    return doc.save();
  }
  
  /// Generates the initial calibration test (Step 3).
  /// 
  /// Creates 2 pages with:
  /// - Simple header identifying the page
  /// - 2 mock records per page marking page number and pass
  static Future<Uint8List> generateInitialCalibration() {
    return generateCalibrationPdf(passNumber: 1, pageCount: 2);
  }
  
  /// Generates the append test (Step 7).
  /// 
  /// Creates 2 pages with:
  /// - Transparent content for pass 1 (simulating already-printed content)
  /// - Visible pass 2 records appended below
  static Future<Uint8List> generateAppendTest() async {
    final doc = pw.Document(theme: await PdfFonts.loadTheme());
    
    for (int pageNum = 1; pageNum <= 2; pageNum++) {
      doc.addPage(_buildAppendTestPage(
        pageNumber: pageNum,
        totalPages: 2,
      ));
    }
    
    return doc.save();
  }
  
  // ===========================================================================
  // PRIVATE: Page builders
  // ===========================================================================
  
  static pw.Page _buildCalibrationPage({
    required int pageNumber,
    required int totalPages,
    required int passNumber,
    bool isTransparent = false,
  }) {
    final textColor = isTransparent 
        ? const PdfColor(1, 1, 1, 0) // Transparent
        : PdfColors.black;
    final borderColor = isTransparent
        ? const PdfColor(1, 1, 1, 0)
        : PdfColors.black;
    
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header - simple page identifier
            _buildTestHeader(
              pageNumber: pageNumber,
              passNumber: passNumber,
              textColor: textColor,
              borderColor: borderColor,
            ),
            pw.SizedBox(height: 20),
            
            // Mock records section
            _buildRecordsSection(
              pageNumber: pageNumber,
              passNumber: passNumber,
              textColor: textColor,
              borderColor: borderColor,
            ),
            
            // Spacer to push footer down
            pw.Expanded(child: pw.Container()),
            
            // Footer with page number
            _buildFooter(
              pageNumber: pageNumber,
              totalPages: totalPages,
              textColor: textColor,
            ),
          ],
        );
      },
    );
  }
  
  static pw.Page _buildAppendTestPage({
    required int pageNumber,
    required int totalPages,
  }) {
    const transparentColor = PdfColor(1, 1, 1, 0);
    
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header - transparent (already printed)
            _buildTestHeader(
              pageNumber: pageNumber,
              passNumber: 1,
              textColor: transparentColor,
              borderColor: transparentColor,
            ),
            pw.SizedBox(height: 20),
            
            // Pass 1 records - transparent (already printed)
            _buildRecordsSection(
              pageNumber: pageNumber,
              passNumber: 1,
              textColor: transparentColor,
              borderColor: transparentColor,
            ),
            pw.SizedBox(height: 10),
            
            // Pass 2 records - VISIBLE (new content to append)
            _buildRecordsSection(
              pageNumber: pageNumber,
              passNumber: 2,
              textColor: PdfColors.black,
              borderColor: PdfColors.black,
            ),
            
            // Spacer
            pw.Expanded(child: pw.Container()),
            
            // Footer
            _buildFooter(
              pageNumber: pageNumber,
              totalPages: totalPages,
              textColor: PdfColors.black,
            ),
          ],
        );
      },
    );
  }
  
  // ===========================================================================
  // PRIVATE: Component builders (reusable patterns from print_ops2)
  // ===========================================================================
  
  /// Simple header identifying the test page.
  static pw.Widget _buildTestHeader({
    required int pageNumber,
    required int passNumber,
    required PdfColor textColor,
    required PdfColor borderColor,
  }) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(width: 2.0, color: borderColor),
      ),
      padding: const pw.EdgeInsets.all(12),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'TESTOVACÍ STRÁNKA $pageNumber',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: textColor,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Kalibrace tisku – průchod $passNumber',
            style: pw.TextStyle(fontSize: 12, color: textColor),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Tato stránka slouží k nastavení dotisku. Po vytištění si všimněte, '
            'která stránka leží navrchu.',
            style: pw.TextStyle(fontSize: 10, color: textColor),
          ),
        ],
      ),
    );
  }
  
  /// Mock records section mimicking actual record format.
  static pw.Widget _buildRecordsSection({
    required int pageNumber,
    required int passNumber,
    required PdfColor textColor,
    required PdfColor borderColor,
  }) {
    final timestamp = DateTime.now();
    
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(width: 1.0, color: borderColor),
      ),
      padding: const pw.EdgeInsets.all(8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Záznamy (průchod $passNumber):',
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 11,
              color: textColor,
            ),
          ),
          pw.SizedBox(height: 8),
          
          // Mock record 1
          _buildMockRecord(
            timestamp: timestamp,
            title: 'Testovací záznam ${passNumber}A',
            description: 'Stránka $pageNumber, průchod $passNumber – první záznam',
            textColor: textColor,
          ),
          pw.SizedBox(height: 6),
          
          // Mock record 2
          _buildMockRecord(
            timestamp: timestamp.add(const Duration(minutes: 5)),
            title: 'Testovací záznam ${passNumber}B',
            description: 'Stránka $pageNumber, průchod $passNumber – druhý záznam',
            textColor: textColor,
          ),
        ],
      ),
    );
  }
  
  /// Single mock record row (matches PersonPdfRecordRow format).
  static pw.Widget _buildMockRecord({
    required DateTime timestamp,
    required String title,
    required String description,
    required PdfColor textColor,
  }) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Timestamp column
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              '${timestamp.day.toString().padLeft(2, '0')}.'
              '${timestamp.month.toString().padLeft(2, '0')}.'
              '${timestamp.year}',
              style: pw.TextStyle(fontSize: 8, color: textColor),
            ),
            pw.Text(
              '${timestamp.hour.toString().padLeft(2, '0')}:'
              '${timestamp.minute.toString().padLeft(2, '0')}',
              style: pw.TextStyle(fontSize: 9, color: textColor),
            ),
          ],
        ),
        pw.SizedBox(width: 20),
        
        // Content
        pw.Expanded(
          child: pw.RichText(
            text: pw.TextSpan(
              text: '$title – ',
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: textColor,
              ),
              children: [
                pw.TextSpan(
                  text: description,
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.normal,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  /// Footer with page number indicator.
  static pw.Widget _buildFooter({
    required int pageNumber,
    required int totalPages,
    required PdfColor textColor,
  }) {
    return pw.Container(
      alignment: pw.Alignment.center,
      padding: const pw.EdgeInsets.symmetric(vertical: 8),
      child: pw.Column(
        children: [
          pw.Text(
            'Deník ZZA – Kalibrace tisku',
            style: pw.TextStyle(fontSize: 8, color: textColor),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            'Stránka $pageNumber z $totalPages',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
