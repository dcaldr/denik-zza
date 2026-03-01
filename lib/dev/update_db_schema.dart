// ignore_for_file: avoid_print
// One-time script to add printerPage1OnTop column to existing databases
// Run: flutter run -t lib/dev/update_db_schema.dart -d windows

import 'dart:io';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

void main() async {
  print('=== Database Schema Update Script ===\n');
  
  // Get the default database path
  final appDocsDir = await getApplicationDocumentsDirectory();
  final dbPath = p.join(appDocsDir.path, 'denik_zza', 'db.sqlite');
  final dbFile = File(dbPath);
  
  if (!dbFile.existsSync()) {
    print('Database not found at: $dbPath');
    print('Nothing to update - new databases will have the column automatically.');
    return;
  }
  
  print('Found database at: $dbPath');
  print('Adding printer_page1_on_top column to cache table...\n');
  
  final db = NativeDatabase(dbFile);
  
  try {
    // Check if column already exists
    final result = await db.runSelect('PRAGMA table_info(cache)', []);
    final hasColumn = result.any((row) => row['name'] == 'printer_page1_on_top');
    
    if (hasColumn) {
      print('Column already exists. Nothing to do.');
    } else {
      // Add the new column
      await db.runCustom(
        'ALTER TABLE cache ADD COLUMN printer_page1_on_top INTEGER',
      );
      print('SUCCESS: Column added!');
    }
  } catch (e) {
    print('ERROR: $e');
  } finally {
    await db.close();
  }
  
  print('\nDone. You can now run the app normally.');
}
