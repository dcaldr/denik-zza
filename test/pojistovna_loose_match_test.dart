import 'package:denik_zza/input/input_hold.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PojistovnaHold loose match', () {
    test('Matches common names and returns canonical code', () {
      expect(PojistovnaHold.full('OZP').getOutput(), 'ozp');
      expect(PojistovnaHold.full('207').getOutput(), 'ozp');
      expect(PojistovnaHold.full('Oborová zdravotní pojišťovna').getOutput(), 'ozp');

      expect(PojistovnaHold.full('VZP').getOutput(), 'vzp');
      expect(PojistovnaHold.full('111').getOutput(), 'vzp');
      expect(PojistovnaHold.full('Všeobecná zdravotní pojišťovna').getOutput(), 'vzp');

      expect(PojistovnaHold.full('ZPMV').getOutput(), 'zpmv');
      expect(PojistovnaHold.full('211').getOutput(), 'zpmv');

      // Unknown passes through as-is, but OK
      final unknown = PojistovnaHold.full('abc');
      expect(unknown.getOutput(), 'abc');
    });

    test('Empty input returns null and OK', () {
      final empty = PojistovnaHold.full('');
      expect(empty.getOutput(), null);
    });
  });
}
