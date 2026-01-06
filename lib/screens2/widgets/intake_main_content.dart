import 'dart:io';
import 'package:flutter/material.dart';
import '../../database/in_memory_structures_tmp/memory_osoba.dart';
import '../participant_registration_form.dart';
import 'file_viewer_logic.dart';
import 'file_viewer_screen_widget.dart';
import 'package:denik_zza/design_system/tokens/app_spacing.dart';
import 'package:denik_zza/design_system/tokens/app_breakpoints.dart';
import 'package:denik_zza/screens2/widgets/zza_scrollable.dart';

class IntakeMainContent extends StatefulWidget {
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
  State<IntakeMainContent> createState() => _IntakeMainContentState();
}

class _IntakeMainContentState extends State<IntakeMainContent> {
  final ScrollController _formScrollController = ScrollController();

  @override
  void dispose() {
    _formScrollController.dispose();
    super.dispose();
  }

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
            return CustomScrollView(
              slivers: [
                // SWAPPED: Form First (Requested via User Feedback)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: _buildLeftColumn(
                        context, constraints, isNarrow), // Form (Unbounded)
                  ),
                ),
                // Camera/Gallery Second
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: _buildRightColumn(
                        context, constraints, isNarrow), // Camera/Gallery
                  ),
                ),
              ],
            );
          }

          // Desktop/Tablet: Side-by-side
          // Use wideContentMaxWidth for the row
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                  maxWidth: AppBreakpoints.wideContentMaxWidth),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Left Column: Form
                  Expanded(
                    flex: 4,
                    child: _buildLeftColumn(context, constraints, isNarrow),
                  ),
                  const SizedBox(width: AppSpacing.xxl),
                  // Right Column: Camera/Gallery (Always fills remaining vertical space)
                  Expanded(
                    flex: 3,
                    child: _buildRightColumn(context, constraints, isNarrow),
                  ),
                ],
              ),
            ),
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
      return widget.participantRegistrationForm;
    }

    // If we have limited vertical space, we shouldn't force the form to "fill" the remaining space,
    // because it might be smaller than the form's minimum height (causing crash).
    final isCompact = AppBreakpoints.isCompactHeight(constraints.maxHeight);

    if (isCompact) {
      // < 600px: Wrap in ScrollView to handle overflow gracefully
      // Enhanced with ZzaScrollable for better visibility of scroll
      return ZzaScrollable(
        controller: _formScrollController,
        child: SingleChildScrollView(
          controller: _formScrollController,
          child: widget.participantRegistrationForm,
        ),
      );
    }

    // Default Desktop (> 600px): Return validation form directly.
    // This allows it to receive bounded height constraints from the Row -> Expanded chain,
    // enabling "Expanded" usage inside the form (e.g. for RestrictionsWidget).
    return widget.participantRegistrationForm;
  }

  Widget _buildRightColumn(
      BuildContext context, BoxConstraints parentConstraints, bool isNarrow) {
    final child = Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
    final hasFile = widget.zpusobilostFolder != null &&
        widget.selectedPerson?.potvrzeniPath != null &&
        widget.selectedPerson!.potvrzeniPath!.isNotEmpty;

    if (hasFile) {
      return FileViewerScreen(
          initialFilePath:
              '${widget.zpusobilostFolder!.path}/${widget.selectedPerson!.potvrzeniPath}');
    } else {
      return FileViewerLogic(onFileUploaded: widget.onFileUploaded);
    }
  }
}
