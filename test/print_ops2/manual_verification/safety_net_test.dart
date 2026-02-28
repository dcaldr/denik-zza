
import 'dart:io';

import 'package:denik_zza/database/database_wrapper.dart';
import 'package:denik_zza/database/drift_database_connector.dart';

import 'package:denik_zza/print_ops2/generate_pdf_template.dart';
import 'package:denik_zza/utils/mode_coordinator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'package:pdf/widgets.dart' as pw;
import 'package:denik_zza/print_ops2/pdf_fonts.dart';

import '../../utils/print_test_helpers.dart';

void main() {
  late Directory outputDir;
  late pw.ThemeData theme;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    
    // Mock path_provider
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel('plugins.flutter.io/path_provider'), (MethodCall methodCall) async {
        if (methodCall.method == 'getApplicationDocumentsDirectory') {
          return Directory.current.path;
        }
        if (methodCall.method == 'getTemporaryDirectory') {
          return Directory.systemTemp.path;
        }
        return null;
      });

    await ModeCoordinator.setIntegrationTestMode(testName: 'safety_net');
    theme = await PdfFonts.loadTheme();
    
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.').first;
    outputDir = Directory(p.join(Directory.current.path, 'test_outputs', 'safety_net', timestamp));
    
    if (await outputDir.exists()) await outputDir.delete(recursive: true);
    await outputDir.create(recursive: true);
  });

  tearDownAll(() async {
    await ModeCoordinator.setProductionMode();
  });

  test('Safety Net: Verify Append Blocking and Engine Resilience', () async {
    final dbInterface = DatabaseWrapper.getDatabase();
    if (dbInterface is! DriftDatabaseConnector) fail('Wrong DB type');

    
    // -------------------------------------------------------------------------
    // SCENARIO 1: The "Gap" (Broken Sequence)
    // -------------------------------------------------------------------------
    // Context: User printed #1 and #3, but #2 failed or was skipped.
    // State: [T, F, T]
    // Expectation: 
    //   1. canAppend() == FALSE (Strict Validation blocks usage)
    //   2. If forced, engine prints "Patch" (Only #2 visible? Or does it break?)
    // debugPrint('Testing Scenario 1: Gap [T, F, T]');
    
    final p1 = buildTestPerson(id: 1, jmeno: 'Jan', prijmeni: 'Gap');
    p1.wasPrinted = true;
    
    final r1 = buildTestRecord(id: 1, participantId: 1, title: 'Rec 1', description: 'Printed')..isPrinted = true;
    final r2 = buildTestRecord(id: 2, participantId: 1, title: 'Rec 2', description: 'SKIPPED')..isPrinted = false;
    final r3 = buildTestRecord(id: 3, participantId: 1, title: 'Rec 3', description: 'Printed')..isPrinted = true;
    
    // Ensure chronological order
    r1.casZaznamu = DateTime(2023, 1, 1, 10, 0);
    r2.casZaznamu = DateTime(2023, 1, 1, 11, 0);
    r3.casZaznamu = DateTime(2023, 1, 1, 12, 0);
    
    final template1 = GeneratePdfTemplate.named(osoba: p1, zaznamList: [r1, r2, r3]);
    
    // CHECK 1: Must BLOCK
    final canAppend1 = template1.canAppend();
    expect(canAppend1, false, reason: 'canAppend MUST be false for [T, F, T] sequence');
    
    // CHECK 2: Engine Resilience (Force Build)
    // We expect analyzeAndBuildAppend to handle this without crashing.
    // Ideally, it might mask T records and print F record.
    try {
      final result = await template1.analyzeAndBuildAppend(
        theme: theme,
        osoba: p1, 
        zaznamList: [r1, r2, r3]
      );
      final file1 = File(p.join(outputDir.path, '01_gap_forced.pdf'));
      await file1.writeAsBytes(result.pdfBytes);
      // debugPrint('  -> Engine survived [T, F, T]. PDF generated: ${file1.path}');
    } catch (e) {
      fail('Engine CRASHED on [T, F, T]: $e');
    }

    // -------------------------------------------------------------------------
    // SCENARIO 2: The "Overlap" (Insert Middle)
    // -------------------------------------------------------------------------
    // Context: User inserted a new record chronologically between printed ones.
    // State: [T, F (new), T]  <-- Logically same as Gap, but physically dangerous
    // Expectation: canAppend() == FALSE
    // debugPrint('Testing Scenario 2: Overlap [T, F(new), T]');

    final p2 = buildTestPerson(id: 2, jmeno: 'Eva', prijmeni: 'Overlap');
    p2.wasPrinted = true;
     
    final rA = buildTestRecord(id: 10, participantId: 2, title: 'Morning', description: 'Printed')..isPrinted = true;
    final rB = buildTestRecord(id: 11, participantId: 2, title: 'Noon Insert', description: 'DANGER')..isPrinted = false;
    final rC = buildTestRecord(id: 12, participantId: 2, title: 'Evening', description: 'Printed')..isPrinted = true;
    
    rA.casZaznamu = DateTime(2023, 1, 1, 8, 0);
    rB.casZaznamu = DateTime(2023, 1, 1, 12, 0); // Middle
    rC.casZaznamu = DateTime(2023, 1, 1, 20, 0);
    
    final template2 = GeneratePdfTemplate.named(osoba: p2, zaznamList: [rA, rB, rC]);
    
    // CHECK 1: Must BLOCK
    final canAppend2 = template2.canAppend();
    expect(canAppend2, false, reason: 'canAppend MUST be false for inserted middle record');

  });
}
