import 'package:denik_zza/database/drift_database/database.dart';
import 'seeders/jursky_park_seeder.dart';

/// Data volume levels for simulation profiles.
///
/// Used to control the amount of test data seeded into the database.
enum DataVolume {
  /// Minimal seed data - only what's absolutely necessary for tests to run.
  /// Example: 1 event, 1 paramedic, 2-3 participants, 0-2 records.
  minimal,

  /// Standard representative dataset - realistic camp scenario.
  /// Example: 1 event, 1 paramedic, 15 participants, varied medical scenarios.
  standard,

  /// Stress test dataset - maximum realistic load.
  /// Example: Multiple events, multiple paramedics, 50+ participants, heavy medical records.
  stress,
}

/// Configuration for database seeding in integration tests.
///
/// Following the testing strategy defined in `integration_test/testing strategy.md`,
/// this class provides structured control over test data volume and complexity.
///
/// ## Usage:
/// ```dart
/// // For protected flow (canary) tests
/// final minimal = SimulationProfile.minimal();
/// await seedDatabase(database, minimal);
///
/// // For general functional tests
/// final standard = SimulationProfile.standard();
/// await seedDatabase(database, standard);
///
/// // For performance/breakdown tests
/// final stress = SimulationProfile.stress();
/// await seedDatabase(database, stress);
/// ```
class SimulationProfile {
  final DataVolume volume;
  final bool simulateNetworkDelay;

  const SimulationProfile._({
    required this.volume,
    this.simulateNetworkDelay = false,
  });

  /// Minimal profile: Clean state with minimal seeds.
  ///
  /// Used for:
  /// - Protected flow (canary) tests
  /// - Fast smoke tests
  /// - Tests requiring empty or near-empty database
  ///
  /// Generates:
  /// - 1 event (Jurský park - current day to +7 days)
  /// - 1 paramedic
  /// - 2 participants (1 with records, 1 without)
  /// - 1-2 medical records total
  factory SimulationProfile.minimal() {
    return const SimulationProfile._(
      volume: DataVolume.minimal,
      simulateNetworkDelay: false,
    );
  }

  /// Standard profile: Representative realistic dataset.
  ///
  /// Used for:
  /// - General E2E functional tests
  /// - UI walkthroughs
  /// - CSV import/export tests
  /// - Print logic tests
  ///
  /// Generates:
  /// - 1 event (Jurský park - July 10-24, 2025)
  /// - 1 paramedic (Jana Zdravotníková)
  /// - 15 participants (Czech historical figures)
  /// - 0-13 medical records per participant (64 total)
  /// - Medications, allergies, limitations
  /// - Insurance companies (VZP, OZP)
  factory SimulationProfile.standard() {
    return const SimulationProfile._(
      volume: DataVolume.standard,
      simulateNetworkDelay: false,
    );
  }

  /// Stress profile: Maximum capacity dataset.
  ///
  /// Used for:
  /// - Performance tests
  /// - Breakdown/adversarial tests
  /// - Testing pagination and scrolling under load
  ///
  /// Generates:
  /// - 3 events (past, current, future)
  /// - 3 paramedics
  /// - 50 participants distributed across events
  /// - Heavy medical record load (500+ records total)
  /// - Maximum medications/allergies/limitations
  factory SimulationProfile.stress() {
    return const SimulationProfile._(
      volume: DataVolume.stress,
      simulateNetworkDelay: false,
    );
  }
}

/// Seeds the database based on the provided simulation profile.
///
/// This is the main entry point for populating test databases.
/// Implementation delegates to specific seeders based on profile volume.
Future<void> seedDatabase(
    AppDatabase database, SimulationProfile profile) async {
  switch (profile.volume) {
    case DataVolume.minimal:
      // TODO: Implement minimal seeder
      throw UnimplementedError('Minimal seeder not yet implemented');

    case DataVolume.standard:
      // Use Jurský Park seeder for realistic camp scenario
      await JurskyParkSeeder.seed(database);
      break;

    case DataVolume.stress:
      // TODO: Implement stress seeder
      throw UnimplementedError('Stress seeder not yet implemented');
  }
}
