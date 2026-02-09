import 'package:flutter_test/flutter_test.dart';
import 'package:denik_zza/database/drift_database/database.dart';
import 'package:denik_zza/database/database_wrapper.dart';
import 'package:denik_zza/database/drift_database_connector.dart';
import 'package:denik_zza/utils/mode_coordinator.dart';
import 'package:drift/drift.dart';

void main() {
  late AppDatabase db;
  late DriftDatabaseConnector connector;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    ModeCoordinator.setTestingMode(); // Use in-memory
    db = AppDatabase.testInMemory();
    connector = DriftDatabaseConnector.withDatabase(db);
  });

  tearDown(() async {
    await connector.close();
  });

  test('Drift stream should emit participants', () async {
    // 1. Setup Data
    final now = DateTime.now();
    final eventId = await db.addZzaAction(ZzaActionsCompanion(
      actionTitle: const Value('Test Event'),
      actionDescription: const Value('Desc'),
      dateFrom: Value(now),
      dateTo: Value(now.add(const Duration(days: 1))),
    ));

    // UPDATE CACHE (Critical step)
    await db.updateCache(CacheCompanion(
      id: const Value(1),
      currentActionID: Value(eventId),
    ));

    // Add a participant
    await db.addParticipant(ParticipantsCompanion(
      firstName: const Value('Jan'),
      lastName: const Value('Novak'),
      zzaActionFK: Value(eventId),
      gender: const Value(1),
      birthDate: Value(DateTime(1990)),
      birthNumber: const Value('900101/1234'),
      address: const Value('Prague'),
      // Add other required fields if needed by constraints
    ));

    // 2. Listen to Stream
    print('Subscribing to stream...');
    final stream = connector.watchParticipantsByCurrentEvent();
    
    final emission = await stream.first.timeout(const Duration(seconds: 3));
    
    print('Emitted: ${emission.length} participants');
    expect(emission.length, 1);
    expect(emission.first.jmeno, 'Jan');
  });
}
