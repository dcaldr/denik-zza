import 'package:denik_zza/input/rodne_cislo.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  RodneCislo rodneCislo;
  RodneCislo rodneCisloFalse = RodneCislo('000101/0800');
  RodneCislo rodneCisloGood = RodneCislo('1404145039');
  RodneCislo zbytek10 = RodneCislo('840501/1330');
  RodneCislo rcZenaGood = RodneCislo('1454147013');
  group('RodneCislo modus', () {
    test('základní modus špatně', () {
      expect(rodneCisloFalse.isValidSum(), isFalse);
    });
    test('základní modus správně', () {
      expect(rodneCisloGood.isValidSum(), isTrue);
    });
    test('zbytek 10', () {
      expect(zbytek10.isValidSum(), isTrue);
    });

  });
  group("odhadování z RČ ",(){
    test('pohlaví',(){
      expect(rodneCisloGood.getPohlavi(), 1);
      expect(rcZenaGood.getPohlavi(), 2);
    });
    test('datum narození muž',(){
      expect(rodneCisloGood.getDatumNarozeni(), DateTime(2014, 04, 14));
    });
    test('datum narozeni žena',(){
      expect(rcZenaGood.getDatumNarozeni(), DateTime(2014, 04, 14));
    });
  });
  group("zbytek testů RČ",(){
    test("output rč s lomítkem",(){
      expect(rodneCisloGood.getRc(), "140414/5039");
    });
  });

}