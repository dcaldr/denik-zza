import 'package:denik_zza/dev/dev_csv_review_shared.dart';
import 'package:denik_zza/screens2/csv/table_overview_screen.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureCsvReviewDevDatabase();
  final String csvPath =
      resolveProjectFile('test/data/dev_bad_import_fixture.csv');

  runApp(buildDevApp(
    title: 'CSV Review – Tabulkový přehled',
    home: CsvReviewTableOverviewScreen(
      filePath: csvPath,
    ),
  ));
}
