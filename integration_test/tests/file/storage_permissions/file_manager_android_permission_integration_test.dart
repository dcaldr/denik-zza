import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:denik_zza/input/file_manager.dart';
import 'package:denik_zza/utils/file_exceptions.dart';
import 'package:denik_zza/utils/mode_coordinator.dart';
import 'package:denik_zza/utils/app_logger.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Policy: keep negative permission assertion Android-only for stability.
  // Other platforms have different protected paths and privilege models, which
  // makes a single cross-platform "permission denied" assertion flaky.

  group('FileManager storage permission integration', () {
    setUp(() async {
      await ModeCoordinator.setIntegrationTestMode(
        testName: 'file_manager_android_permission',
      );
    });

    tearDown(() async {
      await ModeCoordinator.setProductionMode();
    });

    testWidgets('preflightWrite succeeds for writable temporary directory',
        (tester) async {
      final tempDir = await Directory.systemTemp.createTemp('fm_it_ok_');
      try {
        await FileManager().preflightWrite(tempDir);
        expect(await tempDir.exists(), isTrue);
      } finally {
        try {
          await tempDir.delete(recursive: true);
        } catch (_) {}
      }
    });

    testWidgets('Android-only: preflightWrite reports permission failure on restricted path',
        (tester) async {
      // /proc is OS-managed and read-only for regular app writes on Android.
      // Writing a probe file there should fail with a permission-style exception.
      if (!Platform.isAndroid) {
        AppLogger.l.i(
          '[file_manager_android_permission] Skipping Android-only negative permission assertion.',
        );
        return;
      }

      final restrictedDir = Directory('/proc');
      expect(await restrictedDir.exists(), isTrue,
          reason: 'Expected /proc to exist on Android device.');

      expect(
        () async => await FileManager().preflightWrite(restrictedDir),
        throwsA(anyOf(isA<PermissionDeniedException>(), isA<FileOperationException>())),
      );
    });
  });
}
