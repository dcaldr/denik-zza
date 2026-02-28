import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// Guard test: Ensures all entry points use [ZzaAppConfig] for locale/delegates.
///
/// If this test fails, someone re-introduced hardcoded locale or delegate
/// definitions instead of referencing ZzaAppConfig. Fix by using:
///   - `ZzaAppConfig.supportedLocales`
///   - `ZzaAppConfig.delegates`
///   - `ZzaAppConfig.initialize()`
void main() {
  group('Config consistency enforcement', () {
    test('dev_app_builder uses ZzaAppConfig, not hardcoded locale/delegates',
        () {
      final file = File('lib/dev/ui/dev_app_builder.dart');
      expect(file.existsSync(), isTrue,
          reason: 'dev_app_builder.dart must exist');

      final content = file.readAsStringSync();

      // Must NOT contain hardcoded locale constructor
      expect(
        content.contains("Locale('cs'"),
        isFalse,
        reason:
            'dev_app_builder.dart must use ZzaAppConfig.supportedLocales instead of hardcoding Locale',
      );

      // Must NOT contain hardcoded delegate lists
      expect(
        content.contains('GlobalMaterialLocalizations'),
        isFalse,
        reason:
            'dev_app_builder.dart must use ZzaAppConfig.delegates instead of hardcoding delegates',
      );

      // MUST reference ZzaAppConfig
      expect(
        content.contains('ZzaAppConfig'),
        isTrue,
        reason:
            'dev_app_builder.dart must import and use ZzaAppConfig for locale/delegates',
      );
    });

    test('test_harness uses ZzaAppConfig.initialize(), not manual locale setup',
        () {
      final file = File(
          'integration_test/infrastructure/utils/test_harness.dart');
      expect(file.existsSync(), isTrue,
          reason: 'test_harness.dart must exist');

      final content = file.readAsStringSync();

      // Must NOT contain manual Intl.defaultLocale assignment
      expect(
        content.contains('Intl.defaultLocale'),
        isFalse,
        reason:
            'test_harness.dart must use ZzaAppConfig.initialize() instead of manually setting Intl.defaultLocale',
      );

      // Must NOT contain manual initializeDateFormatting
      expect(
        content.contains('initializeDateFormatting'),
        isFalse,
        reason:
            'test_harness.dart must use ZzaAppConfig.initialize() instead of calling initializeDateFormatting directly',
      );

      // MUST reference ZzaAppConfig
      expect(
        content.contains('ZzaAppConfig'),
        isTrue,
        reason:
            'test_harness.dart must import and use ZzaAppConfig for initialization',
      );
    });
  });
}
