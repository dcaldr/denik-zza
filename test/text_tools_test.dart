
import 'package:denik_zza/input/text_tools.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final TextTools textTools = TextTools();
  group('basic tests too see how build-in options work', () {
    //test(description, body)
    test('basic string trimming',() {
      expect('     hello    '.trim(), 'hello');
    });
    test('to lowercase',(){
      expect("HeLlO".toLowerCase(), 'hello');
    });
    test('to lowercase harder',(){
      expect('ĚŠČŘŽÝÁÍÉŮĎˇI'.toLowerCase(), 'ěščřžýáíéůďˇi');
    });



  });
  group('advanced text manipulation',(){
    test('my normalizer remove',(){
      expect(TextTools.normText('ěščřžýáíéúůďť'),'escrzyaieuudt');
      expect(TextTools.normText('ĚŠČŘŽÝÁÍÉÚŮĎŤ'),'escrzyaieuudt');
    });
    test('my normalizer with spaces', (){
      expect(TextTools.normText(' ěščřžýáíéúůďť '),'escrzyaieuudt');
      expect(TextTools.normText(' ĚŠČŘŽÝÁÍÉÚŮĎŤ '),'escrzyaieuudt');
      expect(TextTools.normText(' ĚŠČŘžýáíéÚŮĎŤ '),'escrzyaieuudt');
    });
  });
  }