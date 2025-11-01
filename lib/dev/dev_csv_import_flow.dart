import 'package:denik_zza/dev/dev_environment.dart';
import 'package:denik_zza/dev/ui/dev_app_builder.dart';
import 'package:denik_zza/screens2/csv/import_screen.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DevEnvironment.initialize();

  runApp(buildDevAppWithBanner(
    title: 'CSV Import Flow Dev',
    bannerMessage: 'CSV Import Flow (In-Memory DB)',
    bannerIcon: Icons.upload_file,
    home: const CsvImportScreen(),
    useDeepOrangeTheme: true,
  ));
}
