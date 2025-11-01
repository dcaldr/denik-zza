# Development Entry Points (`lib/dev/`)

Quick-start dev environments for rapid feature prototyping and testing.

## 🎨 NEW: Unified Dev UI Components

All dev entry points now use unified UI components from `lib/dev/ui/`:
- **Orange dev mode banner** - Persistent visual indicator
- **Consistent theme** - Orange AppBar across all dev apps
- **Auto Czech localization** - No manual setup needed

See `lib/dev/ui/README.md` for full documentation.

## 🚀 Quick Start Pattern

All dev mains use `DevEnvironment.initialize()` + `buildDevAppWithBanner()`:

```dart
import 'package:denik_zza/dev/dev_environment.dart';
import 'package:denik_zza/dev/ui/dev_app_builder.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DevEnvironment.initialize(); // ← Data setup
  
  runApp(buildDevAppWithBanner(     // ← UI setup with banner
    title: 'My Dev App',
    bannerMessage: 'Testing Feature X',
    bannerIcon: Icons.science,
    home: MyDevScreen(),
  ));
}
```

## ✅ What This Fixes

**Before:**
```
❌ Error: Null check operator used on a null value
   at getCurrentActionID()!
```

**After:**
```
✅ Dev environment ready with test event
✅ CSV import works (current event exists!)
✅ All participant operations succeed
```

## 📁 Available Dev Entry Points

### CSV Import Flow - **FIXED!** ✅
```bash
flutter run -t lib/dev/dev_csv_import_flow.dart
```
- **Now works!** Current event exists
- Full workflow: File picker → Review → Finalize → Summary
- Test with `multi_person_shuffled_order.csv`

### CSV Review Table (Bad Data)
```bash
flutter run -t lib/dev/dev_csv_review_table.dart
```
- Table view with validation errors
- Uses `dev_bad_import_fixture.csv`

### CSV Review Table (Extra Columns)
```bash
flutter run -t lib/dev/dev_csv_review_table_extra_columns.dart
```
- Tests unmapped column handling
- Uses `multi_person_with_extra_columns.csv`

## 🎁 Rich Test Data (Optional)

For full test data (10 participants + records), use:
```bash
flutter run -t test/setup_templates/dev_main.dart
```

Creates:
- ✅ "Test Test Test" event with 10 Czech participants
- ✅ Medical records with cultural easter eggs
- ✅ Insurance companies (VZP, OZKP)
- ✅ Orange dev mode banner

## 🔧 Utilities

### `dev_environment.dart` ← **NEW!**
Unified dev setup:
- `initialize()` - Minimal setup (event only)
- `initializeWithTestData()` - Event + insurance + paramedic

### `dev_csv_review_shared.dart`
Helpers:
- `buildDevApp()` - MaterialApp with Czech localization
- `resolveProjectFile()` - Test data path resolution
- ~~`configureCsvReviewDevDatabase()`~~ - **Deprecated**

## ✨ Benefits

| Before | After |
|--------|-------|
| Each dev main had own setup | ✅ Unified `DevEnvironment.initialize()` |
| CSV import crashed (no event) | ✅ Current event always exists |
| Inconsistent test data | ✅ Consistent across all dev mains |
| Complex setup code | ✅ One-liner initialization |

## 📝 Adding New Dev Entry Points

1. Create `lib/dev/dev_my_feature.dart`
2. Copy this template:

```dart
import 'package:denik_zza/dev/dev_environment.dart';
import 'package:denik_zza/dev/dev_csv_review_shared.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DevEnvironment.initialize();
  
  runApp(buildDevApp(
    title: 'My Feature Dev',
    home: MyFeatureScreen(),
  ));
}
```

3. Run: `flutter run -t lib/dev/dev_my_feature.dart`

## 🐛 Debugging

If you see errors about missing database or null values:
1. Verify you called `DevEnvironment.initialize()`
2. Check it's called **before** `runApp()`
3. Ensure you're using `await`

## 🧪 Test vs Dev Setup

| Feature | `DevEnvironment` | `HardcodedTestSetup` |
|---------|------------------|----------------------|
| Location | `lib/dev/` | `test/setup_templates/` |
| Event | ✅ 1 test event | ✅ "Test Test Test" |
| Participants | ❌ None | ✅ 10 Czech cultural refs |
| Records | ❌ None | ✅ 10 with easter eggs |
| Use case | Quick CSV testing | Full app testing |

---

**Pro Tip:** Use `DevEnvironment.initialize()` for CSV testing, `HardcodedTestSetup` for full app demos!
