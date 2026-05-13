# Storage Permission Integration Test

This folder contains integration coverage for `FileManager` storage permission behavior.

## Scope

- Positive path: `preflightWrite` succeeds in a writable temp directory.
- Negative path (Android-only): `preflightWrite` fails on `/proc` and throws a permission-style exception.

The negative check is intentionally Android-only to keep the test deterministic.
Other platforms have different protected paths and privilege models.

## Run on Android

```bash
flutter test integration_test/tests/file/storage_permissions/file_manager_android_permission_integration_test.dart -d android
```

## Optional Permission State Checks

Replace `<package.id>` with your app package (for example `com.example.denik_zza`).

```bash
adb shell pm revoke <package.id> android.permission.READ_EXTERNAL_STORAGE
adb shell pm revoke <package.id> android.permission.WRITE_EXTERNAL_STORAGE
adb shell pm grant <package.id> android.permission.READ_EXTERNAL_STORAGE
adb shell pm grant <package.id> android.permission.WRITE_EXTERNAL_STORAGE
```

Notes:

- On newer Android versions, storage behavior depends on scoped storage and media permissions.
- This test does not request runtime permissions; it validates observed write behavior in OS-restricted paths.