import 'package:flutter_test/flutter_test.dart';
import 'package:denik_zza/database/database_wrapper.dart';

/// Simple proof-of-concept test to verify the robust database mode system works.
/// This test verifies the core safety features without relying on complex interfaces.
void main() {
  group('Database Mode Safety Tests', () {
    /// Clean up state before each test
    setUp(() async {
      await DatabaseWrapper.dispose();
    });

    /// Ensure clean state after tests
    tearDown(() async {
      await DatabaseWrapper.dispose();
    });

    test('Default mode is production', () {
      expect(DatabaseWrapper.getCurrentMode(), DatabaseMode.production);
    });

    test('Test mode can be set and retrieved', () {
      DatabaseWrapper.setTestMode();
      expect(DatabaseWrapper.getCurrentMode(), DatabaseMode.testing);
    });

    test('Production mode can be restored', () async {
      DatabaseWrapper.setTestMode();
      expect(DatabaseWrapper.getCurrentMode(), DatabaseMode.testing);

      await DatabaseWrapper.dispose();
      expect(DatabaseWrapper.getCurrentMode(), DatabaseMode.production);
    });

    test('isUsingPersistentStorage works correctly', () async {
      // Production mode should use persistent storage
      await DatabaseWrapper.dispose();
      expect(DatabaseWrapper.isUsingPersistentStorage(), isTrue);

      // Test mode should not use persistent storage
      DatabaseWrapper.setTestMode();
      expect(DatabaseWrapper.isUsingPersistentStorage(), isFalse);
    });

    test('ensureProductionMode sets production mode', () {
      DatabaseWrapper.setTestMode();
      expect(DatabaseWrapper.getCurrentMode(), DatabaseMode.testing);

      DatabaseWrapper.ensureProductionMode();
      expect(DatabaseWrapper.getCurrentMode(), DatabaseMode.production);
    });

    test('validateProductionSafety works in safe configurations', () async {
      await DatabaseWrapper.dispose();
      expect(() => DatabaseWrapper.validateProductionSafety(), returnsNormally);
    });

    test('Multiple mode switches work correctly', () async {
      for (int i = 0; i < 3; i++) {
        DatabaseWrapper.setTestMode();
        expect(DatabaseWrapper.getCurrentMode(), DatabaseMode.testing);
        expect(DatabaseWrapper.isUsingPersistentStorage(), isFalse);

        await DatabaseWrapper.dispose();
        expect(DatabaseWrapper.getCurrentMode(), DatabaseMode.production);
        expect(DatabaseWrapper.isUsingPersistentStorage(), isTrue);
      }
    });

    test('Production mode is the safe default', () async {
      // After any operations, verify we're in production mode
      DatabaseWrapper.setTestMode();
      await DatabaseWrapper.dispose();

      expect(DatabaseWrapper.getCurrentMode(), DatabaseMode.production);
      expect(DatabaseWrapper.isUsingPersistentStorage(), isTrue);
    });
  });
}
