import 'package:denik_zza/design_system/zza_app_config.dart';
import 'package:flutter/material.dart';
import 'dev_banner.dart';
import 'dev_theme.dart';

/// Unified MaterialApp builder for all dev entry points
///
/// Uses [ZzaAppConfig] for locale and delegates to prevent config drift.
/// Dev-specific differences: orange theme, debug banner.
///
/// **Two variants available:**
/// 1. `buildDevApp()` - Simple, no visible dev banner (for quick prototyping)
/// 2. `buildDevAppWithBanner()` - Includes orange banner at top (recommended)
///
/// **Usage (simple):**
/// ```dart
/// runApp(buildDevApp(
///   title: 'CSV Import Flow',
///   home: CsvImportScreen(),
/// ));
/// ```
///
/// **Usage (with banner - recommended):**
/// ```dart
/// runApp(buildDevAppWithBanner(
///   title: 'Menu Testing',
///   bannerMessage: 'Menu Testing (In-Memory DB)',
///   bannerIcon: Icons.menu,
///   home: EventList(),
/// ));
/// ```

/// Simple MaterialApp builder without visible dev banner
///
/// Good for quick prototyping where the orange AppBar is enough indication.
/// For most cases, prefer `buildDevAppWithBanner()` for better visibility.
MaterialApp buildDevApp({
  required String title,
  required Widget home,
}) {
  return MaterialApp(
    title: title,
    debugShowCheckedModeBanner: true,
    locale: ZzaAppConfig.supportedLocales.first,
    supportedLocales: ZzaAppConfig.supportedLocales,
    localizationsDelegates: ZzaAppConfig.delegates,
    theme: DevTheme.theme,
    home: home,
  );
}

/// MaterialApp builder with visible dev mode banner (recommended)
///
/// This is the recommended approach as it makes dev mode immediately obvious
/// with a persistent orange banner at the top of the screen.
///
/// The banner displays "DEV MODE - {bannerMessage}" with an optional icon.
MaterialApp buildDevAppWithBanner({
  required String title,
  required Widget home,
  required String bannerMessage,
  IconData? bannerIcon,
}) {
  return MaterialApp(
    title: title,
    debugShowCheckedModeBanner: true,
    locale: ZzaAppConfig.supportedLocales.first,
    supportedLocales: ZzaAppConfig.supportedLocales,
    localizationsDelegates: ZzaAppConfig.delegates,
    theme: DevTheme.theme,
    home: DevBannerWrapper(
      message: bannerMessage,
      icon: bannerIcon,
      child: home,
    ),
  );
}
