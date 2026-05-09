import 'dart:async';

import 'package:denik_zza/screens2/csv/table_overview_screen.dart';
import 'package:denik_zza/screens2/widgets/app_drawer.dart';
import 'package:denik_zza/services/csv_import_service.dart';
import 'package:denik_zza/services/models/csv_import_payload.dart';
import 'package:denik_zza/input/file_manager.dart';
import 'package:denik_zza/utils/app_logger.dart';
import 'package:denik_zza/utils/file_exceptions.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:denik_zza/design_system/tokens/app_spacing.dart';
import 'package:denik_zza/design_system/tokens/app_radii.dart';
import 'package:denik_zza/services/system/system_interface.dart';

/// Entry screen for the CSV review flow allowing the operator to pick a file
/// and launch the table overview review experience.
class CsvImportScreen extends StatefulWidget {
  const CsvImportScreen({super.key});

  /// Opens the import flow and returns the finalize result, if any, when the
  /// flow finishes.
  static Future<CsvFinalizeResult?> open(BuildContext context) {
    return Navigator.of(context).push<CsvFinalizeResult?>(
      MaterialPageRoute<CsvFinalizeResult?>(
        builder: (BuildContext context) => const CsvImportScreen(),
      ),
    );
  }

  @override
  State<CsvImportScreen> createState() => _CsvImportScreenState();
}

class _CsvImportScreenState extends State<CsvImportScreen> {
  final Logger _logger = AppLogger.l;

  CsvImportPayload? _selectedPayload;
  String? _selectedFileName;
  String? _errorMessage;
  bool _isPicking = false;
  bool _isNavigating = false;
  String? _tempFilePath;

  bool get _canContinue => _selectedPayload != null && !_isNavigating;

  @override
  void dispose() {
    unawaited(_cleanupTempFile());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import CSV'),
      ),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screenPaddingGenerous,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Vyberte soubor CSV pro import účastníků.',
                key: const Key('CsvImportScreen_instruction_label'),
                style: theme.textTheme.titleMedium,
              ),
              AppSpacing.smallGap,
              Text(
                'Soubor musí být ve formátu CSV se stejným pořadím sloupců jako v šabloně. '
                'Nepovolené soubory budou odmítnuty.',
                style: theme.textTheme.bodyMedium,
              ),
              AppSpacing.largeGap,
              _buildSelectionPreview(theme),
              if (_errorMessage != null) ...<Widget>[
                AppSpacing.smallGap,
                Text(
                  _errorMessage!,
                  key: const Key('CsvImportScreen_error_label'),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
              AppSpacing.largeGap,
              Row(
                children: <Widget>[
                  OutlinedButton(
                    key: const Key('CsvImportScreen_pick_button'),
                    onPressed: _isPicking ? null : _handlePickPressed,
                    child: _isPicking
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Vybrat soubor'),
                  ),
                  AppSpacing.buttonGap,
                  FilledButton(
                    key: const Key('CsvImportScreen_continue_button'),
                    onPressed: _canContinue ? _handleContinuePressed : null,
                    child: const Text('Pokračovat'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // TODO: Add drag-and-drop support for CSV uploads.
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionPreview(ThemeData theme) {
    final bool hasSelection = _selectedPayload != null;
    final Color borderColor = hasSelection
        ? theme.colorScheme.primary
        : theme.colorScheme.outlineVariant;
    final Color textColor = hasSelection
        ? theme.colorScheme.onSurface
        : theme.colorScheme.onSurfaceVariant;

    // Make the entire container clickable, but only filename selectable
    return InkWell(
      key: const Key('CsvImportScreen_file_box'),
      onTap: _isPicking ? null : _handlePickPressed,
      borderRadius: AppRadii.containerRadius,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          borderRadius: AppRadii.containerRadius,
          border: Border.all(color: borderColor),
        ),
        child: hasSelection
            ? Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  Text(
                    'Vybraný soubor: ',
                    key: const Key('CsvImportScreen_file_label_prefix'),
                    style:
                        theme.textTheme.bodyLarge?.copyWith(color: textColor),
                  ),
                  SelectableText(
                    _selectedFileName ?? "(bez názvu)",
                    key: const Key('CsvImportScreen_file_name'),
                    style:
                        theme.textTheme.bodyLarge?.copyWith(color: textColor),
                  ),
                ],
              )
            : Text(
                'Zatím nebyl vybrán žádný soubor.',
                key: const Key('CsvImportScreen_file_label_empty'),
                style: theme.textTheme.bodyLarge?.copyWith(color: textColor),
              ),
      ),
    );
  }

  Future<void> _handlePickPressed() async {
    if (_isPicking) {
      return;
    }
    setState(() {
      _isPicking = true;
      _errorMessage = null;
    });

    try {
      final FilePickerResult? result = await SystemInterface.instance.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: const <String>['csv'],
        withData: true,
        withReadStream: true,
      );
      if (!mounted) {
        return;
      }
      if (result == null || result.files.isEmpty) {
        setState(() {
          _isPicking = false;
        });
        return;
      }

      final PlatformFile file = result.files.single;
      if (!_hasCsvExtension(file)) {
        setState(() {
          _selectedPayload = null;
          _selectedFileName = file.name;
          _errorMessage = 'Vybraný soubor musí mít příponu CSV.';
          _isPicking = false;
        });
        return;
      }

      final CsvImportPayload? payload = await _createPayload(file);
      if (!mounted) {
        return;
      }

      setState(() {
        _selectedPayload = payload;
        _selectedFileName =
            file.name.trim().isEmpty ? 'import.csv' : file.name.trim();
        if (payload == null) {
          _errorMessage = 'Soubor se nepodařilo připravit.';
        } else {
          _errorMessage = null;
        }
        _isPicking = false;
      });
    } catch (error, stackTrace) {
      _logger.e('$csvImportFlowLogTag: Failed to pick CSV file.',
          error: error, stackTrace: stackTrace);
      if (!mounted) {
        return;
      }
      setState(() {
        _selectedPayload = null;
        _errorMessage = 'Soubor se nepodařilo načíst.';
        _isPicking = false;
      });
      _showSnackBar('Soubor se nepodařilo načíst. Zkuste to prosím znovu.');
    }
  }

  Future<void> _handleContinuePressed() async {
    final CsvImportPayload? payload = _selectedPayload;
    if (payload == null || _isNavigating) {
      return;
    }

    setState(() {
      _isNavigating = true;
    });

    _logger.i(
      '$csvImportFlowLogTag: Navigating to table overview for ${payload.displayName}.',
    );

    final CsvFinalizeResult? result =
        await Navigator.of(context).push<CsvFinalizeResult?>(
      MaterialPageRoute<CsvFinalizeResult?>(
        builder: (BuildContext context) => CsvReviewTableOverviewScreen(
          payload: payload,
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    if (_tempFilePath != null) {
      await _cleanupTempFile();
    }

    setState(() {
      _isNavigating = false;
    });

    if (result != null && mounted) {
      _logger.i(
        '$csvImportFlowLogTag: Flow returned from review with finalize result (saved=${result.savedCount}, failed=${result.failedCount}).',
      );
      Navigator.of(context).pop(result);
    }
  }

  bool _hasCsvExtension(PlatformFile file) {
    final String? explicitExtension = file.extension?.toLowerCase();
    if (explicitExtension == 'csv') {
      return true;
    }
    final String fileName = file.name.toLowerCase();
    return fileName.endsWith('.csv');
  }

  Future<CsvImportPayload?> _createPayload(PlatformFile file) async {
    final String displayName =
        file.name.trim().isEmpty ? 'import.csv' : file.name.trim();

    if (kIsWeb) {
      final Uint8List? bytes = file.bytes;
      if (bytes == null) {
        _logger.e(
          '$csvImportFlowLogTag: File picker did not provide bytes for web payload. Name: ${file.name}',
        );
        _showSnackBar('Soubor se nepodařilo načíst z prohlížeče.');
        return null;
      }
      await _cleanupTempFile();
      return CsvImportPayload.fromBytes(bytes: bytes, displayName: displayName);
    }

    final String? existingPath = file.path;
    if (existingPath != null && existingPath.isNotEmpty) {
      await _cleanupTempFile();
      return CsvImportPayload.fromPath(
        path: existingPath,
        displayName: displayName,
      );
    }

    try {
      final Uint8List? bytes = await _resolveBytes(file);
      if (bytes == null || bytes.isEmpty) {
        throw StateError('No CSV data available for payload.');
      }
      await _cleanupTempFile();
      final String tempPath = await FileManager().writeTempCsvBytes(
        bytes,
        suggestedName: displayName,
      );
      _tempFilePath = tempPath;
      return CsvImportPayload.fromPath(
        path: tempPath,
        displayName: displayName,
      );
    } catch (error, stackTrace) {
      _logger.e('$csvImportFlowLogTag: Failed to prepare CSV payload.',
          error: error, stackTrace: stackTrace);
      if (mounted) {
        if (error is TempFileException || error is FileOperationException) {
          _showSnackBar('Nepodařilo se uložit dočasný soubor. Zkuste to znovu.');
        } else {
          _showSnackBar('Soubor se nepodařilo připravit. Zkuste to prosím znovu.');
        }
      }
      return null;
    }
  }

  Future<Uint8List?> _resolveBytes(PlatformFile file) async {
    final Uint8List? inMemoryBytes = file.bytes;
    if (inMemoryBytes != null) {
      return inMemoryBytes;
    }

    final Stream<List<int>>? stream = file.readStream;
    if (stream == null) {
      return null;
    }

    final List<int> buffer = <int>[];
    try {
      await for (final List<int> chunk in stream) {
        buffer.addAll(chunk);
      }
      return Uint8List.fromList(buffer);
    } catch (error, stackTrace) {
      _logger.e(
        '$csvImportFlowLogTag: Failed while reading CSV stream.',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  Future<void> _cleanupTempFile() async {
    if (_tempFilePath == null) {
      return;
    }
    try {
      await FileManager().deleteTempFile(_tempFilePath!);
    } catch (error, stackTrace) {
      _logger.w(
        '$csvImportFlowLogTag: Failed to delete temporary CSV file created during import.',
        error: error,
        stackTrace: stackTrace,
      );
    } finally {
      _tempFilePath = null;
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
