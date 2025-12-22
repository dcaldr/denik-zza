import 'package:flutter_test/flutter_test.dart';
import 'package:denik_zza/utils/app_logger.dart';
import 'package:denik_zza/print_ops2/generate_pdf_template.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_zaznam.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Append Logic Tests', () {
    late MemoryOsoba person;
    late int pageCapacity;

    List<MemoryZaznam> generateRecords(int count,
        {bool printed = false, int startId = 1}) {
      return List.generate(count, (index) {
        final id = startId + index;
        return MemoryZaznam.fullNamed(
          idZaznamu: id,
          casZaznamu: DateTime.now().add(Duration(minutes: id)),
          nazev: 'Record $id',
          popis:
              'Description line 1\nDescription line 2', // Consistent 2-line description
          isPrinted: printed,
          idAuthor: 1,
          idPacient: 1,
          poznamka: '',
          teplota: null,
          obrazekPath: null,
          lecba: null,
        );
      });
    }

    setUpAll(() async {
      person = MemoryOsoba.named(
        id: 1,
        jmeno: 'Test',
        prijmeni: 'Person',
        zpusobilost: true,
        bezinfekcnost: true,
        datumNarozeni: DateTime(1990, 1, 1),
        wasPrinted: true,
        cisloPojisteni: '111',
        telefonRodice: '123',
        zdravotniPojistovna: '205',
        adresa: 'Test Address',
      );

      AppLogger.l.d('Determining page capacity...');
      for (int i = 1; i < 100; i++) {
        final records = generateRecords(i, printed: true);

        final template =
            GeneratePdfTemplate.named(osoba: person, zaznamList: records);
        // Using analyzeAndBuildAppend PASS 1 logic (all printed)
        final result = await template.analyzeAndBuildAppend(
            osoba: person, zaznamList: records);

        if (result.analysis.finalPages > 1) {
          pageCapacity = i - 1; // Previous count fit on 1 page
          AppLogger.l.d('Capacity determined: $pageCapacity records per page.');
          return;
        }
      }
      pageCapacity =
          18; // Fallback if something weird happens (e.g. infinite page)
      AppLogger.l.d('Capacity fallback: 18');
    });

    test('Scenario 1: Same Page Append (Below Capacity)', () async {
      // Use 50% capacity for old, add 20%. Should fit.
      final usedCount = (pageCapacity * 0.5).floor();
      final newCount = (pageCapacity * 0.2).floor();
      // Ensure at least 1 record
      final effectiveUsed = usedCount < 1 ? 1 : usedCount;
      final effectiveNew = newCount < 1 ? 1 : newCount;

      final oldRecords =
          generateRecords(effectiveUsed, printed: true, startId: 1);
      final newRecords = generateRecords(effectiveNew,
          printed: false, startId: effectiveUsed + 1);
      final allRecords = [...oldRecords, ...newRecords];

      final template =
          GeneratePdfTemplate.named(osoba: person, zaznamList: allRecords);
      final result = await template.analyzeAndBuildAppend(
        osoba: person,
        zaznamList: allRecords,
      );

      AppLogger.l
          .d('Scenario 1 (${effectiveUsed}old + ${effectiveNew}new): $result');
      expect(result.analysis.finalPages, 1);
      expect(result.analysis.reusedLastPage, true);
    });

    test('Scenario 2: New Page Append (Full Page + 1)', () async {
      // Use FULL Capacity for old. Add 1 New.
      // Should force new page.
      final usedCount = pageCapacity;
      const newCount = 1;

      final oldRecords = generateRecords(usedCount, printed: true, startId: 1);
      final newRecords =
          generateRecords(newCount, printed: false, startId: usedCount + 1);
      final allRecords = [...oldRecords, ...newRecords];

      final template =
          GeneratePdfTemplate.named(osoba: person, zaznamList: allRecords);
      final result = await template.analyzeAndBuildAppend(
        osoba: person,
        zaznamList: allRecords,
      );

      AppLogger.l.d('Scenario 2 (${usedCount}old + ${newCount}new): $result');
      expect(result.analysis.finalPages, 2);
      expect(result.analysis.reusedLastPage, false,
          reason: 'Old page was full, should NOT reuse');
      expect(result.analysis.insertionPage, 2);
    });

    test('Scenario 3: Mixed Append (Half + Full)', () async {
      // Half Used. Add Capacity. Should spill to Page 2 but start on Page 1.
      final usedCount = (pageCapacity * 0.5).floor();
      final newCount = pageCapacity;
      // Ensure positive
      final effectiveUsed = usedCount < 1 ? 1 : usedCount;

      final oldRecords =
          generateRecords(effectiveUsed, printed: true, startId: 1);
      final newRecords =
          generateRecords(newCount, printed: false, startId: effectiveUsed + 1);
      final allRecords = [...oldRecords, ...newRecords];

      final template =
          GeneratePdfTemplate.named(osoba: person, zaznamList: allRecords);
      final result = await template.analyzeAndBuildAppend(
        osoba: person,
        zaznamList: allRecords,
      );

      AppLogger.l
          .d('Scenario 3 (${effectiveUsed}old + ${newCount}new): $result');
      expect(result.analysis.finalPages, 2);
      expect(result.analysis.reusedLastPage, true,
          reason: 'Had space on Page 1, should start there');
      expect(result.analysis.insertionPage, 1);
    });
  });
}
