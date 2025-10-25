import 'package:denik_zza/dev/dev_csv_review_shared.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureCsvReviewDevDatabase();

  runApp(const CsvReviewPrototypeDevApp(
    title: 'CSV Prototype – Importní flow',
    subtitle:
        'Vyberte soubor pomocí tlačítka (doporučeno: test/data/multi_person_with_extra_columns.csv).',
    prototypeId: CsvReviewPrototypeId.importFlow,
    csvPath: 'test/data/multi_person_with_extra_columns.csv',
  ));
}
