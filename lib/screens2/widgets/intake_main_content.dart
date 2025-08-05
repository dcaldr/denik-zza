import 'dart:io';
import 'package:flutter/material.dart';
import '../../database/in_memory_structures_tmp/memory_osoba.dart';
import '../participant_registration_form.dart';
import 'file_viewer_logic.dart';
import 'file_viewer_screen_widget.dart';

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
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: _buildLeftColumn(),
          ),
          Expanded(
            child: _buildRightColumn(context),
          ),
        ],
      ),
    );
  }

  Widget _buildLeftColumn() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('First Column'),
        Transform.scale(
          scale: 0.85,
          child: participantRegistrationForm,
        ),
      ],
    );
  }

  Widget _buildRightColumn(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Second Column'),
        Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height / 1.6,
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
        initialFilePath: '${zpusobilostFolder!.path}/${selectedPerson!.potvrzeniPath}'
      );
    } else {
      return FileViewerLogic(onFileUploaded: onFileUploaded);
    }
  }
}
