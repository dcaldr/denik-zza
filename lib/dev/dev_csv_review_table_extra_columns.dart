import 'package:denik_zza/dev/dev_csv_review_shared.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureCsvReviewDevDatabase();
  final String csvPath =
      resolveProjectFile('test/data/multi_person_with_extra_columns.csv');

  runApp(CsvReviewPrototypeDevApp(
    title: 'CSV Prototype – Tabulkový přehled (extra sloupce)',
    subtitle: 'multi_person_with_extra_columns.csv',
    prototypeId: CsvReviewPrototypeId.tableOverview,
    csvPath: csvPath,
  ));
}
