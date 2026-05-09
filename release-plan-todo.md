# Release Plan TODO - Master Checklist

## Release Goal
Ship a safe pre-1.0 release for:
- Windows 10 as primary desktop target
- Android tablets as primary mobile target
- Linux as secondary target
- iOS/macOS as tertiary targets
- Web excluded for this release

---

## PRE-RELEASE DECISIONS

### Your Decisions (Confirmed)
- [ ] **Android Package Name:** `com.github.denik_zza` ✓ CONFIRMED
- [ ] **Internet Permission:** NOT needed (no backend/cloud) ✓ CONFIRMED
- [ ] **Release Version:** Pick one:
  - [ ] `0.99.0+1` (pre-release)
  - [ ] `1.0.0+1` (full release)
- [ ] **Android Distribution:** Pick one:
  - [ ] APK (single file, easier to test)
  - [ ] AAB (App Bundle, Play Store preferred)
  - [ ] Both (test with APK, submit AAB)
- [ ] **Windows Distribution:** Pick one:
  - [ ] MSIX (Windows Store, auto-updates)
  - [ ] Installer (.msi)
  - [ ] ZIP (portable, no install)
  - [ ] Just executable

### Platform Identifiers (Bundle IDs & App IDs)
These must match the reverse-domain format and cannot change after store release.

| Platform | Current | Suggested | Your Choice |
|----------|---------|-----------|-------------|
| Android | `com.example.denik_zza` | `com.github.denik_zza` | ✓ com.github.denik_zza |
| iOS | `com.example.denikZza` | `com.github.denik_zza` | _______________ |
| macOS | `com.example.denikZza` | `com.github.denik_zza` | _______________ |
| Windows | (no formal ID) | "Deník ZZA" | _______________ |
| Linux | `com.example.denik_zza` | `com.github.denik_zza` | _______________ |

### Apple Developer Setup (if shipping iOS/macOS)
- [ ] Have Apple Developer account? YES / NO
- [ ] Team ID: _______________ (from https://developer.apple.com/account)
- [ ] Will you ship iOS to App Store, or just verify it builds? (App Store / Verify Only)
- [ ] Will you ship macOS to App Store, direct download, or just verify? (App Store / Direct / Verify Only)

### Version Policy (Critical for future releases)
Once set, this applies to ALL platforms and future releases.

- [ ] Release version: `0.99.0+1` or `1.0.0+1`? _______________
- [ ] Future version bumping rule (document this):
  - When you fix a bug, what changes? (e.g., `0.99.1+1`?)
  - When you add a feature, what changes? (e.g., `0.100.0+0`?)
  - When you do a major release, what changes? (e.g., `1.0.0+0`?)
  - Document: _______________

---

## RELEASE STEPS

### Step 1: Set Release Version in One Place
**File:** `pubspec.yaml`

- [ ] Set `version: X.Y.Z+B` (your release version decision above)
- [ ] Save and run `flutter pub get`
- [ ] All platforms (Android, iOS, macOS, Windows, Linux) inherit automatically

**Verify:**
```bash
grep "^version:" pubspec.yaml
# Should show exactly one line with your version
```

---

### Step 2: Android Release Setup
**Files:** `android/app/build.gradle` or `build.gradle.kts`, `android/app/src/main/AndroidManifest.xml`

- [ ] Replace `com.example.denik_zza` with `com.github.denik_zza`
- [ ] Add/update release signing configuration (keystore setup):
  - Create keystore: `keytool -genkey -v -keystore ~/denik_zza.keystore -alias denik_zza -keyalg RSA -keysize 2048 -validity 10000`
  - Store keystore file outside repo (e.g., `~/denik_zza.keystore`)
  - Add to gradle:
    ```gradle
    signingConfigs {
      release {
        storeFile = file("path/to/denik_zza.keystore")
        storePassword = "your-keystore-password"
        keyAlias = "denik_zza"
        keyPassword = "your-key-password"
      }
    }
    buildTypes {
      release {
        signingConfig signingConfigs.release
      }
    }
    ```
- [ ] Remove INTERNET permission (not needed)
- [ ] Keep only these Android permissions:
  ```xml
  <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
  <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
  ```

**Verify:**
```bash
grep -r "com.example" . --include="*.gradle" --include="*.xml" 2>/dev/null
# Should return ZERO results
grep -c "uses-permission" android/app/src/main/AndroidManifest.xml
# Should show 2 (only storage, no internet)
```

---

### Step 3: Add Drift Migration Path
**Files:** `lib/database/drift_database/database.dart`, create `lib/database/migrations/migration_logic.dart`

- [ ] Add `onUpgrade()` callback to handle future schema migrations:
  ```dart
  @override
  Future<void> onUpgrade(Migrator m, int from, int to) async {
    if (from < 2) {
      // Future migration: if (from < 2) await _migrateV1ToV2(m);
    }
  }
  ```
- [ ] Create migration module with stub for future use
- [ ] Ensure cache table is bootstrapped on first launch (if empty, insert default row)
- [ ] Pin Drift dependency: `drift: ^2.19.1` (exact, not `^2.19.1+1`)

**Verify:**
```bash
grep -q "onUpgrade" lib/database/drift_database/database.dart && echo "✓ onUpgrade found"
grep -q "sqlite3: any" pubspec.yaml && echo "⚠ sqlite3 is unpinned, consider pinning"
```

---

### Step 4: Guard lib/dev from Release
**Files:** `analysis_options.yaml`, `pubspec.yaml`

- [ ] Add to `analysis_options.yaml`:
  ```yaml
  exclude:
    - lib/dev/**
  ```
- [ ] Add comment in `pubspec.yaml` near flutter section:
  ```yaml
  flutter:
    # lib/dev is dev-only, not shipped in release builds
  ```
- [ ] Create safety check script `scripts/check-lib-dev-safety.sh`:
  ```bash
  #!/bin/bash
  if grep -q "from 'package:denik_zza/dev/" lib/main.dart; then
    echo "✗ ERROR: lib/dev is imported in main.dart"
    exit 1
  fi
  echo "✓ lib/dev is isolated"
  ```

**Verify:**
```bash
bash scripts/check-lib-dev-safety.sh
```

---

### Step 5: Fix Critical Safety Issues
**Files:** `lib/input/file_manager.dart`, `lib/screens2/**`, `lib/database/drift_database_connector.dart`

- [ ] **File operations:**
  - Add error handling to file copy, temp file cleanup, backup
  - Make backup failures visible instead of silent
  - Validate files exist after upload
  - Add logging for all file operations

- [ ] **Async UI:**
  - Add `mounted` checks after every await in screens
  - Add try/catch in IntakeForm.saveData(), NewRecordPage event handlers, CSV import flow
  - Show user-friendly Czech error messages on failure

- [ ] **Database:**
  - Validate `Future.wait()` results before casting
  - Handle null/invalid results safely
  - Ensure first-run cache access doesn't crash
  - Add clear error logs

**Verify:**
```bash
flutter analyze
flutter test
# Should pass with 0 errors
```

---

### Step 6: Windows Configuration
**Files:** `windows/runner/Runner.rc`, `pubspec.yaml`

- [ ] Set version format: `X.Y.Z.0` (Windows requires 4 parts, last is 0 for Store compatibility)
- [ ] Update product metadata in Runner.rc (if not auto-inherited):
  - PRODUCT_NAME: "Deník ZZA"
  - COMPANY_NAME: "Your Organization"
  - VERSION: matches pubspec.yaml

**Verify:**
```bash
flutter build windows --release
# Should complete without errors
```

---

### Step 7: Build and Test Windows Release
- [ ] `flutter build windows --release`
- [ ] Run the resulting executable on Windows 10
- [ ] Test CSV import (create small test file)
- [ ] Test event creation and printing
- [ ] Check version in app or About dialog

**Sign-off:**
- [ ] Windows release executable runs
- [ ] CSV import works
- [ ] Printing works
- [ ] No crashes

---

### Step 8: Build and Test Android Release
- [ ] `flutter build apk --release` or `flutter build appbundle --release` (your decision)
- [ ] Install on a real Android tablet
- [ ] Test storage permission prompt (should appear on first file access)
- [ ] Test CSV import
- [ ] Test event creation and printing
- [ ] Check version in app or About dialog

**Sign-off:**
- [ ] Android release build is signed correctly
- [ ] Permissions work (no silent failures)
- [ ] CSV import works
- [ ] Printing works
- [ ] No crashes

---

### Step 9: iOS Configuration (if shipping)
**Files:** `ios/Runner/Info.plist`, Xcode project settings

- [ ] Set bundle ID to `com.github.denik_zza` in Xcode project
- [ ] Add Development Team ID in Xcode build settings
- [ ] Add privacy descriptions to Info.plist:
  ```xml
  <key>NSFileProviderPresenceUsageDescription</key>
  <string>Umožňuje přístup k souborům v zařízení pro import zdravotnických údajů.</string>
  ```
- [ ] Verify provisioning profile is set up

---

### Step 10: macOS Configuration (if shipping)
**Files:** `macos/Runner/Configs/AppInfo.xcconfig`, `macos/Runner/Release.entitlements`, Xcode project

- [ ] Set bundle ID to `com.github.denik_zza` in AppInfo.xcconfig
- [ ] Set Development Team ID in Xcode build settings
- [ ] Update Release.entitlements to include:
  ```xml
  <key>com.apple.security.files.user-selected.read-write</key>
  <true/>
  <key>com.apple.security.print</key>
  <true/>
  ```
- [ ] Add privacy descriptions to Info.plist

---

### Step 11: Linux Configuration (if shipping)
**Files:** `linux/CMakeLists.txt`

- [ ] Update APPLICATION_ID from `com.example.denik_zza` to `com.github.denik_zza`
- [ ] Create `.desktop` file with app metadata
- [ ] Ensure app icon is in place

---

### Step 12: Fix Issues Found in Testing
- [ ] Address any crashes or errors from Steps 7-11
- [ ] Run tests again: `flutter analyze && flutter test`
- [ ] Rebuild target platforms and verify fixes

---

### Step 13: Write Release Documentation
**Do this AFTER everything works.**

Create these files:

- [ ] `docs/VERSIONING.md` — How version numbers are set and increased
- [ ] `docs/BUILD.md` — Short build instructions per platform
- [ ] `docs/RELEASE_CHECKLIST.md` — Go/no-go checklist
- [ ] Update root `README.md` — Replace Flutter boilerplate with actual project info

---

### Step 14: Final Go/No-Go Checks
Before shipping, verify ALL of these:

- [ ] Version is identical in pubspec.yaml and all platform manifests
- [ ] Android package name is `com.github.denik_zza` (no com.example)
- [ ] Android release build is signed with production keystore
- [ ] Drift migrations are in place
- [ ] File operations have error handling
- [ ] Async screens have try/catch and mounted checks
- [ ] Windows release runs on Windows 10
- [ ] Android release runs on a real tablet
- [ ] lib/dev is isolated (not imported in main.dart)
- [ ] `flutter analyze` passes with 0 errors
- [ ] `flutter test` passes
- [ ] Release docs are written
- [ ] Web is documented as excluded

---

## AUTOMATIC SAFETY CHECKS

Create file `scripts/pre-release-check.sh`:

```bash
#!/bin/bash
set -e

echo "Running pre-release safety checks..."

# 1. Check version consistency
PUBSPEC_VERSION=$(grep "^version:" pubspec.yaml | cut -d' ' -f2)
echo "✓ pubspec.yaml version: $PUBSPEC_VERSION"

# 2. Check for leftover com.example
if grep -r "com.example" . --include="*.gradle" --include="*.xml" --include="*.kt" 2>/dev/null; then
  echo "✗ FAIL: Found com.example references"
  exit 1
fi
echo "✓ No com.example found"

# 3. Check for lib/dev leaking
if grep "from 'package:denik_zza/dev/" lib/main.dart 2>/dev/null; then
  echo "✗ FAIL: lib/dev imported in main.dart"
  exit 1
fi
echo "✓ lib/dev isolated"

# 4. Check Drift migrations
if ! grep -q "onUpgrade" lib/database/drift_database/database.dart 2>/dev/null; then
  echo "⚠ WARNING: onUpgrade not found in database.dart"
fi

# 5. Check for debug prints in production
PRINT_COUNT=$(grep -r "print(" lib/ --exclude-dir=dev --exclude-dir=test 2>/dev/null | grep -v "AppLogger" | wc -l)
if [ "$PRINT_COUNT" -gt 0 ]; then
  echo "⚠ WARNING: Found $PRINT_COUNT print() calls"
fi

echo "✓ All checks passed"
```

Run before every release:
```bash
bash scripts/pre-release-check.sh
```

---

## GIT COMMITS & TAGGING

After each major step, commit:

```bash
git commit -m "feat: set release version to 0.99.0"
git commit -m "feat: configure Android release signing"
git commit -m "feat: add Drift migration framework"
git commit -m "chore: isolate lib/dev from production"
git commit -m "fix: add error handling to file and async operations"
git commit -m "docs: add release documentation"
```

Then tag the release:
```bash
git tag -a v0.99.0 -m "Pre-release 0.99.0 - Windows/Android primary"
git push origin v0.99.0
```

---

## CLEANUP (Deferred)

Do this only after release is shipped and working, if needed:

- [ ] Remove old `lib/screens/` if not used
- [ ] Remove dead commented code
- [ ] Move stale test data out of lib/
- [ ] Remove deprecated API calls

---

## SUMMARY

**Your confirmed setup:**
- Android: `com.github.denik_zza`, no internet permission
- Version: from pubspec.yaml
- Windows: inherit version, set metadata
- iOS/macOS: decide before shipping
- Linux: nice-to-have
- Web: excluded

**Next action:** Fill in the remaining decisions in the "PRE-RELEASE DECISIONS" section above, then follow steps 1-14 in order.
