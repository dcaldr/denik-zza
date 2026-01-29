import 'package:denik_zza/dev/dev_environment.dart';
import 'package:denik_zza/dev/ui/dev_app_builder.dart';
import 'package:denik_zza/screens2/new_record/new_record_page.dart';
import 'package:denik_zza/database/database_wrapper.dart';
import 'package:denik_zza/database/drift_database/database.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';

/// Development entry point for testing NewRecordPage (Nový záznam úrazu)
/// 
/// This provides a pre-configured environment with:
/// - Test event "Test Test Test" created and selected
/// - 10 Czech participants with cultural references
/// - 10 medical records with easter eggs
/// - First participant (Václav Havel) pre-selected
/// 
/// 🎯 **Perfect for:**
/// - Testing NewRecordPage UI and functionality
/// - Developing record creation features
/// - Testing with pre-selected participant
/// 
/// 💡 **Note:** Now uses same data as HardcodedTestSetup (10 participants + records)
/// 
/// 🚀 **To run:** `flutter run -t lib/dev/dev_new_record.dart`

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Capture the specific drift database instance to allow adding companions directly
  final mockDb = await DevEnvironment.initialize();
  
  // Get first participant (DevEnvironment now creates 3 participants)
  final db = DatabaseWrapper.getDatabase();
  final participants = await db.getParticipantsByCurrentEvent();
  final firstParticipant = participants.isNotEmpty ? participants.first : null;

  // Add extra dummy records for visualization if participant exists
  if (firstParticipant != null) {
    // Add 3 extra records to show scrolling/list behavior
    final extras = [
      'Říznutí do prstu při krájení cibule',
      'Včelí bodnutí do nohy', 
      'Odřené koleno na hřišti'
    ];
    
    for (var i = 0; i < extras.length; i++) {
       await mockDb.addRecord(
        RecordsCompanion(
          title: Value(extras[i]),
          description: Value('Automaticky generovaný testovací záznam ${i + 1}'),
          note: const Value('Dev mode data'),
          participantFK: Value(firstParticipant.id),
          paramedicFK: const Value(1), // Default admin
          dateAndTime: Value(DateTime.now().subtract(Duration(days: i + 1))),
          wasPrinted: const Value(false),
        ),
      );
    }
  }

  runApp(buildDevAppWithBanner(
    title: 'Nový záznam úrazu - Dev Mode',
    bannerMessage: 'NewRecordPage with pre-selected participant',
    bannerIcon: Icons.medical_services,
    home: NewRecordPage(participant: firstParticipant),
  ));
}
