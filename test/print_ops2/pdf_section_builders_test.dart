import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:denik_zza/print_ops2/pdf_fonts.dart';
import 'package:denik_zza/print_ops2/pdf_header_section.dart';
import 'package:denik_zza/print_ops2/pdf_record_row.dart';
import 'package:denik_zza/print_ops2/print_pdf_records.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_omezeni.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_lek.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_zaznam.dart';

void main() {
  group('PDF section builders', () {
    test('PersonPdfHeaderSection builds with full data', () async {
      final person = MemoryOsoba.basic('Test', 'Person')
        ..datumNarozeni = DateTime(2010, 1, 1)
        ..adresa = 'Test Address'
        ..cisloPojisteni = '123'
        ..zdravotniPojistovna = 'Test Insurance'
        ..jmenoRodice = 'Parent Name'
        ..telefonRodice = '123456'
        ..emailRodice = 'parent@example.com';

      final header = PersonPdfHeaderSection(
        person,
        omezeniList: [MemoryOmezeni(omezeni: 'No peanuts')],
        lekList: [MemoryLek.fullNamed(id: 1, nazev: 'Med', idOsoby: 1)],
      ).buildHeader();

      final doc = pw.Document(theme: await PdfFonts.loadTheme());
      doc.addPage(pw.Page(build: (_) => header));
      final bytes = await doc.save();
      expect(bytes.isNotEmpty, true);
    });

    test('PersonPdfHeaderSection builds without restrictions', () async {
      final person = MemoryOsoba.basic('Test', 'Person')
        ..datumNarozeni = DateTime(2010, 1, 1);

      final header = PersonPdfHeaderSection(person).buildHeader();

      final doc = pw.Document(theme: await PdfFonts.loadTheme());
      doc.addPage(pw.Page(build: (_) => header));
      final bytes = await doc.save();
      expect(bytes.isNotEmpty, true);
    });

    test('PersonPdfRecordRow builds for long description', () async {
      final record = MemoryZaznam('Title', 'Long description text', null, 1, 1, 1)
        ..casZaznamu = DateTime(2024, 1, 1)
        ..isPrinted = false;

      final row = PersonPdfRecordRow(record).buildRow();

      final doc = pw.Document(theme: await PdfFonts.loadTheme());
      doc.addPage(pw.Page(build: (_) => row));
      final bytes = await doc.save();
      expect(bytes.isNotEmpty, true);
    });

    test('PrintPdfRecords builds list for multi page layout', () async {
      final record1 = MemoryZaznam('Title 1', 'Desc 1', null, 1, 1, 1)
        ..casZaznamu = DateTime(2024, 1, 1);
      final record2 = MemoryZaznam('Title 2', 'Desc 2', null, 2, 1, 1)
        ..casZaznamu = DateTime(2024, 1, 2);

      final rows = [PersonPdfRecordRow(record1), PersonPdfRecordRow(record2)];
      final widget = PrintPdfRecords(recordRows: rows)
          .buildRecordsList(rows, forMultiPage: true);

      final doc = pw.Document(theme: await PdfFonts.loadTheme());
      doc.addPage(pw.Page(build: (_) => widget));
      final bytes = await doc.save();
      expect(bytes.isNotEmpty, true);
    });

    test('PrintPdfRecords builds empty list safely', () {
      final widget = PrintPdfRecords().buildRecordsList(const [], forMultiPage: true);
      expect(widget, isNotNull);
    });
  });
}
