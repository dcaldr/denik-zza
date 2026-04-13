// print_status_codes.dart import removed

String pluralSuffixCz(int count) {
  if (count == 1) return '';
  if (count >= 2 && count <= 4) return 'y';
  return 'ů';
}

/// Checks if the sequence of printed flags is valid (monotonic).
/// Valid: [T, T, F, F]
/// Invalid: [T, F, T] (Gap)
bool isSequenceValid(List<bool> isPrintedFlags) {
  if (isPrintedFlags.isEmpty) return true;

  var prevItem = isPrintedFlags.first;
  for (final current in isPrintedFlags) {
    if (current && !prevItem) {
      // Found a True after a False -> Gap detected
      return false;
    }
    prevItem = current;
  }
  return true;
}

bool canAppendPrint({
  required bool wasPrinted,
  required List<bool> isPrintedFlags,
}) {
  if (!wasPrinted) return false;
  if (isPrintedFlags.isEmpty) return false;

  final hasUnprintedRecords = isPrintedFlags.any((flag) => !flag);
  if (!hasUnprintedRecords) return false;

  return isSequenceValid(isPrintedFlags);
}
