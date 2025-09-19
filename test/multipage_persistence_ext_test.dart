import 'package:flutter_test/flutter_test.dart';
import 'package:denik_zza/print_ops2/generate_pdf_template.dart';
import 'package:denik_zza/print_ops2/print_center_service.dart';
import 'package:denik_zza/database/database_wrapper.dart';
import 'package:denik_zza/database/database_interface.dart';
import 'package:denik_zza/database/drift_database/database.dart';
import 'setup_templates/hardcoded_setup.dart';
import 'helpers/database_test_helper.dart';

void main() {
  // Ensure Flutter bindings for rootBundle/font loading
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Extended multi-page persistence and edge-case tests', () {
    late AppDatabase database;
    late PrintCenterService service;
    late DatabaseInterface db;

    setUp(() async {
      database = await HardcodedTestSetup.setupTestData(databaseType: TestDatabaseType.memory);
      service = PrintCenterService();
      db = DatabaseWrapper.getDatabase();
    });

    tearDown(() async {
      await database.close();
    });

    test('analyzeAndBuildAppend with empty records produces first-print analysis', () async {
      final participants = await db.getParticipantsByCurrentEvent();
      expect(participants.isNotEmpty, true);

      final p = participants.first;

      // Force generate with empty record list to simulate first print
      final template = GeneratePdfTemplate();
      final result = await template.analyzeAndBuildAppend(
        osoba: p,
        omezeniList: [],
        lekList: [],
        zaznamList: [],
      );

      final analysis = result.analysis;
      expect(analysis.baselinePages, 0);
      expect(analysis.finalPages, greaterThan(0));
      expect(analysis.getAppendModeDescription().contains('První tisk'), true);

      // PDF bytes should exist
      expect(result.pdfBytes.isNotEmpty, true);
    });

    test('GeneratePdfTemplate.canAppend returns false when osoba not printed', () async {
      final participants = await db.getParticipantsByCurrentEvent();
      expect(participants.isNotEmpty, true);

      final p = participants.first;
      // Locally mark as not printed (object-level) and pass to template
      p.wasPrinted = false;

      final template = GeneratePdfTemplate.named(osoba: p, zaznamList: []);
      // Should be false because osoba header is not printed
      expect(template.canAppend(), false);
    });

    test('setMultipleRecordPrintedFlags handles empty list and returns empty results', () async {
      final results = await service.setMultipleRecordPrintedFlags([], true);
      expect(results, isEmpty);
    });
  });
}
