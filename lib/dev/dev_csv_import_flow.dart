import 'package:denik_zza/dev/dev_csv_review_shared.dart';
import 'package:denik_zza/dev/dev_environment.dart';
import 'package:denik_zza/screens2/csv/import_screen.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DevEnvironment.initialize();

  runApp(buildDevApp(
    title: 'CSV Import Flow Dev',
    home: const CsvImportScreen(),
  ));
}
