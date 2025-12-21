import 'package:denik_zza/database/drift_database/database.dart';
import 'seeders/generated_seeder.dart';
import 'seeders/jursky_park_seeder.dart';

/// Data volume levels for simulation profiles.
///
/// Used to control the amount of test data seeded into the database.
/// All profiles use the unified [TestParticipant] format.
enum DataVolume {
  /// Standard dataset: 15 participants - Canary + normal operations.
  /// Uses Jurský Park dataset (Czech historical figures).
  standard,

  /// Medium dataset: 50 participants.
  /// TODO: Implement medium seeder
  medium,

  /// Large dataset: 100 participants.
  /// TODO: Implement generated seeder
  large,

  /// Extra large dataset: 130 participants.
  /// TODO: Implement generated seeder
  xlarge,

  /// Stress test dataset: ~300 participants.
  /// TODO: Implement generated seeder
  stress,
}

/// Configuration for database seeding in integration tests.
///
/// Following the testing strategy defined in `integration_test/testing strategy.md`,
/// this class provides structured control over test data volume and complexity.
///
/// All datasets use the unified [TestParticipant] format, ensuring robots and
/// seeders work identically regardless of volume tier.
///
/// ## Usage:
/// ```dart
/// // For canary/standard tests (15 participants)
/// final standard = SimulationProfile.standard();
/// await seedDatabase(database, standard);
///
/// // For load testing (50 participants)
/// final medium = SimulationProfile.medium();
/// await seedDatabase(database, medium);
/// ```
class SimulationProfile {
  final DataVolume volume;
  final bool simulateNetworkDelay;

  const SimulationProfile._({
    required this.volume,
    this.simulateNetworkDelay = false,
  });

  /// Standard profile: 15 Czech historical figures (Jurský park).
  ///
  /// Used for:
  /// - Canary/smoke tests
  /// - Normal E2E functional tests
  /// - UI walkthroughs
  /// - Print logic tests
  ///
  /// Dataset: `datasets/jursky_park_data.dart`
  factory SimulationProfile.standard() {
    return const SimulationProfile._(
      volume: DataVolume.standard,
      simulateNetworkDelay: false,
    );
  }

  /// Medium profile: 50 hand-crafted participants.
  ///
  /// Used for:
  /// - Load testing
  /// - Scroll performance
  factory SimulationProfile.medium() {
    return const SimulationProfile._(
      volume: DataVolume.medium,
      simulateNetworkDelay: false,
    );
  }

  /// Large profile: 100 generated participants.
  ///
  /// Used for:
  /// - Volume testing
  /// - Pagination testing
  factory SimulationProfile.large() {
    return const SimulationProfile._(
      volume: DataVolume.large,
      simulateNetworkDelay: false,
    );
  }

  /// Extra large profile: 130 generated participants.
  factory SimulationProfile.xlarge() {
    return const SimulationProfile._(
      volume: DataVolume.xlarge,
      simulateNetworkDelay: false,
    );
  }

  /// Stress profile: ~300 generated participants.
  ///
  /// Used for:
  /// - Performance tests
  /// - Breakdown/adversarial tests
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
/// All seeders use the unified [TestParticipant] format.
Future<void> seedDatabase(
    AppDatabase database, SimulationProfile profile) async {
  switch (profile.volume) {
    case DataVolume.standard:
      await JurskyParkSeeder.seed(database);
      break;

    case DataVolume.medium:
      await GeneratedSeeder.seedMedium(database);
      break;

    case DataVolume.large:
      await GeneratedSeeder.seedLarge(database);
      break;

    case DataVolume.xlarge:
      await GeneratedSeeder.seedXLarge(database);
      break;

    case DataVolume.stress:
      await GeneratedSeeder.seedStress(database);
      break;
  }
}
