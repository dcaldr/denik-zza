import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_zaznam.dart';
import 'package:denik_zza/print_ops2/generate_pdf_template.dart';

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
}) async {
  final generator = GeneratePdfTemplate.named(
    osoba: person,
    zaznamList: records,
  );
  final result = await generator.analyzeAndBuildAppend(
    osoba: person,
    zaznamList: records,
  );
  return result.analysis.finalPages;
}

Future<List<MemoryZaznam>> generateRecordsForPageCount({
  required int targetPages,
  required MemoryOsoba person,
  int maxRecords = 80,
  int baseTextRepeat = 6,
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

    pageCount = await countPagesForRecords(person: person, records: records);
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

  const PrintTestFixture({
    required this.singlePageRecords,
    required this.twoPageRecords,
    required this.threePageRecords,
  });

  static Future<PrintTestFixture> build({
    required MemoryOsoba person,
  }) async {
    final one = await generateRecordsForPageCount(
      targetPages: 1,
      person: person,
    );
    final two = await generateRecordsForPageCount(
      targetPages: 2,
      person: person,
    );
    final three = await generateRecordsForPageCount(
      targetPages: 3,
      person: person,
    );

    return PrintTestFixture(
      singlePageRecords: one,
      twoPageRecords: two,
      threePageRecords: three,
    );
  }
}
