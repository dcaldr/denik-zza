import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:denik_zza/screens2/csv_review/csv_review_screen.dart';

import 'dev_csv_review_shared.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureCsvReviewDevDatabase();

  final String csvPath = resolveProjectFile('test/data/dev_bad_import_fixture.csv');

  runApp(_CsvReviewDevApp(
    title: 'CSV Review – Mixed Issues Fixture',
    subtitle: 'dev_bad_import_fixture.csv',
    csvPath: csvPath,
  ));
}

class _CsvReviewDevApp extends StatelessWidget {
  const _CsvReviewDevApp({
    required this.title,
    required this.subtitle,
    required this.csvPath,
  });

  final String title;
  final String subtitle;
  final String csvPath;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      debugShowCheckedModeBanner: true,
      locale: const Locale('cs', 'CZ'),
      supportedLocales: const [Locale('cs', 'CZ')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
      ),
      home: _CsvReviewDevHome(title: title, subtitle: subtitle, csvPath: csvPath),
    );
  }
}

class _CsvReviewDevHome extends StatelessWidget {
  const _CsvReviewDevHome({
    required this.title,
    required this.subtitle,
    required this.csvPath,
  });

  final String title;
  final String subtitle;
  final String csvPath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(32),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              subtitle,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.white70),
            ),
          ),
        ),
      ),
      body: CsvReviewScreen(filePath: csvPath),
    );
  }
}
