import 'package:denik_zza/print_ops2/print_status_codes.dart';

String pluralSuffixCz(int count) {
  if (count == 1) return '';
  if (count >= 2 && count <= 4) return 'y';
  return 'ů';
}

OkCodes evaluateRecordSequence(List<bool> isPrintedFlags) {
  if (isPrintedFlags.isEmpty) {
    return OkCodes.unset;
  }

  var prevItem = isPrintedFlags.first;
  for (final current in isPrintedFlags) {
    if (current && !prevItem) {
      return OkCodes.broken;
    }
    prevItem = current;
  }

  return prevItem ? OkCodes.printed : OkCodes.unprinted;
}

bool canAppendPrint({
  required bool wasPrinted,
  required List<bool> isPrintedFlags,
}) {
  if (!wasPrinted) return false;
  if (isPrintedFlags.isEmpty) return false;

  final status = evaluateRecordSequence(isPrintedFlags);
  return status != OkCodes.broken;
}
