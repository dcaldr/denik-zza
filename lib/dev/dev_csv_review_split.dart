import 'package:denik_zza/dev/dev_csv_review_shared.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureCsvReviewDevDatabase();
  final String csvPath = resolveProjectFile('test/data/dev_bad_import_fixture.csv');

  runApp(CsvReviewPrototypeDevApp(
    title: 'CSV Prototype – Dvou-panelový přehled',
    subtitle: 'dev_bad_import_fixture.csv',
    prototypeId: CsvReviewPrototypeId.splitWorkspace,
    csvPath: csvPath,
  ));
}
