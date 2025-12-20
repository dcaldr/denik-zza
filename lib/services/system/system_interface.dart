import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

/// Facade for System interactions (File Picker, Printing)
/// This allows us to mock these "Native UI" blocking calls during Integration Tests.
abstract class SystemInterface {
  static SystemInterface _instance = RealSystemInterface();
  static SystemInterface get instance => _instance;

  /// Injection method for tests
  static void registerWith(SystemInterface implementation) {
    _instance = implementation;
  }

  /// Wrapper for FilePicker.platform.pickFiles
  Future<FilePickerResult?> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    dynamic onFileLoading,
    bool allowMultiple = false,
    bool withData = false,
    bool withReadStream = false,
    bool lockParentWindow = false,
    bool readSequential = false,
  });

  /// Wrapper for Printing.layoutPdf
  Future<void> printPdf({
    required String name,
    required Future<Uint8List> Function(PdfPageFormat format) onLayout,
    PdfPageFormat format = PdfPageFormat.standard,
    bool usePrinterSettings = false,
    bool dynamicLayout = true,
  });
}

/// The Production implementation that calls the real Native plugins.
class RealSystemInterface implements SystemInterface {
  @override
  Future<FilePickerResult?> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    dynamic onFileLoading,
    bool allowMultiple = false,
    bool withData = false,
    bool withReadStream = false,
    bool lockParentWindow = false,
    bool readSequential = false,
  }) {
    return FilePicker.platform.pickFiles(
      dialogTitle: dialogTitle,
      initialDirectory: initialDirectory,
      type: type,
      allowedExtensions: allowedExtensions,
      onFileLoading: onFileLoading,
      allowMultiple: allowMultiple,
      withData: withData,
      withReadStream: withReadStream,
      lockParentWindow: lockParentWindow,
      readSequential: readSequential,
    );
  }

  @override
  Future<void> printPdf({
    required String name,
    required Future<Uint8List> Function(PdfPageFormat format) onLayout,
    PdfPageFormat format = PdfPageFormat.standard,
    bool usePrinterSettings = false,
    bool dynamicLayout = true,
  }) {
    return Printing.layoutPdf(
      onLayout: onLayout,
      name: name,
      format: format,
      usePrinterSettings: usePrinterSettings,
      dynamicLayout: dynamicLayout,
    );
  }
}

/// A Safe Stub implementation that does nothing (No UI) for integration tests.
class TestSystemInterface implements SystemInterface {
  @override
  Future<FilePickerResult?> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    dynamic onFileLoading,
    bool allowMultiple = false,
    bool withData = false,
    bool withReadStream = false,
    bool lockParentWindow = false,
    bool readSequential = false,
  }) async {
    // Return null simulating "User Cancelled" or "No Selection"
    // This prevents the native window from blocking the test.
    return null;
  }

  @override
  Future<void> printPdf({
    required String name,
    required Future<Uint8List> Function(PdfPageFormat format) onLayout,
    PdfPageFormat format = PdfPageFormat.standard,
    bool usePrinterSettings = false,
    bool dynamicLayout = true,
  }) async {
    // Verify the layout builder doesn't crash, but don't show UI.
    // We intentionally await the layout purely to test the generation code logic.
    await onLayout(format);
  }
}
