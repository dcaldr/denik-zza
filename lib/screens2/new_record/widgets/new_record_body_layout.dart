import 'package:flutter/material.dart';

import 'package:denik_zza/database/in_memory_structures_tmp/memory_lek.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_omezeni.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';
import 'package:denik_zza/design_system/tokens/app_spacing.dart';
import 'package:denik_zza/screens2/new_record/new_record_scroll_strategy.dart';
import 'package:denik_zza/screens2/new_record/widgets/new_record_form_fields.dart';
import 'package:denik_zza/screens2/new_record/widgets/new_record_health_info.dart';
import 'package:denik_zza/screens2/new_record/widgets/new_record_header_section.dart';
import 'package:denik_zza/screens2/new_record/widgets/new_record_history_section.dart';

class NewRecordBodyLayout extends StatelessWidget {
  final bool isCompact;
  final bool isNarrow;
  final double spacing;
  final NewRecordScrollMetrics scrollMetrics;
  final String participantSubtitle;
  final bool hasParticipant;
  final bool hasUnsavedChanges;
  final bool showBirthdateInfo;
  final bool isParticipantSelected;
  final List<MemoryOsoba> availableParticipants;
  final List<MemoryOmezeni> omezeniList;
  final List<MemoryLek> lekyList;
  final MemoryOsoba? selectedParticipant;
  final int recordCount;
  final int refreshCounter;
  final GlobalKey headerKey;
  final GlobalKey historyHeaderKey;
  final double historyHeaderHeight;
  final GlobalKey formContainerKey;
  final GlobalKey<FormState> formKey;
  final TextEditingController titleController;
  final TextEditingController temperatureController;
  final TextEditingController descriptionController;
  final TextEditingController poznamkaController;
  final String dateTimeLabel;
  final VoidCallback? onSelectDateTime;
  final bool showDateTimeReset;
  final VoidCallback? onResetDateTime;
  final VoidCallback? onPrintFull;
  final VoidCallback? onPrintAppend;
  final Widget? zpusobilostButton;
  final VoidCallback? onShowPoznamka;
  final FormFieldValidator<String>? titleValidator;
  final FormFieldValidator<String>? temperatureValidator;
  final FormFieldValidator<String>? descriptionValidator;
  final VoidCallback onRefresh;
  final ValueChanged<MemoryOsoba> onParticipantSelected;
  final ValueChanged<MemoryOsoba>? onParticipantTapped;
  final VoidCallback onBirthdateInfo;
  final ValueChanged<int> onRecordsLoaded;

  const NewRecordBodyLayout({
    super.key,
    required this.isCompact,
    required this.isNarrow,
    required this.spacing,
    required this.scrollMetrics,
    required this.participantSubtitle,
    required this.hasParticipant,
    required this.hasUnsavedChanges,
    required this.showBirthdateInfo,
    required this.isParticipantSelected,
    required this.availableParticipants,
    required this.omezeniList,
    required this.lekyList,
    required this.selectedParticipant,
    required this.recordCount,
    required this.refreshCounter,
    required this.headerKey,
    required this.historyHeaderKey,
    required this.historyHeaderHeight,
    required this.formContainerKey,
    required this.formKey,
    required this.titleController,
    required this.temperatureController,
    required this.descriptionController,
    required this.poznamkaController,
    required this.dateTimeLabel,
    required this.onSelectDateTime,
    required this.showDateTimeReset,
    required this.onResetDateTime,
    required this.onPrintFull,
    required this.onPrintAppend,
    required this.zpusobilostButton,
    required this.onShowPoznamka,
    required this.titleValidator,
    required this.temperatureValidator,
    required this.descriptionValidator,
    required this.onRefresh,
    required this.onParticipantSelected,
    this.onParticipantTapped,
    required this.onBirthdateInfo,
    required this.onRecordsLoaded,
  });

  @override
  Widget build(BuildContext context) {
    final formFields = NewRecordFormFields(
      isCompact: isCompact,
      isNarrow: isNarrow,
      isParticipantSelected: isParticipantSelected,
      titleController: titleController,
      temperatureController: temperatureController,
      descriptionController: descriptionController,
      poznamkaController: poznamkaController,
      dateTimeLabel: dateTimeLabel,
      onSelectDateTime: onSelectDateTime,
      showDateTimeReset: showDateTimeReset,
      onResetDateTime: onResetDateTime,
      onPrintFull: onPrintFull,
      onPrintAppend: onPrintAppend,
      zpusobilostButton: zpusobilostButton,
      onShowPoznamka: onShowPoznamka,
      titleValidator: titleValidator,
      temperatureValidator: temperatureValidator,
      descriptionValidator: descriptionValidator,
    );

    final formContent = scrollMetrics.shouldUsePageScroll
        ? formFields
        : SingleChildScrollView(child: formFields);

    final healthInfo = hasParticipant
        ? NewRecordHealthInfo(
            isCompact: isCompact,
            omezeniList: omezeniList,
            lekyList: lekyList,
          )
        : null;

    final headerSection = NewRecordHeaderSection(
      isCompact: isCompact,
      isNarrow: isNarrow,
      hasParticipant: hasParticipant,
      hasUnsavedChanges: hasUnsavedChanges,
      participantTitle: 'Účastník',
      participantSubtitle: participantSubtitle,
      showBirthdateInfo: showBirthdateInfo,
      onBirthdateInfo: onBirthdateInfo,
      healthInfo: healthInfo,
      availableParticipants: availableParticipants,
      onParticipantSelected: onParticipantSelected,
      selectedParticipant: selectedParticipant,
      onParticipantTapped: onParticipantTapped,
      onRefresh: onRefresh,
      headerKey: headerKey,
    );

    final historySection = NewRecordHistorySection(
      isCompact: isCompact,
      recordCount: recordCount,
      historyHeaderKey: historyHeaderKey,
      historyHeaderHeight: historyHeaderHeight,
      historyMaxHeight: scrollMetrics.shouldUsePageScroll
          ? scrollMetrics.historyHeightForScroll
          : scrollMetrics.maxHistoryHeight,
      selectedParticipant: selectedParticipant,
      refreshCounter: refreshCounter,
      onRecordsLoaded: onRecordsLoaded,
    );

    final historyBlock = scrollMetrics.shouldUsePageScroll
        ? SizedBox(
            height: scrollMetrics.historyHeightForScroll,
            child: historySection,
          )
        : Flexible(
            fit: FlexFit.loose,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: scrollMetrics.minHistoryHeight,
                maxHeight: scrollMetrics.maxHistoryHeight,
              ),
              child: historySection,
            ),
          );

    final formSection = SizedBox(
      key: formContainerKey,
      child: Opacity(
        opacity: hasParticipant ? 1.0 : 0.4,
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              formContent,
            ],
          ),
        ),
      ),
    );

    final bodyContent = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        headerSection,
        SizedBox(height: spacing),
        historyBlock,
        SizedBox(height: spacing),
        formSection,
      ],
    );

    return Padding(
      padding: AppSpacing.screenPadding,
      child: scrollMetrics.shouldUsePageScroll
          ? SingleChildScrollView(child: bodyContent)
          : bodyContent,
    );
  }
}
