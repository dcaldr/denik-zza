# Dev UI Components

Unified UI components for all development entry points to ensure consistent dev mode indicators.

## Components

### `dev_app_builder.dart`
Main entry point for creating dev MaterialApps with consistent setup.

**Two variants:**
1. **`buildDevApp()`** - Simple, no visible banner
   - Use for quick prototyping
   - Orange AppBar is the only indicator
   
2. **`buildDevAppWithBanner()`** - With visible banner (recommended)
   - Persistent orange banner at top
   - Clear "DEV MODE" message
   - Optional icon

### `dev_banner.dart`
Reusable banner widgets.

- **`DevBanner`** - Standalone orange banner widget
- **`DevBannerWrapper`** - Wraps any screen with a banner

### `dev_theme.dart`
Theme configurations for dev mode.

- **`DevTheme.theme`** - Standard orange AppBar theme
- **`DevTheme.deepOrangeTheme`** - Alternative deepOrange color scheme

## Usage Examples

### Simple Dev App (no banner)
```dart
import 'package:denik_zza/dev/dev_environment.dart';
import 'package:denik_zza/dev/ui/dev_app_builder.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DevEnvironment.initialize();
  
  runApp(buildDevApp(
    title: 'My Feature Dev',
    home: MyFeatureScreen(),
  ));
}
```

### Dev App with Banner (recommended)
```dart
import 'package:denik_zza/dev/dev_environment.dart';
import 'package:denik_zza/dev/ui/dev_app_builder.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DevEnvironment.initialize();
  
  runApp(buildDevAppWithBanner(
    title: 'My Feature Dev',
    bannerMessage: 'Testing Feature X (In-Memory DB)',
    bannerIcon: Icons.science,
    home: MyFeatureScreen(),
  ));
}
```

### Using DeepOrange Theme (for CSV screens)
```dart
runApp(buildDevAppWithBanner(
  title: 'CSV Import',
  bannerMessage: 'CSV Import Flow',
  bannerIcon: Icons.upload_file,
  home: CsvImportScreen(),
  useDeepOrangeTheme: true,  // ← CSV screens use this
));
```

## Visual Indicators

All dev apps get these indicators:
1. **Orange AppBar** - All AppBars are orange instead of blue
2. **Debug Banner** - Diagonal banner (top right)
3. **Orange Top Banner** - "DEV MODE - {message}" (if using `buildDevAppWithBanner`)
4. **Czech Localization** - Automatically included

## Benefits

✅ Consistent dev mode appearance across all entry points
✅ No need to copy-paste MaterialApp setup
✅ Easier to identify dev vs production
✅ Centralized maintenance
✅ Czech localization always included
✅ Optional custom banners with icons

## Migration from Old Pattern

**Before:**
```dart
// Old: Manual MaterialApp setup
runApp(MaterialApp(
  title: 'Dev',
  theme: ThemeData(
    appBarTheme: AppBarTheme(backgroundColor: Colors.orange),
  ),
  // ... more boilerplate
));
```

**After:**
```dart
// New: One-liner with banner
runApp(buildDevAppWithBanner(
  title: 'Dev',
  bannerMessage: 'Testing',
  home: MyScreen(),
));
```
