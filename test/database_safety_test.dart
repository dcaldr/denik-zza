import 'package:flutter_test/flutter_test.dart';
import '../lib/database/database_wrapper.dart';

/// Test database safety mechanisms
void main() {
  group('Database Safety Tests', () {
    setUp(() {
      // Reset to production mode before each test
      DatabaseWrapper.resetToProduction();
    });

    test('defaults to production mode', () {
      expect(DatabaseWrapper.getCurrentMode(), equals(DatabaseMode.production));
      expect(DatabaseWrapper.isUsingPersistentStorage(), isTrue);
    });

    test('can switch to test mode', () {
      DatabaseWrapper.setTestMode();
      expect(DatabaseWrapper.getCurrentMode(), equals(DatabaseMode.testing));
    });

    test('can reset to production mode', () {
      DatabaseWrapper.setTestMode();
      expect(DatabaseWrapper.getCurrentMode(), equals(DatabaseMode.testing));
      
      DatabaseWrapper.resetToProduction();
      expect(DatabaseWrapper.getCurrentMode(), equals(DatabaseMode.production));
    });

    test('ensureProductionMode forces production mode', () {
      DatabaseWrapper.setTestMode();
      expect(DatabaseWrapper.getCurrentMode(), equals(DatabaseMode.testing));
      
      DatabaseWrapper.ensureProductionMode();
      expect(DatabaseWrapper.getCurrentMode(), equals(DatabaseMode.production));
    });

    test('production mode uses persistent storage', () {
      DatabaseWrapper.resetToProduction();
      expect(DatabaseWrapper.isUsingPersistentStorage(), isTrue);
    });
  });
}
