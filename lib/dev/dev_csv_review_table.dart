import 'package:denik_zza/dev/dev_csv_review_shared.dart';
import 'package:denik_zza/dev/dev_environment.dart';
import 'package:denik_zza/dev/ui/dev_app_builder.dart';
import 'package:denik_zza/screens2/csv/table_overview_screen.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DevEnvironment.initialize();
  final String csvPath =
      resolveProjectFile('test/data/dev_bad_import_fixture.csv');

  runApp(buildDevAppWithBanner(
    title: 'CSV Review – Tabulkový přehled',
    bannerMessage: 'CSV Table Review - Bad Data Test',
    bannerIcon: Icons.table_chart,
    home: CsvReviewTableOverviewScreen(
      filePath: csvPath,
    ),
  ));
}
