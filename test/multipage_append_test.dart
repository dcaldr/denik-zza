import 'package:flutter_test/flutter_test.dart';
import 'package:denik_zza/print_ops2/models/append_analysis.dart';

void main() {
  group('AppendAnalysis', () {
    test('creates analysis from page counts - first print scenario', () {
      final analysis = AppendAnalysis.fromPageCounts(
        baselinePages: 0,
        pagesAfterFirst: 0,
        finalPages: 2,
      );

      expect(analysis.baselinePages, 0);
      expect(analysis.pagesAfterFirst, 0);
      expect(analysis.finalPages, 2);
      expect(analysis.reusedLastPage, false);
      expect(analysis.insertionPage, 1); // Should be 1 for first print, not 0
      expect(analysis.hideHeaderOnPage, -1);
      expect(analysis.additionalPages, 2);
    });

    test('creates analysis from page counts - reused last page scenario', () {
      final analysis = AppendAnalysis.fromPageCounts(
        baselinePages: 3,
        pagesAfterFirst: 3,
        finalPages: 4,
      );

      expect(analysis.baselinePages, 3);
      expect(analysis.pagesAfterFirst, 3);
      expect(analysis.finalPages, 4);
      expect(analysis.reusedLastPage, true);
      expect(analysis.insertionPage, 3);
      expect(analysis.hideHeaderOnPage, 3);
      expect(analysis.additionalPages, 1);
    });

    test('creates analysis from page counts - new page scenario', () {
      final analysis = AppendAnalysis.fromPageCounts(
        baselinePages: 2,
        pagesAfterFirst: 3,
        finalPages: 4,
      );

      expect(analysis.baselinePages, 2);
      expect(analysis.pagesAfterFirst, 3);
      expect(analysis.finalPages, 4);
      expect(analysis.reusedLastPage, false);
      expect(analysis.insertionPage, 3);
      expect(analysis.hideHeaderOnPage, -1);
      expect(analysis.additionalPages, 2);
    });

    test('getAppendModeDescription returns correct Czech descriptions', () {
      // First print
      final firstPrint = AppendAnalysis.fromPageCounts(
        baselinePages: 0,
        pagesAfterFirst: 0,
        finalPages: 2,
      );
      expect(firstPrint.getAppendModeDescription(), 'První tisk (2 stran)');

      // Reused last page
      final reusedPage = AppendAnalysis.fromPageCounts(
        baselinePages: 3,
        pagesAfterFirst: 3,
        finalPages: 4,
      );
      expect(reusedPage.getAppendModeDescription(), 'Pokračování na straně 3 (celkem 4 stran)');

      // New page
      final newPage = AppendAnalysis.fromPageCounts(
        baselinePages: 2,
        pagesAfterFirst: 3,
        finalPages: 4,
      );
      expect(newPage.getAppendModeDescription(), 'Nová strana 3 (celkem 4 stran)');
    });

    test('toString returns detailed information', () {
      final analysis = AppendAnalysis.fromPageCounts(
        baselinePages: 2,
        pagesAfterFirst: 3,
        finalPages: 4,
      );

      final str = analysis.toString();
      expect(str, contains('baseline: 2'));
      expect(str, contains('afterFirst: 3'));
      expect(str, contains('final: 4'));
      expect(str, contains('reused: false'));
      expect(str, contains('insertion: 3'));
      expect(str, contains('hideHeader: -1'));
    });
  });
}
