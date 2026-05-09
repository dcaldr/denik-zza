import 'package:denik_zza/database/database_wrapper.dart';
import 'package:denik_zza/design_system/zza_app_config.dart';
import 'package:flutter/material.dart';

/// A standardized wrapper for widget tests in the Zza app.
///
/// This widget:
/// 1. Wraps your [child] in a [MaterialApp] and [Scaffold].
/// 2. Configures Czech localization defaults via [ZzaAppConfig].
///
/// Database test mode is handled globally by `flutter_test_config.dart`
/// (via `ModeCoordinator.setTestingMode()`). No per-widget setup needed.
///
/// Usage:
/// ```dart
/// testWidgets('My Widget Test', (tester) async {
///   await tester.pumpWidget(
///     BaseTestWidget(
///       child: MyWidget(),
///     ),
///   );
/// });
/// ```
class BaseTestWidget extends StatelessWidget {
  final Widget child;

  /// Set to true if testing a Drawer widget (puts child in drawer slot)
  final bool isDrawer;

  const BaseTestWidget({
    super.key,
    required this.child,
    this.isDrawer = false,
  });

  @override
  Widget build(BuildContext context) {
    // Ensure localization data is ready using shared config
    ZzaAppConfig.initialize();

    return MaterialApp(
      title: ZzaAppConfig.appTitle,
      theme: ZzaAppConfig.theme,
      locale: ZzaAppConfig.supportedLocales.first,
      supportedLocales: ZzaAppConfig.supportedLocales,
      localizationsDelegates: ZzaAppConfig.delegates,
      home: Scaffold(
        body: isDrawer ? null : child,
        drawer: isDrawer ? child : null,
      ),
    );
  }
}

/// Helper to explicitly initialize the test environment.
/// Call this in your `setUp()` method if you need DB access *before* pumping widgets.
void setupTestEnvironment() {
  DatabaseWrapper.setTestMode();
}
