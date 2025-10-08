import 'package:denik_zza/dev/dev_csv_review_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

const bool _enableDebugDump = bool.fromEnvironment(
  'CSV_DEV_DEBUG_DUMP',
  defaultValue: false,
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (_enableDebugDump) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future<void>.delayed(const Duration(seconds: 3), () {
        debugPrint('--- debugDumpApp start ---');
        debugDumpApp();
        debugPrint('--- debugDumpApp end ---');
      });
    });
  }
  await configureCsvReviewDevDatabase();
  final String csvPath = resolveProjectFile('test/data/dev_bad_import_fixture.csv');

  runApp(CsvReviewPrototypeDevApp(
    title: 'CSV Prototype – Dvou-panelový přehled',
    subtitle: 'dev_bad_import_fixture.csv',
    prototypeId: CsvReviewPrototypeId.splitWorkspace,
    csvPath: csvPath,
  ));
}
