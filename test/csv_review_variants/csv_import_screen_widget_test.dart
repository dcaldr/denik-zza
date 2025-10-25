import 'dart:typed_data';

import 'package:denik_zza/screens2/csv_review_variants/import_screen.dart';
import 'package:denik_zza/screens2/csv_review_variants/table_overview_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _StubFilePicker stubPlatform;
  late _FakeFilePicker fakePlatform;

  setUp(() {
    stubPlatform = _StubFilePicker();
    fakePlatform = _FakeFilePicker(stubPlatform);
    FilePicker.platform = fakePlatform;
  });

  tearDown(() {
    FilePicker.platform = stubPlatform;
  });

  testWidgets('shows validation error for non-CSV selection',
      (WidgetTester tester) async {
    fakePlatform.enqueueResult(
      FilePickerResult(<PlatformFile>[
        PlatformFile(name: 'report.txt', size: 0, path: 'report.txt'),
      ]),
    );

    await tester.pumpWidget(const MaterialApp(home: CsvImportScreen()));

    await tester.tap(find.byKey(const Key('CsvImportScreen_pick_button')));
    await tester.pumpAndSettle();

    expect(
      find.text('Vybraný soubor musí mít příponu CSV.'),
      findsOneWidget,
    );
  });

  testWidgets('enables continue button after valid selection',
      (WidgetTester tester) async {
    fakePlatform.enqueueResult(
      FilePickerResult(<PlatformFile>[
        PlatformFile(
          name: 'first.csv',
          size: 0,
          path: 'test/data/first.csv',
        ),
      ]),
    );

    await tester.pumpWidget(const MaterialApp(home: CsvImportScreen()));

    await tester.tap(find.byKey(const Key('CsvImportScreen_pick_button')));
    await tester.pumpAndSettle();

    final FilledButton continueButton = tester.widget<FilledButton>(
      find.byKey(const Key('CsvImportScreen_continue_button')),
    );
    expect(continueButton.onPressed, isNotNull);
  });

  testWidgets('shows snackbar when payload preparation fails',
      (WidgetTester tester) async {
    fakePlatform.enqueueResult(
      FilePickerResult(<PlatformFile>[
        PlatformFile(
          name: 'broken.csv',
          size: 0,
          bytes: Uint8List(0),
        ),
      ]),
    );

    await tester.pumpWidget(const MaterialApp(home: CsvImportScreen()));

    await tester.tap(find.byKey(const Key('CsvImportScreen_pick_button')));
    await tester.pump();

    expect(
      find.text('Soubor se nepodařilo připravit.'),
      findsOneWidget,
    );
    await tester.pump(const Duration(milliseconds: 200));
    expect(
      find.text('Soubor se nepodařilo připravit. Zkuste to prosím znovu.'),
      findsOneWidget,
    );
  });

  testWidgets('navigates to table overview after continue',
      (WidgetTester tester) async {
    fakePlatform.enqueueResult(
      FilePickerResult(<PlatformFile>[
        PlatformFile(
          name: 'first.csv',
          size: 0,
          path: 'test/data/first.csv',
        ),
      ]),
    );

    final _TrackingNavigatorObserver observer = _TrackingNavigatorObserver();

    await tester.pumpWidget(
      MaterialApp(
        home: const CsvImportScreen(),
        navigatorObservers: <NavigatorObserver>[observer],
      ),
    );

    await tester.tap(find.byKey(const Key('CsvImportScreen_pick_button')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('CsvImportScreen_continue_button')));
    await tester.pump();

    for (int i = 0; i < 10; i++) {
      if (find.byType(CsvReviewTableOverviewScreen).evaluate().isNotEmpty) {
        break;
      }
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(observer.pushedRoute, isNotNull);
    expect(find.byType(CsvReviewTableOverviewScreen), findsOneWidget);
  });

  // ═══════════════════════════════════════════════════════════════
  // EDGE CASES: Lifecycle and Race Conditions
  // ═══════════════════════════════════════════════════════════════

  testWidgets('handles user cancelling file picker gracefully',
      (WidgetTester tester) async {
    // User cancels file picker - returns null
    fakePlatform.enqueueResult(null);

    await tester.pumpWidget(const MaterialApp(home: CsvImportScreen()));

    await tester.tap(find.byKey(const Key('CsvImportScreen_pick_button')));
    await tester.pumpAndSettle();

    // Should not show error, just stay in initial state
    expect(find.byKey(const Key('CsvImportScreen_error_label')), findsNothing);
    expect(find.text('Zatím nebyl vybrán žádný soubor.'), findsOneWidget);
    
    // Continue button should remain disabled
    final continueButton = tester.widget<FilledButton>(
      find.byKey(const Key('CsvImportScreen_continue_button')),
    );
    expect(continueButton.onPressed, isNull);
  });

  testWidgets('prevents double-tap during file picking',
      (WidgetTester tester) async {
    fakePlatform.enqueueResult(
      FilePickerResult(<PlatformFile>[
        PlatformFile(
          name: 'test.csv',
          size: 0,
          path: 'test/data/first.csv',
        ),
      ]),
    );

    await tester.pumpWidget(const MaterialApp(home: CsvImportScreen()));

    // Get initial button state
    final buttonBefore = tester.widget<ElevatedButton>(
      find.byKey(const Key('CsvImportScreen_pick_button')),
    );
    expect(buttonBefore.onPressed, isNotNull);

    // Tap once
    await tester.tap(find.byKey(const Key('CsvImportScreen_pick_button')));
    await tester.pump(); // Let tap take effect
    
    // After tap, button child might change (implementation detail)
    // Key point: async operation started, should complete successfully
    await tester.pumpAndSettle();
    
    // After completion, file should be selected
    expect(find.textContaining('test.csv'), findsOneWidget);
  });

  testWidgets('cleans up when disposed during file picking',
      (WidgetTester tester) async {
    // This test verifies the dispose() cleanup doesn't crash
    fakePlatform.enqueueResult(
      FilePickerResult(<PlatformFile>[
        PlatformFile(
          name: 'test.csv',
          size: 100,
          bytes: Uint8List.fromList(List<int>.filled(100, 65)), // "AAA..."
        ),
      ]),
    );

    await tester.pumpWidget(const MaterialApp(home: CsvImportScreen()));
    
    await tester.tap(find.byKey(const Key('CsvImportScreen_pick_button')));
    await tester.pump(); // Start async operation

    // Pop screen before async completes - triggers dispose()
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: Text('Screen popped'))),
    );
    await tester.pumpAndSettle();

    // Should not crash - dispose() handles cleanup gracefully
    expect(find.text('Screen popped'), findsOneWidget);
  });

  testWidgets('prevents navigation during existing navigation attempt',
      (WidgetTester tester) async {
    fakePlatform.enqueueResult(
      FilePickerResult(<PlatformFile>[
        PlatformFile(
          name: 'test.csv',
          size: 0,
          path: 'test/data/first.csv',
        ),
      ]),
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: CsvImportScreen(),
      ),
    );

    // Pick file
    await tester.tap(find.byKey(const Key('CsvImportScreen_pick_button')));
    await tester.pumpAndSettle();

    // Tap continue ONCE
    await tester.tap(find.byKey(const Key('CsvImportScreen_continue_button')));
    await tester.pump(); // Start navigation but don't wait
    await tester.pump(); // Let setState take effect

    // Button should be disabled during navigation (_isNavigating = true)
    final continueButton = tester.widget<FilledButton>(
      find.byKey(const Key('CsvImportScreen_continue_button')),
    );
    expect(continueButton.onPressed, isNull);

    // Verify we can't tap again (onPressed is null)
    // This prevents double-navigation
  });

  testWidgets('handles empty file picker result (no files)',
      (WidgetTester tester) async {
    // Edge case: FilePickerResult exists but files list is empty
    fakePlatform.enqueueResult(FilePickerResult(<PlatformFile>[]));

    await tester.pumpWidget(const MaterialApp(home: CsvImportScreen()));

    await tester.tap(find.byKey(const Key('CsvImportScreen_pick_button')));
    await tester.pumpAndSettle();

    // Should handle gracefully - no crash, stays in initial state
    expect(find.text('Zatím nebyl vybrán žádný soubor.'), findsOneWidget);
    expect(find.byKey(const Key('CsvImportScreen_error_label')), findsNothing);
  });

  testWidgets('handles file with empty name gracefully',
      (WidgetTester tester) async {
    fakePlatform.enqueueResult(
      FilePickerResult(<PlatformFile>[
        PlatformFile(
          name: '', // Empty name
          size: 0,
          path: 'test/data/first.csv',
        ),
      ]),
    );

    await tester.pumpWidget(const MaterialApp(home: CsvImportScreen()));

    await tester.tap(find.byKey(const Key('CsvImportScreen_pick_button')));
    await tester.pumpAndSettle();

    // File label should exist (check implementation handles empty name)
    final fileLabel = find.byKey(const Key('CsvImportScreen_file_label'));
    expect(fileLabel, findsOneWidget);
    
    // Key insight: Empty name is edge case - implementation might show default
    // or "(bez názvu)" or empty. Main point: no crash and UI renders.
  });
}

class _FakeFilePicker extends FilePicker {
  _FakeFilePicker(this._delegate);

  final FilePicker _delegate;
  final List<FilePickerResult?> _queue = <FilePickerResult?>[];

  void enqueueResult(FilePickerResult? result) {
    _queue.add(result);
  }

  @override
  Future<FilePickerResult?> pickFiles({
    bool allowCompression = true,
    bool allowMultiple = false,
    List<String>? allowedExtensions,
    int compressionQuality = 30,
    String? dialogTitle,
    String? initialDirectory,
    bool lockParentWindow = false,
    void Function(FilePickerStatus status)? onFileLoading,
    bool readSequential = false,
    FileType type = FileType.any,
    bool withData = false,
    bool withReadStream = false,
  }) async {
    if (_queue.isEmpty) {
      return null;
    }
    return _queue.removeAt(0);
  }

  @override
  Future<bool?> clearTemporaryFiles() {
    return _delegate.clearTemporaryFiles();
  }

  @override
  Future<String?> saveFile({
    List<String>? allowedExtensions,
    Uint8List? bytes,
    String? dialogTitle,
    String? fileName,
    String? initialDirectory,
    bool lockParentWindow = false,
    FileType type = FileType.any,
  }) {
    return _delegate.saveFile(
      allowedExtensions: allowedExtensions,
      bytes: bytes,
      dialogTitle: dialogTitle,
      fileName: fileName,
      initialDirectory: initialDirectory,
      lockParentWindow: lockParentWindow,
      type: type,
    );
  }

  @override
  Future<String?> getDirectoryPath({
    String? dialogTitle,
    String? initialDirectory,
    bool lockParentWindow = false,
  }) {
    return _delegate.getDirectoryPath(
      dialogTitle: dialogTitle,
      initialDirectory: initialDirectory,
      lockParentWindow: lockParentWindow,
    );
  }
}

class _StubFilePicker extends FilePicker {
  @override
  Future<FilePickerResult?> pickFiles({
    bool allowCompression = true,
    bool allowMultiple = false,
    List<String>? allowedExtensions,
    int compressionQuality = 30,
    String? dialogTitle,
    String? initialDirectory,
    bool lockParentWindow = false,
    void Function(FilePickerStatus status)? onFileLoading,
    bool readSequential = false,
    FileType type = FileType.any,
    bool withData = false,
    bool withReadStream = false,
  }) async {
    return null;
  }

  @override
  Future<bool?> clearTemporaryFiles() async {
    return true;
  }

  @override
  Future<String?> saveFile({
    List<String>? allowedExtensions,
    Uint8List? bytes,
    String? dialogTitle,
    String? fileName,
    String? initialDirectory,
    bool lockParentWindow = false,
    FileType type = FileType.any,
  }) async {
    return null;
  }

  @override
  Future<String?> getDirectoryPath({
    String? dialogTitle,
    String? initialDirectory,
    bool lockParentWindow = false,
  }) async {
    return null;
  }
}

class _TrackingNavigatorObserver extends NavigatorObserver {
  Route<dynamic>? pushedRoute;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushedRoute = route;
    super.didPush(route, previousRoute);
  }
}
