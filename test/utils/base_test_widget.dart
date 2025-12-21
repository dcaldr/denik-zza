import 'package:denik_zza/database/database_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

/// A standardized wrapper for widget tests in the Zza app.
///
/// This widget:
/// 1. Wraps your [child] in a [MaterialApp] and [Scaffold].
/// 2. Ensures the database is in test mode.
/// 3. Configures Czech localization defaults.
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
    // Ensure test mode is active whenever this widget is built.
    // This acts as a "Zero-Config" safety net.
    DatabaseWrapper.setTestMode();

    // Ensure date formatting is initialized (idempotent)
    initializeDateFormatting('cs_CZ', null);

    return MaterialApp(
      locale: const Locale('cs', 'CZ'),
      supportedLocales: const [Locale('cs', 'CZ')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
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
