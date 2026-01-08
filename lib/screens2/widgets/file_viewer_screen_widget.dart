import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:denik_zza/utils/app_logger.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:printing/printing.dart';

/// Function type for reading file bytes.
/// Used for dependency injection in tests.
typedef FileReader = Future<Uint8List?> Function(String filePath);

/// Default file reader implementation using dart:io File.
/// Returns null if file doesn't exist, throws on read errors.
Future<Uint8List?> defaultFileReader(String filePath) async {
  final file = File(filePath);
  if (!await file.exists()) {
    return null;
  }
  return await file.readAsBytes();
}

/// Widget for viewing PDF and image files with async loading,
/// error handling, and progressive image display.
///
/// Supports dependency injection of [fileReader] for testability.
class FileViewerScreen extends StatefulWidget {
  final String initialFilePath;

  /// Optional file reader for dependency injection.
  /// Defaults to [defaultFileReader] which uses dart:io File.
  /// In tests, inject a mock that returns test bytes directly.
  final FileReader? fileReader;

  const FileViewerScreen({
    super.key,
    required this.initialFilePath,
    this.fileReader,
  });

  @override
  State<FileViewerScreen> createState() => _FileViewerScreenState();
}

class _FileViewerScreenState extends State<FileViewerScreen> {
  late String filePath;
  final Logger _logger = AppLogger.l;

  // Async loading state
  bool _isLoading = true;
  String? _errorMessage;
  Uint8List? _fileBytes;

  // Race condition prevention - tracks current load operation
  int _loadId = 0;

  /// Gets the file reader to use (injected or default)
  FileReader get _fileReader => widget.fileReader ?? defaultFileReader;

  @override
  void initState() {
    super.initState();
    filePath = widget.initialFilePath;
    _logger.i('FileViewerScreen initialized: $filePath');
    _loadFileAsync();
  }

  @override
  void didUpdateWidget(FileViewerScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialFilePath != widget.initialFilePath) {
      // Validate new path
      if (widget.initialFilePath.isEmpty) {
        setState(() {
          filePath = widget.initialFilePath;
          _fileBytes = null;
          _errorMessage = 'Není vybrán žádný soubor';
          _isLoading = false;
        });
        return;
      }

      filePath = widget.initialFilePath;
      _fileBytes = null; // Clear old bytes
      _errorMessage = null;
      _logger.i('FileViewerScreen path updated: $filePath');
      _loadFileAsync();
    }
  }

  /// Loads file bytes asynchronously with race condition protection.
  Future<void> _loadFileAsync() async {
    final currentLoadId = ++_loadId; // Capture current load ID

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final bytes = await _fileReader(filePath);

      if (!mounted || _loadId != currentLoadId) return;

      if (bytes == null) {
        // File doesn't exist
        setState(() {
          _isLoading = false;
          _errorMessage = 'Soubor nenalezen: ${path.basename(filePath)}';
        });
      } else {
        // Success
        setState(() {
          _fileBytes = bytes;
          _isLoading = false;
        });
      }
    } catch (e) {
      _logger.e('Failed to read file: $e');
      if (mounted && _loadId == currentLoadId) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Nepodařilo se načíst soubor';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Loading state
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 8),
            Text('Načítám soubor...'),
          ],
        ),
      );
    }

    // Error state
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 8),
            Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadFileAsync,
              child: const Text('Zkusit znovu'),
            ),
          ],
        ),
      );
    }

    // Success - show content based on extension
    final String extension = path.extension(filePath).toLowerCase();
    return _buildView(extension);
  }

  Widget _buildView(String extension) {
    if (extension == '.pdf') {
      return _buildPDFView();
    } else if (extension == '.jpg' ||
        extension == '.jpeg' ||
        extension == '.png') {
      return _buildImageView();
    } else {
      return const Center(child: Text('Nepodporovaný formát souboru'));
    }
  }

  Widget _buildPDFView() {
    // LayoutBuilder needed for maxPageWidth calculation
    // No Container with 80%/90% constraints - PdfPreview fills available space
    return LayoutBuilder(
      builder: (context, constraints) {
        return PdfPreview(
          build: (format) => _fileBytes!,
          maxPageWidth: constraints.maxWidth * 2,
        );
      },
    );
  }

  Widget _buildImageView() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return InteractiveViewer(
          minScale: 0.2,
          maxScale: 10,
          child: Center(
            child: Image.memory(
              _fileBytes!,
              fit: BoxFit.contain,
              // Handle sync vs async loading - show spinner until decoded
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                if (wasSynchronouslyLoaded || frame != null) {
                  return child;
                }
                return const Center(child: CircularProgressIndicator());
              },
              // Handle decode errors (corrupted images)
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.broken_image, size: 48, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('Obrázek nelze zobrazit'),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
