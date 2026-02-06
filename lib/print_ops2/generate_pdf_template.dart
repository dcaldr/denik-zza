import 'package:denik_zza/print_ops2/print_pdf_header.dart';
import 'package:denik_zza/print_ops2/print_pdf_records.dart';
import 'package:denik_zza/print_ops2/pdf_record_row.dart';
import 'package:denik_zza/print_ops2/pdf_header_section.dart';
import 'package:denik_zza/print_ops2/pdf_fonts.dart';
import 'package:denik_zza/print_ops2/pdf_constants.dart';
import 'package:denik_zza/print_ops2/models/append_analysis.dart';
import 'package:denik_zza/print_ops2/models/append_build_result.dart';
import 'package:denik_zza/print_ops2/models/doc_with_count.dart';
import 'package:denik_zza/print_ops2/print_utils.dart';
import 'package:denik_zza/print_ops2/print_status_codes.dart';
import 'package:logger/logger.dart';
import 'package:denik_zza/utils/app_logger.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../database/in_memory_structures_tmp/memory_lek.dart';
import '../database/in_memory_structures_tmp/memory_omezeni.dart';
import '../database/in_memory_structures_tmp/memory_osoba.dart';
import '../database/in_memory_structures_tmp/memory_zaznam.dart';

/// Generates a pdf template for the given person WARNING: still missing hiding logic
///
/// The template consists of a header, restrictions, and records.
/// The class doesn't check if the provided inputs match each other,
/// it is the responsibility of the caller to provide the correct data.
class GeneratePdfTemplate {
  static final Logger _logger = AppLogger.l;
  static const headerPrimaryColor = PdfColor(0, 0, 0);
  static const hiddenColor = PdfColor(0, 0, 0, 0);

  MemoryOsoba? _osoba;
  List<MemoryZaznam>? _zaznamList;

  /// status for the records
  OkCodes _recordStatus = OkCodes.unset;

  set osoba(MemoryOsoba? inOsoba) {
    if (inOsoba != _osoba) {
      _recordStatus = OkCodes.unset;
    }
    _osoba = inOsoba;
  }

  GeneratePdfTemplate();

  GeneratePdfTemplate.named({
    required MemoryOsoba? osoba,
    List<MemoryZaznam>? zaznamList,
  })  : _zaznamList = zaznamList,
        _osoba = osoba;

  /// tests if appending is possible or needs to be completely recreated
  ///
  /// returns true if the given wasPrinted flags are in good configuration
  /// Header T -> Records T(all but lasts) - ok
  /// Header T -> Records F - ok
  bool canAppend() {
    // Check if osoba exists and was printed
    if (_osoba == null) return false;
    final wasPrinted = _osoba?.wasPrinted ?? false;

    // Special case: If there are no records at all, don't allow append
    // This is because append mode is designed to add new records to existing ones,
    // but without any records (even if the header exists), a full print makes more sense
    if (_zaznamList == null) return false;

    if (_zaznamList!.isEmpty) return false;

    // here osoba(header) always printed
    isRecordsOk();
    final printedFlags = _zaznamList!.map((record) => record.isPrinted).toList();
    return canAppendPrint(wasPrinted: wasPrinted, isPrintedFlags: printedFlags);
  }

  /// tests if records aren't blocking appending
  ///
  /// for entire safety it will order the list by time (but it should be already ordered)
  void isRecordsOk() {
    if (_recordStatus != OkCodes.unset) {
      return;
    }
    if (_zaznamList == null) {
      _recordStatus = OkCodes.unprinted;
      return;
    }

    if (_zaznamList!.isEmpty) {
      _recordStatus = OkCodes.unset;
      return;
    }

    // if in testing mode check and Logger warn if not ordered
    assert(() {
      var cmpList = List<MemoryZaznam>.from(_zaznamList!);
      _zaznamList!.sort((a, b) => a.casZaznamu!.compareTo(b.casZaznamu!));
      for (int i = 0; i < cmpList.length; i++) {
        if (cmpList[i] != _zaznamList![i]) {
          _logger.w(
              "Records are not ordered by time, where expected in GeneratePdfTemplate");
          return true;
        }
      }
      return true;
    }());

    /// order by time of the record (oldest first)
    _zaznamList!.sort((a, b) => a.casZaznamu!.compareTo(b.casZaznamu!));

    final flags = _zaznamList!.map((record) => record.isPrinted).toList();
    _recordStatus = evaluateRecordSequence(flags);
  }

  /// generates list of pages for pdf from the given person
  Future<List<pw.Page>> getPdfPages({
    required MemoryOsoba osoba,
    List<MemoryOmezeni>? omezeniList,
    List<MemoryLek>? lekList,
    List<MemoryZaznam>? zaznamList,
  }) async {
    // Use new abstractions - header includes restrictions for person
    final headerSection = PersonPdfHeaderSection(osoba,
        omezeniList: omezeniList, lekList: lekList);
    final header = PrintPdfHeader(headerSection).buildHeader();

    // Convert MemoryZaznam to PersonPdfRecordRow
    final recordRows = zaznamList?.map((z) => PersonPdfRecordRow(z)).toList();

    return [
      pw.MultiPage(
        theme: await PdfFonts.loadTheme(),
        build: (pw.Context context) {
          return [
            header,
            pw.SizedBox(height: kPdfHeaderRecordsGap),
            if (recordRows != null)
              PrintPdfRecords(
                      recordRows: recordRows,
                      borderColor: GeneratePdfTemplate.headerPrimaryColor)
                  .buildRecordsList(recordRows, forMultiPage: true),
          ];
        },
        header: (pw.Context context) {
          return pw.Container();
        },
        footer: (pw.Context context) {
          final pageNum = context.pageNumber;
          return pw.Container(
            alignment: pw.Alignment.center,
            child: pw.Text(
              'Deník ZZA - $pageNum',
              style: pw.TextStyle(fontSize: kPdfFooterFontSize),
            ),
          );
        },
      ),
    ];
  }

  // Font loading delegated to shared PdfFonts utility

  /// Three-pass algorithm for multi-page append analysis and PDF generation
  Future<AppendBuildResult> analyzeAndBuildAppend({
    required MemoryOsoba osoba,
    List<MemoryOmezeni>? omezeniList,
    List<MemoryLek>? lekList,
    List<MemoryZaznam>? zaznamList,
  }) async {
    if (zaznamList == null || zaznamList.isEmpty) {
      _logger.w('analyzeAndBuildAppend called with empty records list');
      // Generate as first print
      final result = await _generateBasePdf(
        osoba: osoba,
        omezeniList: omezeniList,
        lekList: lekList,
        zaznamList: [],
        hideHeaderOnPage: -1,
      );

      final analysis = AppendAnalysis.fromPageCounts(
        baselinePages: 0,
        pagesAfterFirst: 0,
        finalPages: result.pageCount,
      );

      return AppendBuildResult(
        analysis: analysis,
        pdfBytes: result.bytes,
        document: result.document,
      );
    }

    // Split records into printed and unprinted
    final printedRecords = zaznamList.where((z) => z.isPrinted).toList();
    final unprintedRecords = zaznamList.where((z) => !z.isPrinted).toList();

    // Pass 1: Generate baseline PDF with only printed content
    final baselineResult = await _generateBasePdf(
      osoba: osoba,
      omezeniList: omezeniList,
      lekList: lekList,
      zaznamList: printedRecords,
      hideHeaderOnPage: -1,
    );
    final baselinePages = baselineResult.pageCount;
    _logger.d('Baseline pages: $baselinePages');

    // Pass 2: Add just the first unprinted record to detect page break
    final probeRecords = [...printedRecords];
    if (unprintedRecords.isNotEmpty) {
      probeRecords.add(unprintedRecords.first);
    }

    final probeResult = await _generateBasePdf(
      osoba: osoba,
      omezeniList: omezeniList,
      lekList: lekList,
      zaznamList: probeRecords,
      hideHeaderOnPage: -1,
    );
    final pagesAfterFirst = probeResult.pageCount;
    _logger.d('Pages after first new record: $pagesAfterFirst');

    // Pass 3: Generate final PDF with all content
    final analysis = AppendAnalysis.fromPageCounts(
      baselinePages: baselinePages,
      pagesAfterFirst: pagesAfterFirst,
      finalPages: 0, // Will be updated below
    );

    final finalResult = await _generateBasePdf(
      osoba: osoba,
      omezeniList: omezeniList,
      lekList: lekList,
      zaznamList: zaznamList,
      hideHeaderOnPage: analysis.hideHeaderOnPage,
      maskPrintedRecords: true,
    );

    // Update final analysis with actual final page count
    final finalAnalysis = AppendAnalysis.fromPageCounts(
      baselinePages: baselinePages,
      pagesAfterFirst: pagesAfterFirst,
      finalPages: finalResult.pageCount,
    );

    _logger.d('Final analysis: $finalAnalysis');

    return AppendBuildResult(
      analysis: finalAnalysis,
      pdfBytes: finalResult.bytes,
      document: finalResult.document,
    );
  }

  // Transparent color for "ghosting" records
  static final PdfColor transparentColor = kPdfTransparentColor;

  /// Generates PDF using MultiPage with header/footer control
  Future<DocWithCount> _generateBasePdf({
    required MemoryOsoba osoba,
    List<MemoryOmezeni>? omezeniList,
    List<MemoryLek>? lekList,
    required List<MemoryZaznam> zaznamList,
    required int hideHeaderOnPage,
    bool maskPrintedRecords = false,
  }) async {
    final theme = await PdfFonts.loadTheme();
    final doc = pw.Document();

    // Track pages for counting (fallback strategy)
    // Track pages for counting (fallback strategy)
    final Set<int> observedPages = <int>{};

    // Create visible header
    final headerSection = PersonPdfHeaderSection(osoba,
        omezeniList: omezeniList, lekList: lekList);
    final headerWidget = PrintPdfHeader(headerSection).buildHeader();

    // Create transparent header (for layout preservation)
    final transparentHeaderSection = PersonPdfHeaderSection(osoba,
        omezeniList: omezeniList,
        lekList: lekList,
        textColor: transparentColor);
    final transparentHeaderWidget =
        PrintPdfHeader(transparentHeaderSection).buildHeader();

    // Convert records to rows with optional masking
    final recordRows = zaznamList.map((z) {
      final shouldHide = maskPrintedRecords && z.isPrinted;
      return PersonPdfRecordRow(z,
          isHidden: shouldHide,
          textColor: shouldHide ? transparentColor : null);
    }).toList();

    doc.addPage(
      pw.MultiPage(
        theme: theme,
        build: (pw.Context context) {
          final content = <pw.Widget>[];

          // Add header (with visibility control)
          final currentPage = _getPageNumber(context);
          observedPages.add(currentPage);

          if (hideHeaderOnPage != currentPage) {
            content.add(headerWidget);
            content.add(pw.SizedBox(height: kPdfHeaderRecordsGap));
          } else {
            // Render transparent header to maintain layout
            content.add(transparentHeaderWidget);
            content.add(pw.SizedBox(height: kPdfHeaderRecordsGap));
          }

          // Add records (using forMultiPage=true)
          if (recordRows.isNotEmpty) {
            final borderColor = maskPrintedRecords
                ? transparentColor
                : GeneratePdfTemplate.headerPrimaryColor;
            content.add(PrintPdfRecords(
                    recordRows: recordRows, borderColor: borderColor)
                .buildRecordsList(recordRows, forMultiPage: true));
          }

          return content;
        },
        header: (pw.Context context) {
          final currentPage = _getPageNumber(context);
          observedPages.add(currentPage);
          return pw.Container();
        },
        footer: (pw.Context context) {
          final currentPage = _getPageNumber(context);
          observedPages.add(currentPage);
          // Debug print to trace footer execution
          // logger.d('Building footer for page $currentPage, mask=$maskPrintedRecords');

          final textColor =
              maskPrintedRecords ? transparentColor : PdfColor(0, 0, 0);

          return pw.Container(
            alignment: pw.Alignment.center,
            child: pw.Text(
              'Deník ZZA - $currentPage',
              style:
                  pw.TextStyle(fontSize: kPdfFooterFontSize, color: textColor),
            ),
          );
        },
      ),
    );

    final bytes = await doc.save();

    // Determine page count using multiple strategies
    int pageCount;
    try {
      pageCount = doc.document.pdfPageList.pages.length;
      _logger.d('Page count from pdfPageList: $pageCount');
    } catch (e) {
      pageCount = observedPages.isNotEmpty ? observedPages.length : 1;
      _logger.w('Page count fallback to observed pages: $pageCount');
    }

    return DocWithCount(doc, pageCount, bytes);
  }

  /// Safely get page number with fallback
  int _getPageNumber(pw.Context context) {
    try {
      final pageNum = context.pageNumber;
      return pageNum > 0 ? pageNum : 1;
    } catch (e) {
      // This occurs in some test-only paths; reduce to debug to avoid noise.
      _logger.d('Failed to get page number, using fallback: $e');
      return 1;
    }
  }
}

