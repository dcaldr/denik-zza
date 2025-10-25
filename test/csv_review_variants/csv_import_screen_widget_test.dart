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
