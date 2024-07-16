
import 'package:denik_zza/input/input_parser.dart';
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
  /// TODO: Need? to move elsewhere
  group('comparing statuses', (){
    ParseStatus ok = ParseStatus.ok;
    ParseStatus format = ParseStatus.format;
    ParseStatus warn = ParseStatus.warn;
    ParseStatus bad = ParseStatus.bad;

    test('basic ordering', (){
      expect(ok.index, lessThan(warn.index));
      expect(ok.compareTo(warn), lessThan(0));
    });
    test('overridden operators', (){
      expect(format < bad, true);
      expect(ok > warn, false);
      expect(ok <= warn, true);
      expect(ok >= warn, false);
    });
    test('Implicit operators', (){
      expect(format == format, true);
      expect(format != bad, true);
    });
  });
  group('Date Parsing',(){
    test('basic IT style date parse',(){
      expect( TextTools.myParseDate('2020-01-02'), DateTime(2020, 01, 02));
    });
    test('basic CZ style date parse',(){
      expect( TextTools.myParseDate('10.06.2020'), DateTime(2020, 06, 10));
      expect( TextTools.myParseDate('10/06/2020'), DateTime(2020, 06, 10));
    });
  });
  }