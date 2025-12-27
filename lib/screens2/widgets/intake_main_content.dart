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
            // Mobile: Stack vertically with scrolling (Global Scroll)
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildLeftColumn(isNarrow),
                  const SizedBox(height: 16),
                  _buildRightColumn(constraints, isNarrow),
                ],
              ),
            );
          }

          // Desktop/Tablet: Side by side (Fixed Panes)
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildLeftColumn(isNarrow),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildRightColumn(constraints, isNarrow),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLeftColumn(bool isNarrow) {
    if (isNarrow) {
      // Mobile: Just return the form.
      // The parent (build method) will wrap this in a ScrollView/Column.
      return participantRegistrationForm;
    }

    // Desktop: We want the form to FILL the available height so restrictions expand.
    // Clean Architecture: Use CustomScrollView + SliverFillRemaining
    return CustomScrollView(
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child:
              participantRegistrationForm, // Form receives Bounded Height -> Expands Restrictions
        ),
      ],
    );
  }

  Widget _buildRightColumn(BoxConstraints parentConstraints, bool isNarrow) {
    final child = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Second Column'),
        if (!isNarrow)
          Expanded(child: _buildFileViewer())
        else
          ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 400),
              child: _buildFileViewer()),
      ],
    );

    // On Desktop (Not Narrow), we want Expanded behavior
    // On Mobile (Narrow), we function as content
    return child;
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
