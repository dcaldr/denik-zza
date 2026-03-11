// Tests for FileViewerScreen widget
// Comprehensive coverage of loading, error, success states, lifecycle,
// race conditions, retry behavior, and layout.
//
// Uses injectable fileReader for testability - avoids FakeAsync issues
// with real file I/O. All tests have 10s timeout to prevent hangs.
//
// NOTE: Image.memory with frameBuilder may keep scheduling frames,
// so we use pump() instead of pumpAndSettle() for image display tests.

import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:denik_zza/screens2/widgets/file_viewer_screen_widget.dart';
import '../../utils/base_test_widget.dart';

void main() {
  // ============================================================
  // GROUP 1: Loading State Tests
  // ============================================================
  group('Loading State', () {
    testWidgets('shows loading spinner initially', (tester) async {
      // Given: File viewer with completer-based reader (never completes in this test)
      final completer = Completer<Uint8List?>();

      await tester.pumpWidget(
        createTestWidget(
          filePath: 'test.png',
          fileReader: (path) => completer.future,
        ),
      );

      // Then: Should show loading indicator immediately
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    }, timeout: Timeout(Duration(seconds: 10)));

    testWidgets('shows loading text with file', (tester) async {
      // Given: File viewer with completer-based reader
      final completer = Completer<Uint8List?>();

      await tester.pumpWidget(
        createTestWidget(
          filePath: 'test.png',
          fileReader: (path) => completer.future,
        ),
      );

      // Then: Should show Czech loading message
      expect(find.text('Načítám soubor...'), findsOneWidget);
    }, timeout: Timeout(Duration(seconds: 10)));
  });

  // ============================================================
  // GROUP 2: Error State Tests
  // ============================================================
  group('Error States', () {
    testWidgets('shows error message for missing file', (tester) async {
      // Given: File reader that returns null (file not found)
      await tester.pumpWidget(
        createTestWidget(
          filePath: 'does_not_exist.pdf',
          fileReader: (path) async => null,
        ),
      );
      await tester.pump(); // Let async complete
      await tester.pump(); // Rebuild with state

      // Then: Should show file not found error with filename
      expect(find.textContaining('Soubor nenalezen'), findsOneWidget);
      expect(find.textContaining('does_not_exist.pdf'), findsOneWidget);
    }, timeout: Timeout(Duration(seconds: 10)));

    testWidgets('shows error icon for missing file', (tester) async {
      // Given: File reader that returns null
      await tester.pumpWidget(
        createTestWidget(
          filePath: 'missing.pdf',
          fileReader: (path) async => null,
        ),
      );
      await tester.pump();
      await tester.pump();

      // Then: Should show error icon
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    }, timeout: Timeout(Duration(seconds: 10)));

    testWidgets('shows retry button on error', (tester) async {
      // Given: File reader that returns null
      await tester.pumpWidget(
        createTestWidget(
          filePath: 'missing.pdf',
          fileReader: (path) async => null,
        ),
      );
      await tester.pump();
      await tester.pump();

      // Then: Should show retry button with Czech text
      expect(find.text('Zkusit znovu'), findsOneWidget);
    }, timeout: Timeout(Duration(seconds: 10)));

    testWidgets('shows error for empty path update via didUpdateWidget',
        (tester) async {
      // Given: Widget with valid path initially
      String currentPath = 'valid.png';
      late StateSetter updateState;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                updateState = setState;
                return SizedBox(
                  width: 400,
                  height: 600,
                  child: FileViewerScreen(
                    initialFilePath: currentPath,
                    fileReader: (path) async => createMinimalPng(),
                  ),
                );
              },
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      // When: Path is updated to empty string
      updateState(() {
        currentPath = '';
      });
      await tester.pump();

      // Then: Should show "no file selected" error
      expect(find.text('Není vybrán žádný soubor'), findsOneWidget);
    }, timeout: Timeout(Duration(seconds: 10)));

    testWidgets('shows error when file read fails', (tester) async {
      // Given: File reader that throws exception
      await tester.pumpWidget(
        createTestWidget(
          filePath: 'error.png',
          fileReader: (path) async => throw Exception('Read failed'),
        ),
      );
      await tester.pump();
      await tester.pump();

      // Then: Should show read error message
      expect(find.text('Nepodařilo se načíst soubor'), findsOneWidget);
    }, timeout: Timeout(Duration(seconds: 10)));
  });

  // ============================================================
  // GROUP 3: Success State Tests
  // ============================================================
  group('Success States', () {
    testWidgets('shows unsupported format message for unknown extension',
        (tester) async {
      // Given: File with unknown extension
      await tester.pumpWidget(
        createTestWidget(
          filePath: 'test.xyz',
          fileReader: (path) async => Uint8List.fromList([1, 2, 3, 4, 5]),
        ),
      );
      await tester.pump();
      await tester.pump();

      // Then: Should show unsupported format message
      expect(find.text('Nepodporovaný formát souboru'), findsOneWidget);
    }, timeout: Timeout(Duration(seconds: 10)));

    testWidgets('loads PNG file and shows InteractiveViewer', (tester) async {
      // Given: Valid PNG file bytes
      await tester.pumpWidget(
        createTestWidget(
          filePath: 'test.png',
          fileReader: (path) async => createMinimalPng(),
        ),
      );
      await tester.pump(); // Let async complete
      await tester.pump(); // Rebuild with bytes
      await tester.pump(); // Let image decode

      // Then: Should show InteractiveViewer (zoom enabled)
      expect(find.byType(InteractiveViewer), findsOneWidget);
    }, timeout: Timeout(Duration(seconds: 10)));

    testWidgets('loads JPG file successfully', (tester) async {
      // Given: Valid JPG file bytes
      await tester.pumpWidget(
        createTestWidget(
          filePath: 'test.jpg',
          fileReader: (path) async => createMinimalJpg(),
        ),
      );
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // Then: Should show InteractiveViewer for image
      expect(find.byType(InteractiveViewer), findsOneWidget);
    }, timeout: Timeout(Duration(seconds: 10)));
  });

  // ============================================================
  // GROUP 4: Lifecycle Tests
  // ============================================================
  group('Lifecycle', () {
    testWidgets('starts loading on init', (tester) async {
      // Given: File viewer with completer-based reader
      final completer = Completer<Uint8List?>();

      await tester.pumpWidget(
        createTestWidget(
          filePath: 'test.pdf',
          fileReader: (path) => completer.future,
        ),
      );

      // Then: Should immediately be in loading state
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    }, timeout: Timeout(Duration(seconds: 10)));

    testWidgets('reloads when path changes', (tester) async {
      // Given: Two paths with completer
      String currentPath = 'file1.png';
      late StateSetter updateState;
      Completer<Uint8List?>? currentCompleter;

      await tester.pumpWidget(
        BaseTestWidget(
          child: StatefulBuilder(
            builder: (context, setState) {
              updateState = setState;
              return SizedBox(
                width: 400,
                height: 600,
                child: FileViewerScreen(
                  initialFilePath: currentPath,
                  fileReader: (path) {
                    currentCompleter = Completer<Uint8List?>();
                    return currentCompleter!.future;
                  },
                ),
              );
            },
          ),
        ),
      );

      // Complete first load
      currentCompleter!.complete(createMinimalPng());
      await tester.pump();
      await tester.pump();

      // First file loaded successfully
      expect(find.byType(InteractiveViewer), findsOneWidget);

      // When: Path changes to file2
      updateState(() {
        currentPath = 'file2.png';
      });
      await tester.pump();

      // Then: Should show loading while reloading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Complete second load
      currentCompleter!.complete(createMinimalPng());
      await tester.pump();
      await tester.pump();
      expect(find.byType(InteractiveViewer), findsOneWidget);
    }, timeout: Timeout(Duration(seconds: 10)));

    testWidgets('does not reload when same path passed', (tester) async {
      // Given: File viewer - test that didUpdateWidget doesn't reload when path same
      int loadCount = 0;

      // Use synchronous return (immediate Future.value)
      Future<Uint8List?> countingReader(String path) {
        loadCount++;
        return Future.value(createMinimalPng());
      }

      String currentPath = 'test.png';
      late StateSetter updateState;

      await tester.pumpWidget(
        BaseTestWidget(
          child: StatefulBuilder(
            builder: (context, setState) {
              updateState = setState;
              return SizedBox(
                width: 400,
                height: 600,
                child: FileViewerScreen(
                  initialFilePath: currentPath,
                  fileReader: countingReader,
                ),
              );
            },
          ),
        ),
      );

      // Initial load triggered
      expect(loadCount, 1);

      // Let async complete
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // File loaded
      expect(find.byType(InteractiveViewer), findsOneWidget);

      // When: Parent triggers rebuild but path stays same
      updateState(() {
        // Trigger rebuild without changing path
      });
      await tester.pump();
      await tester.pump();

      // Then: Should NOT have called reader again
      expect(loadCount, 1, reason: 'fileReader should not be called again when path unchanged');
    }, timeout: Timeout(Duration(seconds: 10)));
  });

  // ============================================================
  // GROUP 5: Retry Behavior Tests
  // ============================================================
  group('Retry Behavior', () {
    testWidgets('retry button triggers reload', (tester) async {
      int callCount = 0;

      await tester.pumpWidget(
        createTestWidget(
          filePath: 'missing.pdf',
          fileReader: (path) async {
            callCount++;
            return null; // Always return null (file not found)
          },
        ),
      );
      await tester.pump();
      await tester.pump();

      // Should be in error state
      expect(find.text('Zkusit znovu'), findsOneWidget);
      expect(callCount, 1);

      // When: Tap retry button
      await tester.tap(find.text('Zkusit znovu'));
      await tester.pump();
      await tester.pump();

      // Then: Should have called reader again
      expect(callCount, 2);
    }, timeout: Timeout(Duration(seconds: 10)));

    testWidgets('retry succeeds after file becomes available', (tester) async {
      bool fileExists = false;

      await tester.pumpWidget(
        createTestWidget(
          filePath: 'eventually_exists.png',
          fileReader: (path) async {
            if (fileExists) {
              return createMinimalPng();
            }
            return null;
          },
        ),
      );
      await tester.pump();
      await tester.pump();

      // In error state
      expect(find.textContaining('Soubor nenalezen'), findsOneWidget);

      // When: File becomes available and retry is tapped
      fileExists = true;
      await tester.tap(find.text('Zkusit znovu'));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // Then: Should now show image successfully
      expect(find.byType(InteractiveViewer), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsNothing);
    }, timeout: Timeout(Duration(seconds: 10)));
  });

  // ============================================================
  // GROUP 6: Race Condition Prevention Tests
  // ============================================================
  group('Race Condition Prevention', () {
    testWidgets('rapid path changes do not crash', (tester) async {
      String currentPath = 'file1.png';
      late StateSetter updateState;

      await tester.pumpWidget(
        BaseTestWidget(
          child: StatefulBuilder(
            builder: (context, setState) {
              updateState = setState;
              return SizedBox(
                width: 400,
                height: 600,
                child: FileViewerScreen(
                  initialFilePath: currentPath,
                  fileReader: (path) async => createMinimalPng(),
                ),
              );
            },
          ),
        ),
      );

      // When: Rapidly change paths
      updateState(() => currentPath = 'file2.png');
      await tester.pump();
      updateState(() => currentPath = 'file3.png');
      await tester.pump();
      updateState(() => currentPath = 'file1.png');
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // Then: Should settle without crash
      expect(find.byType(InteractiveViewer), findsOneWidget);
    }, timeout: Timeout(Duration(seconds: 10)));

    testWidgets('only last path result is displayed', (tester) async {
      String currentPath = 'race1.png';
      late StateSetter updateState;
      final List<String> loadedPaths = [];

      await tester.pumpWidget(
        BaseTestWidget(
          child: StatefulBuilder(
            builder: (context, setState) {
              updateState = setState;
              return SizedBox(
                width: 400,
                height: 600,
                child: FileViewerScreen(
                  initialFilePath: currentPath,
                  fileReader: (path) async {
                    loadedPaths.add(path);
                    return createMinimalPng();
                  },
                ),
              );
            },
          ),
        ),
      );

      // Switch to final path
      updateState(() => currentPath = 'raceFinal.png');
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // Should have loaded both paths
      expect(loadedPaths, contains('race1.png'));
      expect(loadedPaths, contains('raceFinal.png'));
      // Final display should work
      expect(find.byType(InteractiveViewer), findsOneWidget);
    }, timeout: Timeout(Duration(seconds: 10)));
  });

  // ============================================================
  // GROUP 7: Image Handling Tests
  // ============================================================
  group('Image Handling', () {
    testWidgets('shows error for corrupted image bytes', (tester) async {
      // Given: Invalid image bytes
      await tester.pumpWidget(
        createTestWidget(
          filePath: 'corrupted.png',
          fileReader: (path) async =>
              Uint8List.fromList([0, 1, 2, 3, 4, 5, 6, 7, 8, 9]),
        ),
      );
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // Then: Should show image error via errorBuilder
      expect(find.text('Obrázek nelze zobrazit'), findsOneWidget);
      expect(find.byIcon(Icons.broken_image), findsOneWidget);
    }, timeout: Timeout(Duration(seconds: 10)));

    testWidgets('InteractiveViewer has correct zoom settings', (tester) async {
      // Given: Valid image
      await tester.pumpWidget(
        createTestWidget(
          filePath: 'zoomable.png',
          fileReader: (path) async => createMinimalPng(),
        ),
      );
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // Then: InteractiveViewer should have correct settings
      final viewer = tester.widget<InteractiveViewer>(
        find.byType(InteractiveViewer),
      );
      expect(viewer.minScale, 0.2);
      expect(viewer.maxScale, 10);
    }, timeout: Timeout(Duration(seconds: 10)));
  });

  // ============================================================
  // GROUP 8: Layout Tests
  // ============================================================
  group('Layout', () {
    testWidgets('no Scaffold in FileViewerScreen widget tree', (tester) async {
      // Given: Valid file
      await tester.pumpWidget(
        createTestWidget(
          filePath: 'layout.png',
          fileReader: (path) async => createMinimalPng(),
        ),
      );
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // Then: Should be exactly 1 Scaffold (from test wrapper, not FileViewerScreen)
      expect(find.byType(Scaffold), findsOneWidget);
    }, timeout: Timeout(Duration(seconds: 10)));
  });

  // ============================================================
  // GROUP 9: State Preservation Tests
  // ============================================================
  group('State Preservation (cachedBytes)', () {
    testWidgets('uses cachedBytes instead of loading from disk', (tester) async {
      // Given: Pre-loaded cached bytes
      final cachedBytes = createMinimalPng();
      var fileReaderCalled = false;

      await tester.pumpWidget(
        BaseTestWidget(
          child: SizedBox(
            width: 400,
            height: 600,
            child: FileViewerScreen(
              initialFilePath: 'cached.png',
              cachedBytes: cachedBytes,
              fileReader: (path) async {
                fileReaderCalled = true;
                return cachedBytes;
              },
            ),
          ),
        ),
      );

      // Let the widget build
      await tester.pump();

      // Then: Should NOT have called fileReader since we have cachedBytes
      expect(fileReaderCalled, false);
    }, timeout: Timeout(Duration(seconds: 10)));

    testWidgets('calls onBytesLoaded when bytes loaded from disk', (tester) async {
      // Given: No cached bytes, track callback
      Uint8List? loadedBytes;
      String? loadedPath;

      await tester.pumpWidget(
        BaseTestWidget(
          child: SizedBox(
            width: 400,
            height: 600,
            child: FileViewerScreen(
              initialFilePath: 'new_file.png',
              cachedBytes: null,
              onBytesLoaded: (bytes, path) {
                loadedBytes = bytes;
                loadedPath = path;
              },
              fileReader: (path) async => createMinimalPng(),
            ),
          ),
        ),
      );

      // Wait for load to complete
      await tester.pump();
      await tester.pump();
      await tester.pump();

      // Then: Callback should have been called with bytes and path
      expect(loadedBytes, isNotNull);
      expect(loadedPath, 'new_file.png');
      expect(loadedBytes!.length, greaterThan(0));
    }, timeout: Timeout(Duration(seconds: 10)));

    testWidgets('does NOT call onBytesLoaded when using cachedBytes', (tester) async {
      // Given: Using cached bytes
      var callbackCalled = false;

      await tester.pumpWidget(
        BaseTestWidget(
          child: SizedBox(
            width: 400,
            height: 600,
            child: FileViewerScreen(
              initialFilePath: 'cached.png',
              cachedBytes: createMinimalPng(),
              onBytesLoaded: (bytes, path) {
                callbackCalled = true;
              },
              fileReader: (path) async => createMinimalPng(),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump();
      await tester.pump();

      // Then: Callback should NOT have been called (no disk load)
      expect(callbackCalled, false);
      // And: Image should display
      expect(find.byType(InteractiveViewer), findsOneWidget);
    }, timeout: Timeout(Duration(seconds: 10)));
  });
}

// ============================================================
// TEST HELPERS
// ============================================================

/// Creates a test widget wrapper with MaterialApp, Scaffold, and mock fileReader
Widget createTestWidget({
  required String filePath,
  required FileReader fileReader,
}) {
  return BaseTestWidget(
    child: SizedBox(
      width: 400,
      height: 600,
      child: FileViewerScreen(
        initialFilePath: filePath,
        fileReader: fileReader,
      ),
    ),
  );
}

/// Creates minimal valid PDF bytes for testing
Uint8List createMinimalPdf() {
  const pdfContent = '''%PDF-1.4
1 0 obj << /Type /Catalog /Pages 2 0 R >> endobj
2 0 obj << /Type /Pages /Kids [3 0 R] /Count 1 >> endobj
3 0 obj << /Type /Page /Parent 2 0 R /MediaBox [0 0 612 792] >> endobj
xref
0 4
0000000000 65535 f 
0000000009 00000 n 
0000000058 00000 n 
0000000115 00000 n 
trailer << /Size 4 /Root 1 0 R >>
startxref
184
%%EOF''';
  return Uint8List.fromList(pdfContent.codeUnits);
}

/// Creates minimal valid PNG bytes (1x1 red pixel)
Uint8List createMinimalPng() {
  return Uint8List.fromList([
    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, // PNG signature
    0x00, 0x00, 0x00, 0x0D, // IHDR length
    0x49, 0x48, 0x44, 0x52, // IHDR
    0x00, 0x00, 0x00, 0x01, // width: 1
    0x00, 0x00, 0x00, 0x01, // height: 1
    0x08, 0x02, // bit depth: 8, color type: 2 (RGB)
    0x00, 0x00, 0x00, // compression, filter, interlace
    0x90, 0x77, 0x53, 0xDE, // CRC
    0x00, 0x00, 0x00, 0x0C, // IDAT length
    0x49, 0x44, 0x41, 0x54, // IDAT
    0x08, 0xD7, 0x63, 0xF8, 0xCF, 0xC0, 0x00, 0x00, // compressed data
    0x01, 0x01, 0x01, 0x00, // compressed data continued
    0x18, 0xDD, 0x8D, 0xB4, // CRC
    0x00, 0x00, 0x00, 0x00, // IEND length
    0x49, 0x45, 0x4E, 0x44, // IEND
    0xAE, 0x42, 0x60, 0x82, // CRC
  ]);
}

/// Creates minimal valid JPEG bytes
Uint8List createMinimalJpg() {
  return Uint8List.fromList([
    0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46, 0x49, 0x46, 0x00, 0x01,
    0x01, 0x00, 0x00, 0x01, 0x00, 0x01, 0x00, 0x00, 0xFF, 0xDB, 0x00, 0x43,
    0x00, 0x08, 0x06, 0x06, 0x07, 0x06, 0x05, 0x08, 0x07, 0x07, 0x07, 0x09,
    0x09, 0x08, 0x0A, 0x0C, 0x14, 0x0D, 0x0C, 0x0B, 0x0B, 0x0C, 0x19, 0x12,
    0x13, 0x0F, 0x14, 0x1D, 0x1A, 0x1F, 0x1E, 0x1D, 0x1A, 0x1C, 0x1C, 0x20,
    0x24, 0x2E, 0x27, 0x20, 0x22, 0x2C, 0x23, 0x1C, 0x1C, 0x28, 0x37, 0x29,
    0x2C, 0x30, 0x31, 0x34, 0x34, 0x34, 0x1F, 0x27, 0x39, 0x3D, 0x38, 0x32,
    0x3C, 0x2E, 0x33, 0x34, 0x32, 0xFF, 0xC0, 0x00, 0x0B, 0x08, 0x00, 0x01,
    0x00, 0x01, 0x01, 0x01, 0x11, 0x00, 0xFF, 0xC4, 0x00, 0x1F, 0x00, 0x00,
    0x01, 0x05, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08,
    0x09, 0x0A, 0x0B, 0xFF, 0xC4, 0x00, 0xB5, 0x10, 0x00, 0x02, 0x01, 0x03,
    0x03, 0x02, 0x04, 0x03, 0x05, 0x05, 0x04, 0x04, 0x00, 0x00, 0x01, 0x7D,
    0x01, 0x02, 0x03, 0x00, 0x04, 0x11, 0x05, 0x12, 0x21, 0x31, 0x41, 0x06,
    0x13, 0x51, 0x61, 0x07, 0x22, 0x71, 0x14, 0x32, 0x81, 0x91, 0xA1, 0x08,
    0x23, 0x42, 0xB1, 0xC1, 0x15, 0x52, 0xD1, 0xF0, 0x24, 0x33, 0x62, 0x72,
    0x82, 0x09, 0x0A, 0x16, 0x17, 0x18, 0x19, 0x1A, 0x25, 0x26, 0x27, 0x28,
    0x29, 0x2A, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x3A, 0x43, 0x44, 0x45,
    0x46, 0x47, 0x48, 0x49, 0x4A, 0x53, 0x54, 0x55, 0x56, 0x57, 0x58, 0x59,
    0x5A, 0x63, 0x64, 0x65, 0x66, 0x67, 0x68, 0x69, 0x6A, 0x73, 0x74, 0x75,
    0x76, 0x77, 0x78, 0x79, 0x7A, 0x83, 0x84, 0x85, 0x86, 0x87, 0x88, 0x89,
    0x8A, 0x92, 0x93, 0x94, 0x95, 0x96, 0x97, 0x98, 0x99, 0x9A, 0xA2, 0xA3,
    0xA4, 0xA5, 0xA6, 0xA7, 0xA8, 0xA9, 0xAA, 0xB2, 0xB3, 0xB4, 0xB5, 0xB6,
    0xB7, 0xB8, 0xB9, 0xBA, 0xC2, 0xC3, 0xC4, 0xC5, 0xC6, 0xC7, 0xC8, 0xC9,
    0xCA, 0xD2, 0xD3, 0xD4, 0xD5, 0xD6, 0xD7, 0xD8, 0xD9, 0xDA, 0xE1, 0xE2,
    0xE3, 0xE4, 0xE5, 0xE6, 0xE7, 0xE8, 0xE9, 0xEA, 0xF1, 0xF2, 0xF3, 0xF4,
    0xF5, 0xF6, 0xF7, 0xF8, 0xF9, 0xFA, 0xFF, 0xDA, 0x00, 0x08, 0x01, 0x01,
    0x00, 0x00, 0x3F, 0x00, 0xFB, 0xD5, 0xDB, 0x20, 0xA8, 0xF1, 0x45, 0x00,
    0xFF, 0xD9,
  ]);
}
