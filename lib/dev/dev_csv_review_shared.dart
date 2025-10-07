import 'dart:io';

import 'package:denik_zza/database/database_wrapper.dart';
import 'package:denik_zza/database/drift_database/database.dart';
import 'package:denik_zza/screens2/csv_review_variants/card_gallery_screen.dart';
import 'package:denik_zza/screens2/csv_review_variants/checklist_screen.dart';
import 'package:denik_zza/screens2/csv_review_variants/split_workspace_screen.dart';
import 'package:denik_zza/screens2/csv_review_variants/table_overview_screen.dart';
import 'package:denik_zza/services/csv_import_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:path/path.dart' as p;

/// Boots an in-memory database so CSV review dev mains never touch
/// production storage. Returns the configured [AppDatabase] so callers can
/// optionally seed data.
Future<AppDatabase> configureCsvReviewDevDatabase() async {
  DatabaseWrapper.setTestMode();
  final AppDatabase database = AppDatabase.testInMemory();
  DatabaseWrapper.useTestDriftDatabase(database);
  return database;
}

/// Resolves a relative project path to an absolute location and validates that
/// the file exists. Throws [StateError] if the target cannot be found.
String resolveProjectFile(String relativePath) {
  final String absolutePath =
      p.normalize(p.join(Directory.current.path, relativePath));
  if (!File(absolutePath).existsSync()) {
    throw StateError('Fixture not found: $absolutePath');
  }
  return absolutePath;
}

/// Identifiers for available CSV review prototypes.
enum CsvReviewPrototypeId {
  tableOverview,
  checklist,
  cardGallery,
  splitWorkspace,
}

/// Metadata describing a CSV review prototype variant.
class CsvReviewPrototypeEntry {
  const CsvReviewPrototypeEntry({
    required this.id,
    required this.title,
    required this.description,
    required this.builder,
  });

  final CsvReviewPrototypeId id;
  final String title;
  final String description;
  final Widget Function(String filePath, {CsvReviewService? service}) builder;
}

/// Registry of prototype implementations used by the dev launchers.
const Map<CsvReviewPrototypeId, CsvReviewPrototypeEntry> csvReviewPrototypeRegistry =
    <CsvReviewPrototypeId, CsvReviewPrototypeEntry>{
  CsvReviewPrototypeId.tableOverview: CsvReviewPrototypeEntry(
    id: CsvReviewPrototypeId.tableOverview,
    title: 'Tabulkový přehled',
    description: 'Sticky souhrn, DataTable s inline úpravami a rychlými bulk akcemi.',
    builder: _buildTableOverview,
  ),
  CsvReviewPrototypeId.checklist: CsvReviewPrototypeEntry(
    id: CsvReviewPrototypeId.checklist,
    title: 'Kontrolní seznam',
    description: 'Tříkrokový průvodce se zaměřením na ujištění a jasné instrukce.',
    builder: _buildChecklist,
  ),
  CsvReviewPrototypeId.cardGallery: CsvReviewPrototypeEntry(
    id: CsvReviewPrototypeId.cardGallery,
    title: 'Katalog osob',
    description: 'Stavové sekce s kartami, badge duplikátů a rychlými rozhodnutími.',
    builder: _buildCardGallery,
  ),
  CsvReviewPrototypeId.splitWorkspace: CsvReviewPrototypeEntry(
    id: CsvReviewPrototypeId.splitWorkspace,
    title: 'Dvou-panelový přehled',
    description: 'Seznam vlevo, detailní editace v panelech pro zkušené uživatele.',
    builder: _buildSplitWorkspace,
  ),
};

Widget _buildTableOverview(String filePath, {CsvReviewService? service}) {
  return CsvReviewTableOverviewScreen(filePath: filePath, service: service);
}

Widget _buildChecklist(String filePath, {CsvReviewService? service}) {
  return CsvReviewChecklistScreen(filePath: filePath, service: service);
}

Widget _buildCardGallery(String filePath, {CsvReviewService? service}) {
  return CsvReviewCardGalleryScreen(filePath: filePath, service: service);
}

Widget _buildSplitWorkspace(String filePath, {CsvReviewService? service}) {
  return CsvReviewSplitWorkspaceScreen(filePath: filePath, service: service);
}

/// Common Material app used by prototype dev entry points.
class CsvReviewPrototypeDevApp extends StatelessWidget {
  const CsvReviewPrototypeDevApp({
    super.key,
    required this.title,
    required this.subtitle,
    required this.prototypeId,
    required this.csvPath,
  });

  final String title;
  final String subtitle;
  final CsvReviewPrototypeId prototypeId;
  final String csvPath;

  @override
  Widget build(BuildContext context) {
    final CsvReviewPrototypeEntry? entry =
        csvReviewPrototypeRegistry[prototypeId];
    if (entry == null) {
      throw ArgumentError('Unknown prototype: $prototypeId');
    }

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
      home: CsvReviewPrototypeHome(
        title: title,
        subtitle: subtitle,
        entry: entry,
        csvPath: csvPath,
      ),
    );
  }
}

/// Home scaffold shared across prototype dev mains.
class CsvReviewPrototypeHome extends StatelessWidget {
  const CsvReviewPrototypeHome({
    super.key,
    required this.title,
    required this.subtitle,
    required this.entry,
    required this.csvPath,
  });

  final String title;
  final String subtitle;
  final CsvReviewPrototypeEntry entry;
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
              key: const Key('CsvPrototype_subtitle'),
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(color: Colors.white70),
            ),
          ),
        ),
      ),
      body: entry.builder(csvPath),
    );
  }
}
