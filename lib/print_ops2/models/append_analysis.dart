/// Analysis results from the multi-pass append algorithm.
class AppendAnalysis {
  /// Number of pages in original document
  final int baselinePages;

  /// Number of pages after adding first new record
  final int pagesAfterFirst;

  /// Number of pages in final document
  final int finalPages;

  /// Whether the first new record fits on the last existing page
  final bool reusedLastPage;

  /// Page number where new content starts (1-indexed)
  final int insertionPage;

  /// Page number where header should be hidden (-1 if no hiding needed)
  final int hideHeaderOnPage;

  AppendAnalysis({
    required this.baselinePages,
    required this.pagesAfterFirst,
    required this.finalPages,
    required this.reusedLastPage,
    required this.insertionPage,
    required this.hideHeaderOnPage,
  });

  /// Creates analysis from page counts using the three-pass algorithm logic
  factory AppendAnalysis.fromPageCounts({
    required int baselinePages,
    required int pagesAfterFirst,
    required int finalPages,
  }) {
    final reusedLastPage =
        baselinePages > 0 && pagesAfterFirst == baselinePages;
    final insertionPage = reusedLastPage ? baselinePages : baselinePages + 1;
    final hideHeaderOnPage = reusedLastPage ? baselinePages : -1;

    return AppendAnalysis(
      baselinePages: baselinePages,
      pagesAfterFirst: pagesAfterFirst,
      finalPages: finalPages,
      reusedLastPage: reusedLastPage,
      insertionPage: insertionPage,
      hideHeaderOnPage: hideHeaderOnPage,
    );
  }

  /// Additional pages created by appending
  int get additionalPages => finalPages - baselinePages;

  /// Human-readable description of the append mode
  String getAppendModeDescription() {
    if (baselinePages == 0) {
      return 'První tisk ($finalPages stran)';
    }

    if (reusedLastPage) {
      return 'Pokračování na straně $insertionPage (celkem $finalPages stran)';
    } else {
      return 'Nová strana $insertionPage (celkem $finalPages stran)';
    }
  }

  @override
  String toString() {
    return 'AppendAnalysis('
        'baseline: $baselinePages, '
        'afterFirst: $pagesAfterFirst, '
        'final: $finalPages, '
        'reused: $reusedLastPage, '
        'insertion: $insertionPage, '
        'hideHeader: $hideHeaderOnPage)';
  }
}
