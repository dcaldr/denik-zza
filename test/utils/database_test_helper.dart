import 'dart:io';
import 'package:drift/drift.dart' as drift;
import 'package:path/path.dart' as p;
import 'package:denik_zza/database/drift_database/database.dart';
import 'test_output_manager.dart';

enum TestDatabaseType { memory, file }

class DatabaseTestHelper {
  static final Map<String, AppDatabase> _databaseInstances = {};
  static final Map<AppDatabase, String> _pathByInstance = {};
  static int _fileDbCounter = 0;

  static AppDatabase createTestDatabase(TestDatabaseType type) {
    switch (type) {
      case TestDatabaseType.memory:
        return _getOrCreateMemoryDatabase();
      case TestDatabaseType.file:
        return _createFileDatabase();
    }
  }

  static AppDatabase _getOrCreateMemoryDatabase() {
    return AppDatabase.testInMemory();
  }

  static AppDatabase _createFileDatabase() {
    final testDbDir = Directory(TestOutputManager.getDbsDir()).absolute;
    if (!testDbDir.existsSync()) {
      testDbDir.createSync(recursive: true);
    }

    String buildPath() {
      final now = DateTime.now();
      final counter = (_fileDbCounter++ % 1000);
      final numericId = (now.microsecondsSinceEpoch % 100000000) * 1000 + counter;
      return p.join(testDbDir.path, 'testDB_$numericId.db');
    }

    String testDbPath = buildPath();
    int attempts = 0;
    while (File(testDbPath).existsSync() && attempts < 10) {
      testDbPath = buildPath();
      attempts++;
    }

    while (_databaseInstances.containsKey(testDbPath) && attempts < 20) {
      testDbPath = buildPath();
      attempts++;
    }

    final database = AppDatabase(testDbPath);
    _databaseInstances[testDbPath] = database;
    _pathByInstance[database] = testDbPath;
    return database;
  }

  static Future<void> closeTestDatabase(AppDatabase database, {bool cleanup = false}) async {
    String? keyToRemove;
    for (final entry in _databaseInstances.entries) {
      if (identical(entry.value, database)) {
        keyToRemove = entry.key;
        break;
      }
    }
    
    if (keyToRemove != null) {
      _databaseInstances.remove(keyToRemove);
      _pathByInstance.remove(database);
      await database.close();
      if (cleanup) {
        try {
          final file = File(keyToRemove);
          if (await file.exists()) {
            await file.delete();
          }
        } catch (_) {}
      }
    } else {
      _pathByInstance.remove(database);
      await database.close();
    }
  }

  static Future<void> clearAllDatabaseInstances() async {
    final databases = List.from(_databaseInstances.values);
    _databaseInstances.clear();
    _pathByInstance.clear();
    for (final database in databases) {
      try { await database.close(); } catch (_) {}
    }
  }

  static String? getDatabaseFilePath(AppDatabase database) {
    final direct = _pathByInstance[database];
    if (direct != null) return direct;
    for (final entry in _databaseInstances.entries) {
      if (identical(entry.value, database)) {
        final key = entry.key;
        if (key.contains(Platform.pathSeparator) && key.toLowerCase().endsWith('.db')) {
          return key;
        }
        return null;
      }
    }
    return null;
  }
}

class TestDatabaseUtils {
  static InsuranceCompaniesCompanion createSampleInsuranceCompany({
    String name = 'Test Insurance Company',
  }) {
    return InsuranceCompaniesCompanion.insert(name: name);
  }
  
  static ParticipantsCompanion createSampleParticipant({
    String firstName = 'Test',
    String lastName = 'Person', 
    int? zzaActionFK,
    int? insuranceCompanyFK,
  }) {
    return ParticipantsCompanion.insert(
      firstName: firstName,
      lastName: lastName,
      zzaActionFK: zzaActionFK ?? 1,
      insuranceCompanyFK: insuranceCompanyFK != null ? drift.Value(insuranceCompanyFK) : const drift.Value.absent(),
    );
  }
  
  static ZzaActionsCompanion createSampleAction({
    String actionTitle = 'Test Action',
    DateTime? dateFrom,
    DateTime? dateTo,
  }) {
    final now = DateTime.now();
    return ZzaActionsCompanion.insert(
      actionTitle: actionTitle,
      dateFrom: dateFrom ?? now,
      dateTo: dateTo ?? now.add(const Duration(days: 7)),
    );
  }
  
  static RecordsCompanion createSampleRecord({
    String title = 'Test Record',
    String description = 'Test Description',
    required int participantFK,
    required int paramedicFK,
    DateTime? dateAndTime,
  }) {
    return RecordsCompanion.insert(
      title: title,
      description: description,
      participantFK: participantFK,
      paramedicFK: paramedicFK,
      dateAndTime: dateAndTime ?? DateTime.now(),
    );
  }
}
