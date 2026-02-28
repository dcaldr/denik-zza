import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

/// Guard test that scans test files for known anti-patterns.
///
/// These patterns have been proven to cause teardown hangs, double-close bugs,
/// and other systematic test infrastructure issues. This test prevents
/// regressions by scanning all test files for violations.
///
/// WHY: In Feb 2026, leaked StreamSubscriptions from undisposed controllers
/// caused systematic teardown hangs across the test suite. Redundant
/// setup/teardown calls caused double-close risks and DRY violations.
///
/// RULES:
/// - `controller.init()` MUST have corresponding `controller.dispose()` in tearDown
/// - `DatabaseWrapper.setTestMode()` is handled by flutter_test_config.dart globally
/// - `await database.close()` is handled by global DatabaseWrapper.dispose()
/// - `await DatabaseWrapper.dispose()` is handled by flutter_test_config.dart globally
///
/// EXCEPTIONS: database_safety_proof_test.dart and database_mode_safety_test.dart
/// TEST the mode system itself, so their calls are intentional.
void main() {
  /// Files that are ALLOWED to use these patterns (they test the mode system)
  /// Also excludes THIS file since it contains the pattern strings in its messages.
  final allowedFiles = {
    'database_safety_proof_test.dart',
    'database_mode_safety_test.dart',
    'test_infrastructure_guard_test.dart',
  };

  late List<File> testFiles;

  setUpAll(() {
    final testDir = Directory(p.join(Directory.current.path, 'test'));
    testFiles = testDir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('_test.dart'))
        .where((f) => !allowedFiles.contains(p.basename(f.path)))
        .toList();
  });

  group('Test Infrastructure Guard', () {
    test('controller.init() must have corresponding dispose()', () {
      final violations = <String>[];

      for (final file in testFiles) {
        final content = file.readAsStringSync();
        final basename = p.basename(file.path);

        // Check for .init() calls (controller, notifier, etc.)
        final hasInit = RegExp(r'\.\binit\b\s*\(\s*\)').hasMatch(content);
        if (!hasInit) continue;

        // Check for corresponding .dispose() in tearDown
        final hasDisposeInTearDown =
            RegExp(r'tearDown\b.*?\.dispose\(\)', dotAll: true)
                .hasMatch(content);

        // Also accept addTearDown(() => ...dispose())
        final hasAddTearDown =
            RegExp(r'addTearDown\b.*?\.dispose\(\)', dotAll: true)
                .hasMatch(content);

        if (!hasDisposeInTearDown && !hasAddTearDown) {
          violations.add(
            '$basename: calls .init() but has no .dispose() in tearDown/addTearDown',
          );
        }
      }

      expect(violations, isEmpty,
          reason:
              'Every .init() call must have a matching .dispose() in tearDown '
              'to prevent leaked StreamSubscriptions that block teardown.\n'
              'Violations:\n${violations.join('\n')}');
    });

    test('no redundant DatabaseWrapper.setTestMode() calls', () {
      final violations = <String>[];

      for (final file in testFiles) {
        final content = file.readAsStringSync();
        final basename = p.basename(file.path);

        if (content.contains('DatabaseWrapper.setTestMode()')) {
          violations.add(
            '$basename: has redundant DatabaseWrapper.setTestMode() — '
            'flutter_test_config.dart handles this globally via ModeCoordinator',
          );
        }
      }

      expect(violations, isEmpty,
          reason: 'DatabaseWrapper.setTestMode() is called globally by '
              'flutter_test_config.dart. Per-file calls are redundant.\n'
              'Violations:\n${violations.join('\n')}');
    });

    test('no per-test database.close() calls (global tearDown handles it)', () {
      final violations = <String>[];

      for (final file in testFiles) {
        final content = file.readAsStringSync();
        final basename = p.basename(file.path);

        // Match "await database.close();" in tearDown blocks
        // But NOT in test bodies (some tests test close behavior)
        final hasTearDownClose =
            RegExp(r'tearDown\b[^}]*?await\s+database\.close\(\)', dotAll: true)
                .hasMatch(content);

        if (hasTearDownClose) {
          violations.add(
            '$basename: has database.close() in tearDown — '
            'DatabaseWrapper.dispose() in flutter_test_config handles this',
          );
        }
      }

      expect(violations, isEmpty,
          reason: 'Per-test database.close() double-closes the DB. '
              'Global tearDown handles DB cleanup via DatabaseWrapper.dispose().\n'
              'Violations:\n${violations.join('\n')}');
    });

    test('no per-test DatabaseWrapper.dispose() calls (global tearDown handles it)',
        () {
      final violations = <String>[];

      for (final file in testFiles) {
        final content = file.readAsStringSync();
        final basename = p.basename(file.path);

        // Match "await DatabaseWrapper.dispose();" in tearDown blocks
        final hasTearDownDispose = RegExp(
                r'tearDown\b[^}]*?await\s+DatabaseWrapper\.dispose\(\)',
                dotAll: true)
            .hasMatch(content);

        if (hasTearDownDispose) {
          violations.add(
            '$basename: has DatabaseWrapper.dispose() in tearDown — '
            'flutter_test_config.dart handles this globally',
          );
        }
      }

      expect(violations, isEmpty,
          reason: 'Per-test DatabaseWrapper.dispose() is redundant. '
              'Global tearDown in flutter_test_config.dart handles it.\n'
              'Violations:\n${violations.join('\n')}');
    });
  });
}
