import 'package:flutter_test/flutter_test.dart';
import 'package:denik_zza/print_ops2/print_utils.dart';
import 'package:denik_zza/print_ops2/print_status_codes.dart';

void main() {
  group('isRecordsOk – edge case patterns', () {
    test('[T] -> printed', () {
      expect(evaluateRecordSequence([true]), OkCodes.printed);
    });

    test('[F] -> unprinted', () {
      expect(evaluateRecordSequence([false]), OkCodes.unprinted);
    });

    test('[T, T, F] -> printed (contiguous prefix valid)', () {
      expect(evaluateRecordSequence([true, true, false]), OkCodes.printed);
    });

    test('[F, T, T] -> broken (unprinted before printed)', () {
      expect(evaluateRecordSequence([false, true, true]), OkCodes.broken);
    });

    test('[T, F, T] -> broken (gap in contiguous prefix)', () {
      expect(evaluateRecordSequence([true, false, true]), OkCodes.broken);
    });

    test('[T, T, T] -> printed', () {
      expect(evaluateRecordSequence([true, true, true]), OkCodes.printed);
    });

    test('[F, F, F] -> unprinted', () {
      expect(evaluateRecordSequence([false, false, false]), OkCodes.unprinted);
    });

    test('[] -> unset', () {
      expect(evaluateRecordSequence(const []), OkCodes.unset);
    });

    test('[T, F, F] -> printed (contiguous prefix of 1)', () {
      expect(evaluateRecordSequence([true, false, false]), OkCodes.printed);
    });
  });

  group('canAppend – combined person + records', () {
    test('wasPrinted=true, records=[T,T,F] -> canAppend=true', () {
      expect(
        canAppendPrint(wasPrinted: true, isPrintedFlags: [true, true, false]),
        true,
      );
    });

    test('wasPrinted=false, records=[T,T,F] -> canAppend=false', () {
      expect(
        canAppendPrint(wasPrinted: false, isPrintedFlags: [true, true, false]),
        false,
      );
    });

    test('wasPrinted=true, records=[F,F,F] -> canAppend=true', () {
      expect(
        canAppendPrint(wasPrinted: true, isPrintedFlags: [false, false, false]),
        true,
      );
    });

    test('wasPrinted=true, records=[F,T,T] -> canAppend=false', () {
      expect(
        canAppendPrint(wasPrinted: true, isPrintedFlags: [false, true, true]),
        false,
      );
    });

    test('wasPrinted=true, records=[] -> canAppend=false', () {
      expect(
        canAppendPrint(wasPrinted: true, isPrintedFlags: const []),
        false,
      );
    });
  });
}
