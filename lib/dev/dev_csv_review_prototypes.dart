import 'package:denik_zza/dev/dev_csv_review_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureCsvReviewDevDatabase();
  final String csvPath = resolveProjectFile('test/data/dev_bad_import_fixture.csv');

  runApp(_CsvPrototypeSwitcherApp(
    title: 'CSV Prototype – Přepínač variant',
    subtitle: 'dev_bad_import_fixture.csv',
    csvPath: csvPath,
  ));
}

class _CsvPrototypeSwitcherApp extends StatelessWidget {
  const _CsvPrototypeSwitcherApp({
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
      supportedLocales: const <Locale>[Locale('cs', 'CZ')],
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
      ),
      home: _PrototypeSwitcherHome(
        title: title,
        subtitle: subtitle,
        csvPath: csvPath,
      ),
    );
  }
}

class _PrototypeSwitcherHome extends StatefulWidget {
  const _PrototypeSwitcherHome({
    required this.title,
    required this.subtitle,
    required this.csvPath,
  });

  final String title;
  final String subtitle;
  final String csvPath;

  @override
  State<_PrototypeSwitcherHome> createState() => _PrototypeSwitcherHomeState();
}

class _PrototypeSwitcherHomeState extends State<_PrototypeSwitcherHome> {
  CsvReviewPrototypeId _selected = CsvReviewPrototypeId.tableOverview;

  @override
  Widget build(BuildContext context) {
    final CsvReviewPrototypeEntry entry =
        csvReviewPrototypeRegistry[_selected]!;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  widget.subtitle,
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(color: Colors.white70),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Row(
                  children: <Widget>[
                    const Icon(Icons.science_outlined, color: Colors.white70),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<CsvReviewPrototypeId>(
                          key: const Key('CsvPrototypeSwitcher_dropdown'),
                          value: _selected,
                          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                          items: csvReviewPrototypeRegistry.values
                              .map(
                                (CsvReviewPrototypeEntry item) => DropdownMenuItem<CsvReviewPrototypeId>(
                                  value: item.id,
                                  child: Text(item.title),
                                ),
                              )
                              .toList(),
                          onChanged: (CsvReviewPrototypeId? value) {
                            if (value == null) {
                              return;
                            }
                            setState(() {
                              _selected = value;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          Material(
            color: Theme.of(context).colorScheme.surfaceVariant,
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(entry.description),
            ),
          ),
          Expanded(
            child: entry.builder(widget.csvPath),
          ),
        ],
      ),
    );
  }
}
