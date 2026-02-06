/// Result of previewing what a print-flag toggle would do.
///
/// Used by [PrintStateController] to show the user what will happen
/// before they confirm a toggle action (e.g., cascade effects).
class ToggleImpact {
  /// How many additional records will be affected by cascade.
  final int affectedRecordCount;

  /// IDs of records that will be cascaded (excluding the toggled record itself).
  final List<int> affectedRecordIds;

  /// Whether append mode will still be possible after this toggle.
  final bool appendStillPossible;

  /// Whether this toggle effectively requires a full reprint
  /// (e.g., toggling person wasPrinted to false).
  final bool requiresFullReprint;

  const ToggleImpact({
    required this.affectedRecordCount,
    required this.affectedRecordIds,
    required this.appendStillPossible,
    required this.requiresFullReprint,
  });

  /// No cascade, no side effects.
  const ToggleImpact.none()
      : affectedRecordCount = 0,
        affectedRecordIds = const [],
        appendStillPossible = true,
        requiresFullReprint = false;

  /// Whether this toggle has cascade side effects.
  bool get hasCascade => affectedRecordCount > 0;
}
