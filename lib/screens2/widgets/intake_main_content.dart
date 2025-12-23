import 'dart:io';
import 'package:flutter/material.dart';
import '../../database/in_memory_structures_tmp/memory_osoba.dart';
import '../participant_registration_form.dart';
import 'file_viewer_logic.dart';
import 'file_viewer_screen_widget.dart';
import 'package:denik_zza/design_system/tokens/app_spacing.dart';
import 'package:denik_zza/design_system/tokens/app_breakpoints.dart';

class IntakeMainContent extends StatelessWidget {
  final MemoryOsoba? selectedPerson;
  final Function(String) onFileUploaded;
  final Directory? zpusobilostFolder;
  final ParticipantRegistrationForm participantRegistrationForm;

  const IntakeMainContent({
    super.key,
    required this.selectedPerson,
    required this.onFileUploaded,
    required this.zpusobilostFolder,
    required this.participantRegistrationForm,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.screenPadding,
      // Use LayoutBuilder for parent-relative sizing instead of MediaQuery.
      // See /flutter-ui workflow: "Use constraints, not percentages".
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = AppBreakpoints.isMobile(constraints.maxWidth);

          if (isNarrow) {
            // Mobile: Stack vertically with scrolling
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildLeftColumn(),
                const SizedBox(height: 16),
                _buildRightColumn(constraints),
              ],
            );
          }

          // Desktop/Tablet: Side by side
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildLeftColumn(),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildRightColumn(constraints),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLeftColumn() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('First Column'),
        participantRegistrationForm,
      ],
    );
  }

  Widget _buildRightColumn(BoxConstraints parentConstraints) {
    // Handle unbounded height (e.g., inside SingleChildScrollView)
    // Use reasonable default when parent doesn't constrain height
    final maxHeight = parentConstraints.hasBoundedHeight
        ? parentConstraints.maxHeight * 0.6
        : 400.0; // Fallback for unbounded scenarios

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Second Column'),
        // Use parent constraints instead of MediaQuery ratio
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: maxHeight,
          ),
          child: _buildFileViewer(),
        ),
      ],
    );
  }

  Widget _buildFileViewer() {
    final hasFile = zpusobilostFolder != null &&
        selectedPerson?.potvrzeniPath != null &&
        selectedPerson!.potvrzeniPath!.isNotEmpty;

    if (hasFile) {
      return FileViewerScreen(
          initialFilePath:
              '${zpusobilostFolder!.path}/${selectedPerson!.potvrzeniPath}');
    } else {
      return FileViewerLogic(onFileUploaded: onFileUploaded);
    }
  }
}
