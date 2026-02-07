
import 'dart:io';
import 'dart:math';

import 'package:denik_zza/database/database_wrapper.dart';
import 'package:denik_zza/database/drift_database_connector.dart';
import 'package:denik_zza/database/drift_database/database.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_lek.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_omezeni.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_zaznam.dart';
import 'package:denik_zza/print_ops2/generate_pdf_template.dart';
import 'package:denik_zza/print_ops2/models/append_build_result.dart';
import 'package:denik_zza/utils/mode_coordinator.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;
import 'package:pdf/widgets.dart' as pw;

import '../../utils/print_test_helpers.dart';

// -----------------------------------------------------------------------------
// VISUAL VERIFICATION TEST SUITE
// -----------------------------------------------------------------------------

void main() {
  late Directory outputDir;
  late Directory pdfDir;
  late String timestamp;

  setUpAll(() async {
    // 0. Mock path_provider for headless execution
    TestWidgetsFlutterBinding.ensureInitialized();
    
    const MethodChannel('plugins.flutter.io/path_provider')
      .setMockMethodCallHandler((MethodCall methodCall) async {
        if (methodCall.method == 'getApplicationDocumentsDirectory') {
          return Directory.current.path; 
        }
        if (methodCall.method == 'getTemporaryDirectory') {
           return Directory.systemTemp.path;
        }
        return null;
      });

    // 1. Setup Environment
    timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.').first;
    
    // Use ModeCoordinator to ensure we are in a safe integration mode
    await ModeCoordinator.setIntegrationTestMode(testName: 'visual_verification');
    
    // Override output path
    final projectRoot = Directory.current.path;
    final baseDir = Directory(p.join(projectRoot, 'test_outputs', 'visual_verification', timestamp));
    
    outputDir = baseDir;
    pdfDir = Directory(p.join(outputDir.path, 'generated_pdfs'));
    
    if (await outputDir.exists()) await outputDir.delete(recursive: true);
    await outputDir.create(recursive: true);
    await pdfDir.create(recursive: true);
    
    print('----------------------------------------------------------------');
    print('VISUAL VERIFICATION SUITE');
    print('Output Directory: ${outputDir.path}');
    print('----------------------------------------------------------------');
  });

  tearDownAll(() async {
    await _generateHtmlDashboard(outputDir, pdfDir, _scenarios);
    print('----------------------------------------------------------------');
    print('DASHBOARD GENERATED: ${p.join(outputDir.path, "index.html")}');
    print('----------------------------------------------------------------');
    await ModeCoordinator.setProductionMode();
  });

  // ---------------------------------------------------------------------------
  // TEST EXECUTION
  // ---------------------------------------------------------------------------

  test('Generate All Verification Artifacts', () async {
    final dbInterface = DatabaseWrapper.getDatabase();
    // Generators require AppDatabase for hashing, so we need to access the underlying instance.
    // In integration test mode, we are guaranteed to use DriftDatabaseConnector.
    if (dbInterface is! DriftDatabaseConnector) {
      fail('Visual Verification Test requires DriftDatabaseConnector, found: ${dbInterface.runtimeType}');
    }
    final db = dbInterface.appDatabase;

    for (final scenario in _scenarios) {
      print('Generating: ${scenario.title}...');
      
      final data = await scenario.setup(db); // Await async setup
      
      List<int> bytes;
      if (scenario.mode == PrintMode.full) {
        final template = GeneratePdfTemplate();
        final pages = await template.getPdfPages(
          osoba: data.osoba,
          omezeniList: data.omezeni,
          lekList: data.leky,
          zaznamList: data.records,
        );
        
        final doc = pw.Document();
        for (final page in pages) {
          doc.addPage(page);
        }
        bytes = await doc.save();
      } else {
        // Append Mode
        final template = GeneratePdfTemplate();
        final result = await template.analyzeAndBuildAppend(
          osoba: data.osoba,
          omezeniList: data.omezeni,
          lekList: data.leky,
          zaznamList: data.records,
        );
        bytes = result.pdfBytes;
      }

      final filename = '${scenario.name}.pdf';
      final file = File(p.join(pdfDir.path, filename));
      await file.writeAsBytes(bytes);
      
      scenario.generatedFilename = filename;
    }
  });
}

// -----------------------------------------------------------------------------
// SCENARIO DEFINITIONS
// -----------------------------------------------------------------------------

enum PrintMode { full, append }

class TestData {
  MemoryOsoba osoba;
  List<MemoryZaznam> records;
  List<MemoryOmezeni> omezeni;
  List<MemoryLek> leky;

  TestData(this.osoba, this.records, {
    this.omezeni = const <MemoryOmezeni>[], 
    this.leky = const <MemoryLek>[],
  });
}

typedef DataSetup = Future<TestData> Function(AppDatabase db);

class VerificationScenario {
  final String name;
  final String title;
  final String description;
  final PrintMode mode;
  final DataSetup setup;
  String? generatedFilename;

  VerificationScenario({
    required this.name,
    required this.title,
    required this.description,
    required this.mode,
    required this.setup,
  });
}

final List<VerificationScenario> _scenarios = [
  // 1. STANDARD FULL PRINT
  VerificationScenario(
    name: '01_full_standard',
    title: 'Standard Full Print',
    description: 'Basic 1-page print. Check header, footer, spacing.',
    mode: PrintMode.full,
    setup: (db) async {
      final p = buildTestPerson();
      final r = await generateRecordsForPageCount(
        targetPages: 1, 
        person: p, 
        db: db,
        requireExactPages: true
      );
      return TestData(p, r);
    },
  ),

  // 2. MULTI-PAGE FULL PRINT
  VerificationScenario(
    name: '02_full_multipage',
    title: 'Multi-Page Full Print',
    description: '3 pages of records. Check footer numbering (1/3, 2/3...), header repetition if enabled.',
    mode: PrintMode.full,
    setup: (db) async {
      final p = buildTestPerson();
      final r = await generateRecordsForPageCount(
        targetPages: 3, 
        person: p, 
        db: db,
        requireExactPages: true
      ); 
      return TestData(p, r);
    },
  ),

  // 3. APPEND - TIGHT FIT
  VerificationScenario(
    name: '03_append_tight_fit',
    title: 'Append - Tight Fit',
    description: 'Append a record that *just* fits on the current page. Ensure it doesn\'t force a blank page.',
    mode: PrintMode.append,
    setup: (db) async {
      final p = buildTestPerson();
      p.wasPrinted = true;
      
      // Create exactly 1 page of printed records
      final oldRecords = await generateRecordsForPageCount(
        targetPages: 1, 
        person: p, 
        db: db, 
        requireExactPages: true
      );
      for(var r in oldRecords) r.isPrinted = true;
      
      // Add one small record that should fit
      final newRecord = buildTestRecord(
          id: 100, participantId: p.id, title: 'Small Append', description: 'Short line.');
          
      return TestData(p, [...oldRecords, newRecord]);
    },
  ),

  // 4. APPEND - JUST OVERFLOW
  VerificationScenario(
    name: '04_append_overflow',
    title: 'Append - Just Overflow',
    description: 'Append a record that forces a new page using ghosting transparency.',
    mode: PrintMode.append,
    setup: (db) async {
      final p = buildTestPerson();
      p.wasPrinted = true;
      
      // We want to be almost full, so adding one more record triggers overflow
      // This is tricky to guarantee with generators without precise knowing the content size.
      // But we can approximate by taking a 1-page full set and adding a medium record.
       final oldRecords = await generateRecordsForPageCount(
        targetPages: 1, 
        person: p, 
        db: db, 
        requireExactPages: true
      );
      for(var r in oldRecords) r.isPrinted = true;

      final newRecord = buildTestRecord(
          id: 100, participantId: p.id, title: 'Overflow Trigger', description: 'Standard description for overflow. ' * 3);
          
      return TestData(p, [...oldRecords, newRecord]);
    },
  ),

  // 5. APPEND - MULTI-PAGE ADDITION
  VerificationScenario(
    name: '05_append_multipage',
    title: 'Append - Multi-Page Addition',
    description: 'Appending records that span multiple new pages.',
    mode: PrintMode.append,
    setup: (db) async {
      final p = buildTestPerson();
      p.wasPrinted = true;
      
      // Start with small printed content (half page)
      // generateRecordsForPageCount always tries to reach N pages, so getting "half page" is manual
       final oldRecords = await generateRecordsForPageCount(
        targetPages: 1, 
        person: p, 
        db: db, 
        requireExactPages: true
      );
      // Take only first 3 records to simulate partial page
      final partialOld = oldRecords.take(3).toList();
      for(var r in partialOld) r.isPrinted = true;

      // Add 2 pages worth of new content
       final newRecords = await generateRecordsForPageCount(
        targetPages: 2, 
        person: p, 
        db: db, 
        requireExactPages: true
      );
      for(var r in newRecords) {
        r.idZaznamu += 100; // avoid ID collision
        r.isPrinted = false;
      }
      
      return TestData(p, [...partialOld, ...newRecords]);
    },
  ),

    // 6. EDGE - CZECH CHARACTERS
  VerificationScenario(
    name: '06_edge_czech_chars',
    title: 'Edge - Czech Characters',
    description: 'Verify "Příliš žluťoučký kůň" renders correctly in all fields.',
    mode: PrintMode.full,
    setup: (db) async {
      final p = MemoryOsoba.named(
        id: 1,
        jmeno: 'Řehoř',
        prijmeni: 'Ščěřbina',
        datumNarozeni: DateTime(2010, 1, 1),
        zdravotniPojistovna: '111',
        adresa: 'Třístoličník 123, Ústí nad Labem',
        zpusobilost: true,
        bezinfekcnost: true,
      )..poznamka = 'Příliš žluťoučký kůň úpěl ďábelské ódy.';
      
      final r = <MemoryZaznam>[
        MemoryZaznam(
           'Záznam',  // nazev
           'Pacient snědl šťavnaté jablko a cítí se skvěle. ěščřžýáíéúů', // popis
           null,      // poznamka
           1,         // idZaznamu
           -1,        // idAuthor
           1          // idPacient
        )..casZaznamu = DateTime.now()
      ];
      return TestData(p, r);
    },
  ),
  
   // 7. EDGE - MAX LENGTH
  VerificationScenario(
    name: '07_edge_max_length',
    title: 'Edge - Max Length',
    description: 'Very long names and descriptions. Check wrapping and layout breakages.',
    mode: PrintMode.full,
    setup: (db) async {
      final longText = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. ' * 5;
      final p = MemoryOsoba.named(
        id: 1,
        jmeno: 'Maximilianus Aurelius Theophrastus',
        prijmeni: 'Von Hohenzollern-Sigmaringen-Lichtenstein',
        datumNarozeni: DateTime(2000),
        zpusobilost: true,
        bezinfekcnost: true,
      )..poznamka = longText;
      
      final r = <MemoryZaznam>[
        MemoryZaznam(
            'Záznam',
            'EXTREMELY LONG RECORD BODY: $longText $longText',
            null,
            1,
            -1,
            1
        )..casZaznamu = DateTime.now()
      ];
      return TestData(p, r);
    },
  ),
  
  // 8. STRUCTURE - MEDS & RESTRICTIONS
  VerificationScenario(
    name: '08_structure_meds_restr',
    title: 'Structure - Meds & Restrictions',
    description: 'Verify Header sections for Meds and Restrictions appear correctly.',
    mode: PrintMode.full,
    setup: (db) async {
      final p = buildTestPerson();
      final r = await generateRecordsForPageCount(
        targetPages: 1, person: p, db: db
      );
      // Take just 2
      final r2 = r.take(2).toList();

      final List<MemoryLek> meds = [
        MemoryLek.fullNamed(id: 1, nazev: 'Ibalgin 400', popisDavkovani: '1-0-1', idOsoby: 1),
        MemoryLek.fullNamed(id: 2, nazev: 'Zodac', popisDavkovani: 'vecer', idOsoby: 1),
      ];
      final List<MemoryOmezeni> restr = [
        MemoryOmezeni(id: 1, typOmezeni: 2, omezeni: 'Včelí bodnutí', idOsoby: 1), // 2 = Alergie
        MemoryOmezeni(id: 2, typOmezeni: 1, omezeni: 'Bezlepková', idOsoby: 1),    // 1 = Omezeni/Dieta
      ];
      return TestData(p, r2, leky: meds, omezeni: restr);
    },
  ),
];


// -----------------------------------------------------------------------------
// DASHBOARD GENERATOR
// -----------------------------------------------------------------------------

Future<void> _generateHtmlDashboard(
    Directory outputDir, Directory pdfDir, List<VerificationScenario> scenarios) async {
    
  final sb = StringBuffer();
  sb.writeln('<!DOCTYPE html>');
  sb.writeln('<html>');
  sb.writeln('<head>');
  sb.writeln('<title>Visual Verification Dashboard</title>');
  sb.writeln('<style>');
  sb.writeln('body { font-family: sans-serif; max-width: 1000px; margin: 0 auto; padding: 20px; }');
  sb.writeln('table { width: 100%; border-collapse: collapse; margin-top: 20px; }');
  sb.writeln('th, td { border: 1px solid #ddd; padding: 12px; text-align: left; vertical-align: top; }');
  sb.writeln('th { background-color: #f2f2f2; }');
  sb.writeln('tr:nth-child(even) { background-color: #f9f9f9; }');
  sb.writeln('.pass-fail { width: 100px; text-align: center; }');
  sb.writeln('h1 { color: #333; }');
  sb.writeln('.meta { color: #666; font-size: 0.9em; margin-bottom: 20px; }');
  sb.writeln('</style>');
  sb.writeln('</head>');
  sb.writeln('<body>');
  
  sb.writeln('<h1>Visual Verification Dashboard</h1>');
  sb.writeln('<div class="meta">Generated: ${DateTime.now().toLocal()}</div>');
  sb.writeln('<div class="meta">Output: ${outputDir.path}</div>');
  
  sb.writeln('<table>');
  sb.writeln('<thead>');
  sb.writeln('<tr>');
  sb.writeln('<th>Scenario</th>');
  sb.writeln('<th>Description</th>');
  sb.writeln('<th>Action</th>');
  sb.writeln('<th>Verify</th>');
  sb.writeln('</tr>');
  sb.writeln('</thead>');
  sb.writeln('<tbody>');

  for (final s in scenarios) {
    // Relative path for link
    final relativePath = 'generated_pdfs/${s.generatedFilename}';
    
    sb.writeln('<tr>');
    sb.writeln('<td><strong>${s.title}</strong><br><small>${s.mode.name}</small></td>');
    sb.writeln('<td>${s.description}</td>');
    sb.writeln('<td><a href="$relativePath" target="_blank">Open PDF</a></td>');
    sb.writeln('<td class="pass-fail"><input type="checkbox"> Pass</td>');
    sb.writeln('</tr>');
  }

  sb.writeln('</tbody>');
  sb.writeln('</table>');
  
  sb.writeln('</body>');
  sb.writeln('</html>');

  final indexFile = File(p.join(outputDir.path, 'index.html'));
  await indexFile.writeAsString(sb.toString());
}
