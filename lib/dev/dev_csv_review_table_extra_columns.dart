import 'package:denik_zza/dev/dev_csv_review_shared.dart';
import 'package:denik_zza/screens2/csv_review_variants/table_overview_screen.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureCsvReviewDevDatabase();
  final String csvPath =
      resolveProjectFile('test/data/multi_person_with_extra_columns.csv');

  runApp(buildDevApp(
    title: 'CSV Review – Extra Columns Test',
    home: CsvReviewTableOverviewScreen(
      filePath: csvPath,
    ),
  ));
}
