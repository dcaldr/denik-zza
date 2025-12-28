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
          // Use compact height breakpoint to decide if we should force fill (fixed) or allow scrolling
          final isCompact =
              AppBreakpoints.isCompactHeight(constraints.maxHeight);

          if (isNarrow) {
            // Mobile: Stack vertically with scrolling (Global Scroll)
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _buildRightColumn(
                      context, constraints, isNarrow), // Camera/Gallery
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: _buildLeftColumn(
                        context, constraints, isNarrow), // Form (Unbounded)
                  ),
                ),
              ],
            );
          }

          // Desktop/Tablet: Side-by-side
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left Column: Form
              Expanded(
                flex: 4,
                child: _buildLeftColumn(context, constraints, isNarrow),
              ),
              const SizedBox(width: 24),
              // Right Column: Camera/Gallery (Always fills remaining vertical space)
              Expanded(
                flex: 3,
                child: _buildRightColumn(context, constraints, isNarrow),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLeftColumn(
      BuildContext context, BoxConstraints constraints, bool isNarrow) {
    if (isNarrow) {
      // Mobile: Just return the form.
      // The parent (build method) will wrap this in a ScrollView/Column.
      return participantRegistrationForm;
    }

    // If we have limited vertical space, we shouldn't force the form to "fill" the remaining space,
    // because it might be smaller than the form's minimum height (causing crash).
    // Instead, we use SliverToBoxAdapter to let it flow naturally.
    final isCompact = AppBreakpoints.isCompactHeight(constraints.maxHeight);

    if (isCompact) {
      return CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: participantRegistrationForm,
          ),
        ],
      );
    }

    // Default Desktop: Fill remaining space to allow "Expanded" widgets in form to work.
    return CustomScrollView(
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: participantRegistrationForm,
        ),
      ],
    );
  }

  Widget _buildRightColumn(
      BuildContext context, BoxConstraints parentConstraints, bool isNarrow) {
    final child = Column(
      mainAxisSize: MainAxisSize.max,
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
