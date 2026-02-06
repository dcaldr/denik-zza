import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_zaznam.dart';
import 'package:denik_zza/database/drift_database/database.dart';
import 'package:denik_zza/print_ops2/generate_pdf_template.dart';

final Map<String, int> _pageCountCache = {};

MemoryOsoba buildTestPerson({
  int id = 1,
  String jmeno = 'Test',
  String prijmeni = 'Osoba',
}) {
  final person = MemoryOsoba.basic(jmeno, prijmeni);
  person.id = id;
  person.wasPrinted = true;
  person.datumNarozeni = DateTime(2010, 1, 1);
  return person;
}

MemoryZaznam buildTestRecord({
  required int id,
  required int participantId,
  required String title,
  required String description,
  DateTime? timestamp,
}) {
  final record = MemoryZaznam(title, description, null, id, -1, participantId);
  record.casZaznamu = timestamp ?? DateTime.now().add(Duration(minutes: id));
  record.isPrinted = false;
  return record;
}

Future<int> countPagesForRecords({
  required MemoryOsoba person,
  required List<MemoryZaznam> records,
  required AppDatabase db,
}) async {
  final cacheKey = _buildCacheKey(db, records);
  final cached = _pageCountCache[cacheKey];
  if (cached != null) {
    return cached;
  }
  final generator = GeneratePdfTemplate.named(
    osoba: person,
    zaznamList: records,
  );
  final result = await generator.analyzeAndBuildAppend(
    osoba: person,
    zaznamList: records,
  );
  final pages = result.analysis.finalPages;
  _pageCountCache[cacheKey] = pages;
  return pages;
}

Future<List<MemoryZaznam>> generateRecordsForPageCount({
  required int targetPages,
  required MemoryOsoba person,
  required AppDatabase db,
  int maxRecords = 80,
  int baseTextRepeat = 6,
  bool requireExactPages = false,
}) async {
  final records = <MemoryZaznam>[];
  var pageCount = 0;
  var recordIndex = 0;

  while (pageCount < targetPages && recordIndex < maxRecords) {
    recordIndex += 1;
    final description = _buildDescription(recordIndex, baseTextRepeat);
    records.add(buildTestRecord(
      id: recordIndex,
      participantId: person.id,
      title: 'Test ${recordIndex.toString().padLeft(2, '0')}',
      description: description,
    ));

    pageCount = await countPagesForRecords(
      person: person,
      records: records,
      db: db,
    );

    if (requireExactPages && pageCount == targetPages) {
      return records;
    }
  }

  if (requireExactPages && pageCount != targetPages) {
    throw StateError(
      'Could not reach exactly $targetPages page(s) with $recordIndex records',
    );
  }

  return records;
}

String _buildDescription(int index, int baseTextRepeat) {
  final base = 'Popis zaznamu $index. ';
  return List.filled(baseTextRepeat + index, base).join();
}

class PrintTestFixture {
  final List<MemoryZaznam> singlePageRecords;
  final List<MemoryZaznam> twoPageRecords;
  final List<MemoryZaznam> threePageRecords;
  final List<MemoryZaznam> exactlyFullPageRecords;

  const PrintTestFixture({
    required this.singlePageRecords,
    required this.twoPageRecords,
    required this.threePageRecords,
    required this.exactlyFullPageRecords,
  });

  static final Map<int, PrintTestFixture> _cache = {};

  static Future<PrintTestFixture> build({
    required MemoryOsoba person,
    required AppDatabase db,
  }) async {
    final cacheKey = person.id;
    final cached = _cache[cacheKey];
    if (cached != null) {
      return cached;
    }

    final one = await generateRecordsForPageCount(
      targetPages: 1,
      person: person,
      db: db,
    );
    final two = await generateRecordsForPageCount(
      targetPages: 2,
      person: person,
      db: db,
    );
    final three = await generateRecordsForPageCount(
      targetPages: 3,
      person: person,
      db: db,
    );
    final exactOne = await generateRecordsForPageCount(
      targetPages: 1,
      person: person,
      db: db,
      requireExactPages: true,
    );

    final fixture = PrintTestFixture(
      singlePageRecords: one,
      twoPageRecords: two,
      threePageRecords: three,
      exactlyFullPageRecords: exactOne,
    );
    _cache[cacheKey] = fixture;
    return fixture;
  }
}

String _buildCacheKey(AppDatabase db, List<MemoryZaznam> records) {
  var checksum = 0;
  for (final record in records) {
    checksum ^= record.popis?.length ?? 0;
    checksum ^= record.nazev?.length ?? 0;
  }
  return '${db.hashCode}_${records.length}_$checksum';
}
