import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:denik_zza/dev/dev_environment.dart';
import 'package:denik_zza/dev/ui/dev_app_builder.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_zaznam.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart'; // Added missing import
import 'package:denik_zza/print_ops2/print_center.dart';
import 'package:denik_zza/print_ops2/print_center_controller.dart';
import 'package:denik_zza/print_ops2/print_center_service.dart';
import 'package:denik_zza/database/database_wrapper.dart';
import 'package:denik_zza/database/database_interface.dart';
// import 'package:denik_zza/dev/ui/dev_meta_app.dart'; // Removed bad import

/// Development entry point for verifying APPEND mode scenarios.
/// Usage: flutter run -t lib/dev/dev_print_append_scenario.dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DevEnvironment.initialize();
  await runScenario();
}

Future<void> runScenario() async {
  final db = DatabaseWrapper.getDatabase();
  await _ensureDbConnection(db);

  // 1. Create Person
  final personId = await _createPerson(db);
  // debugPrint('SCENARIO: Created Person ID: $personId');

  // Mark Person as Printed
  await db.setParticipantPrintedValue(personId, true);

  // 2. Create Records (Explicitly 4, sorted by expected timeline)
  // We want 3 PRINTED, 1 UNPRINTED (Last one)
  final now = DateTime.now();

  // Record 1: Oldest - Printed
  await _addRecord(db, personId, "Dřívější záznam 1",
      now.subtract(const Duration(hours: 3)), true);

  // Record 2: Middle - Printed
  await _addRecord(db, personId, "Dřívější záznam 2",
      now.subtract(const Duration(hours: 2)), true);

  // Record 3: Recent - Printed
  await _addRecord(db, personId, "Dřívější záznam 3",
      now.subtract(const Duration(hours: 1)), true);

  // Record 4: Newest (Hudební terapie) - NOT PRINTED
  await _addRecord(db, personId, "Hudební terapie", now, false);

  // debugPrint('SCENARIO: Records created. Verifying DB state...');

  // 3. Verify DB State (Read-After-Write)
  final records = await db.getRecordsByParticipantID(personId);
  // Sort by Date to match PDF order
  records.sort((a, b) => a.casZaznamu!.compareTo(b.casZaznamu!));

  bool verificationPassed = true;
  for (var r in records) {
    // debugPrint('DB CHECK: "${r.nazev}" -> isPrinted: ${r.isPrinted}');

    if (r.nazev == "Hudební terapie") {
      if (r.isPrinted) {
        debugPrint('!!! ERROR: Hudební terapie SHOULD form NOT be printed !!!');
        verificationPassed = false;
      }
    } else {
      if (!r.isPrinted) {
        debugPrint('!!! ERROR: ${r.nazev} SHOULD be printed !!!');
        verificationPassed = false;
      }
    }
  }

  if (!verificationPassed) {
    debugPrint('SCENARIO FAILED: DB State is incorrect. Aborting UI launch.');
    return;
  }

  // debugPrint('SCENARIO: DB Verification PASSED. Launching UI...');

  // 4. Launch App
  runApp(buildDevAppWithBanner(
    title: 'Print Verify Append',
    bannerMessage: 'APPEND VERIFY',
    bannerIcon: Icons.playlist_add_check,
    home: DevAutoPilot(
      personId: personId,
    ),
  ));
}

Future<void> _addRecord(DatabaseInterface db, int personId, String title,
    DateTime time, bool setPrinted) async {
  final record = MemoryZaznam.fullNamed(
    idZaznamu: -1, // Auto-id
    idPacient: personId,
    idAuthor: 1,
    nazev: title,
    popis: setPrinted
        ? "Tento záznam již byl vytištěn v minulosti."
        : "Vltava mu teče v uších, doporučujeme méně klavíru",
    casZaznamu: time,
    poznamka: "",
    isPrinted: false, // Default false, will update if needed

    // Add required fields for fullNamed
    teplota: null,
    obrazekPath: null,
  );

  // 1. Add (returns bool, not ID in interface, but we don't need distinct ID here if we fetch by Person)
  await db.addZaznam(record);

  if (setPrinted) {
    // To set 'wasPrinted', we need the ID. Since addZaznam doesn't return ID easily in Interface,
    // we must fetch records, find this one, and update it.
    // This is inefficient but safe for a test script.
    final all = await db.getRecordsByParticipantID(personId);
    // Find the one we just added (by title/time)
    final justAdded = all.firstWhere((r) => r.nazev == title);
    await db.setRecordPrintedValue(justAdded.idZaznamu, true);
  }
}

Future<int> _createPerson(DatabaseInterface db) async {
  // Simple person generator
  final p = MemoryOsoba.fullNamed(
    id: -1,
    jmeno: "Jan",
    prijmeni: "Novak",

    // Required fields
    pohlavi: 1, // 1 = Male
    adresa: "Testovaci 1",
    cisloPojisteni: "123456/7890",
    datumNarozeni: DateTime(2000, 1, 1),
    telefonRodice: "123456789",
    zpusobilost: true,
    bezinfekcnost: true,
    wasPrinted: false,

    // Optional
    zdravotniPojistovna: "VZP",
    jmenoRodice: "Petr Novak",
    emailRodice: "rodic@test.com",
    poznamka: "",
    oddil: "1",
    prisel: true,
    potvrzeniPath: "",
  );
  return (await db.addOsobaAndReturnId(p))!;
}

Future<void> _ensureDbConnection(DatabaseInterface db) async {
  // Just a dummy call to wake it up if needed
  await db.getAllZzaActions();
}

class DevAutoPilot extends StatefulWidget {
  final int personId;
  const DevAutoPilot({super.key, required this.personId});

  @override
  State<DevAutoPilot> createState() => _DevAutoPilotState();
}

class _DevAutoPilotState extends State<DevAutoPilot> {
  bool _navigated = false;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final service = PrintCenterService();
        final controller = PrintCenterController(service);
        controller.init();
        return controller;
      },
      child: Consumer<PrintCenterController>(
        builder: (context, ctrl, _) {
          if (ctrl.loadingParticipants) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (!_navigated && ctrl.participants.isNotEmpty) {
            // Auto-navigate to our person
            // Note: ctrl.participants might not have the freshest 'wasPrinted' flag if it was loaded before our update.
            // But main() update should have happened before UI init.

            final person = ctrl.participants.firstWhere(
                (p) => p.id == widget.personId,
                orElse: () => ctrl.participants.first);

            // Force local update just in case memory cache is stale
            person.wasPrinted = true;

            _navigated = true;
            // Schedule navigation
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider.value(
                    value: context.read<PrintCenterController>(),
                    child: PersonAndModeFlowPage(
                      initialParticipant: person,
                      initialMode: PrintMode.append,
                    ),
                  ),
                ),
              );
            });
          }

          return const Scaffold(
            body: Center(child: Text('Redirecting to Append Scenario...')),
          );
        },
      ),
    );
  }
}
