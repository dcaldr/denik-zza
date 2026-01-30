import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'package:denik_zza/design_system/tokens/app_breakpoints.dart';
import 'package:denik_zza/design_system/tokens/app_new_record_layout.dart';

class NewRecordScrollMetrics {
  final bool shouldUsePageScroll;
  final double minHistoryHeight;
  final double maxHistoryHeight;
  final double historyHeightForScroll;
  final double availableHeightForHistory;
  final bool fitsWithoutPageScroll;

  const NewRecordScrollMetrics({
    required this.shouldUsePageScroll,
    required this.minHistoryHeight,
    required this.maxHistoryHeight,
    required this.historyHeightForScroll,
    required this.availableHeightForHistory,
    required this.fitsWithoutPageScroll,
  });
}

class NewRecordScrollStrategy {
  static NewRecordScrollMetrics compute({
    required BuildContext context,
    required BoxConstraints constraints,
    required double spacing,
    required double historyHeaderHeight,
    required int recordCount,
    required double? headerHeight,
    required double? formHeight,
    required bool isNarrow,
    required bool isCompactHeight,
  }) {
    final minHistoryListHeight = AppBreakpoints.getListHeight(
      context,
      itemCount: 1,
      peekRatio: NewRecordLayoutConfig.historyPeekRatio,
      dense: true,
    );
    final minHistoryHeight = historyHeaderHeight + minHistoryListHeight;

    final recordCountForHeight = math.max(recordCount, 1);
    final fullListHeight = AppBreakpoints.getListHeight(
      context,
      itemCount: recordCountForHeight,
      peekRatio: 0.0,
      dense: true,
    );
    final fullHistoryHeight = historyHeaderHeight + fullListHeight;

      final maxItemsWhenScroll = _resolveMaxItemsWhenScroll(constraints);

    final maxListHeightWhenScroll = AppBreakpoints.getListHeight(
      context,
      itemCount: maxItemsWhenScroll,
      peekRatio: 0.0,
      dense: true,
    );
    final maxHistoryHeightWhenScroll =
        historyHeaderHeight + maxListHeightWhenScroll;

    final availableHeightForHistory = constraints.maxHeight -
        (headerHeight ?? 0) -
        (formHeight ?? 0) -
        (spacing * 2);

    final hasMeasuredHeights = headerHeight != null && formHeight != null;

    final effectiveAvailableHeight = hasMeasuredHeights
        ? (availableHeightForHistory.isFinite
            ? availableHeightForHistory
            : fullListHeight)
        : maxListHeightWhenScroll;

    final fitsWithoutPageScroll = fullHistoryHeight <= effectiveAvailableHeight;

    final targetHistoryMaxHeight = fitsWithoutPageScroll
        ? fullHistoryHeight
        : maxHistoryHeightWhenScroll;

    final cappedMaxHeight = effectiveAvailableHeight.isFinite
        ? math.min(targetHistoryMaxHeight, effectiveAvailableHeight)
        : targetHistoryMaxHeight;

    final historyMaxHeight = math.max(minHistoryHeight, cappedMaxHeight);

    final requiredMinHeight = (headerHeight ?? 0) +
        (formHeight ?? 0) +
        minHistoryHeight +
        (spacing * 2);

    final shouldUsePageScroll =
      (hasMeasuredHeights && requiredMinHeight > constraints.maxHeight) ||
        isNarrow ||
        isCompactHeight;

    final historyHeightForScroll = math.max(
      minHistoryHeight,
      math.min(fullHistoryHeight, maxHistoryHeightWhenScroll),
    );

    return NewRecordScrollMetrics(
      shouldUsePageScroll: shouldUsePageScroll,
      minHistoryHeight: minHistoryHeight,
      maxHistoryHeight: historyMaxHeight,
      historyHeightForScroll: historyHeightForScroll,
      availableHeightForHistory: availableHeightForHistory,
      fitsWithoutPageScroll: fitsWithoutPageScroll,
    );
  }

  static int _resolveMaxItemsWhenScroll(BoxConstraints constraints) {
    final tightThreshold = AppBreakpoints.compactHeight *
        NewRecordLayoutConfig.compactHeightTightFactor;
    final mediumThreshold = AppBreakpoints.compactHeight *
        NewRecordLayoutConfig.compactHeightMediumFactor;

    if (constraints.maxHeight <= tightThreshold) {
      return NewRecordLayoutConfig.maxHistoryItemsTight;
    }
    if (constraints.maxHeight <= mediumThreshold) {
      return NewRecordLayoutConfig.maxHistoryItemsMedium;
    }
    return NewRecordLayoutConfig.maxHistoryItemsDefault;
  }
}
