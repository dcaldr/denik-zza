

import 'package:denik_zza/input/input_hold.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';

var logger = Logger(
  printer: PrettyPrinter(),
);

var loggerNoStack = Logger(
  printer: PrettyPrinter(methodCount: 0),
);


void main() {
  group('Input parsers basic tests',(){
    test('DatumNarozeni  IT style date',(){
      DatumNarozeniHold datumNarozeniHold = DatumNarozeniHold();
      expect(datumNarozeniHold.columnName, 'datum narození');
      datumNarozeniHold.addInput('2020-01-02');
      expect(datumNarozeniHold.getOutput(), DateTime(2020, 01, 02));
      expect(datumNarozeniHold.getOutput().runtimeType, DateTime);
    });
    test('DatumNarozeni czech style date',(){
      DatumNarozeniHold datumNarozeniHold = DatumNarozeniHold();
      expect(datumNarozeniHold.columnName, 'datum narození');
      datumNarozeniHold.addInput('01.02.2020');
      expect(datumNarozeniHold.getOutput(), DateTime(2020, 02, 01));
      expect(datumNarozeniHold.getOutput().runtimeType, DateTime);
    });
  });
}
