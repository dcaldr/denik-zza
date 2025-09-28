import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:denik_zza/screens2/csv_review/csv_review_screen.dart';

import 'dev_csv_review_shared.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureCsvReviewDevDatabase();

  runApp(const _CsvReviewPickerApp());
}

class _CsvReviewPickerApp extends StatelessWidget {
  const _CsvReviewPickerApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CSV Review – Pick your own file',
      debugShowCheckedModeBanner: true,
      locale: const Locale('cs', 'CZ'),
      supportedLocales: const [Locale('cs', 'CZ')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
      ),
      home: const _CsvReviewPickerHome(),
    );
  }
}

class _CsvReviewPickerHome extends StatefulWidget {
  const _CsvReviewPickerHome();

  @override
  State<_CsvReviewPickerHome> createState() => _CsvReviewPickerHomeState();
}

class _CsvReviewPickerHomeState extends State<_CsvReviewPickerHome> {
  String? _lastFile;
  String? _error;

  Future<void> _pickCsv() async {
    setState(() {
      _error = null;
    });

    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const <String>['csv'],
    );

    if (result == null) {
      return;
    }

    final String? path = result.files.single.path;
    if (path == null || path.isEmpty) {
      setState(() {
        _error = 'Nebyl vybrán žádný soubor.';
      });
      return;
    }

    final File file = File(path);
    if (!file.existsSync()) {
      setState(() {
        _error = 'Soubor již neexistuje: $path';
      });
      return;
    }

    setState(() {
      _lastFile = path;
    });

    if (!mounted) {
      return;
    }

    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => CsvReviewScreen(filePath: path),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CSV Review – vyberte vlastní soubor'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Tahle dev varianta slouží pro rychlé ověření importu libovolného CSV. '
              'Soubor se načte přímo do obrazovky kontroly importu.',
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              key: const Key('DevCsvReviewPicker_pick_button'),
              onPressed: _pickCsv,
              icon: const Icon(Icons.upload_file),
              label: const Text('Vybrat CSV'),
            ),
            const SizedBox(height: 12),
            if (_lastFile != null)
              Text(
                'Poslední soubor: $_lastFile',
                key: const Key('DevCsvReviewPicker_last_file'),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  _error!,
                  key: const Key('DevCsvReviewPicker_error'),
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
