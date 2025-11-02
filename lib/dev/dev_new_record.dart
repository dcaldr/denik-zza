import 'package:denik_zza/dev/dev_environment.dart';
import 'package:denik_zza/dev/ui/dev_app_builder.dart';
import 'package:denik_zza/screens2/new_record_page.dart';
import 'package:denik_zza/database/database_wrapper.dart';
import 'package:flutter/material.dart';

/// Development entry point for testing NewRecordPage (Nový záznam úrazu)
/// 
/// This provides a pre-configured environment with:
/// - Test event "Test Test Test" created and selected
/// - 10 Czech participants with cultural references
/// - 10 medical records with easter eggs
/// - First participant (Václav Havlík) pre-selected
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
  await DevEnvironment.initialize();
  
  // Get first participant (DevEnvironment now creates 3 participants)
  final db = DatabaseWrapper.getDatabase();
  final participants = await db.getParticipantsByCurrentEvent();
  final firstParticipant = participants.isNotEmpty ? participants.first : null;

  runApp(buildDevAppWithBanner(
    title: 'Nový záznam úrazu - Dev Mode',
    bannerMessage: 'NewRecordPage with pre-selected participant',
    bannerIcon: Icons.medical_services,
    home: NewRecordPage(participant: firstParticipant),
  ));
}
