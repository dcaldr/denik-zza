/// Tools for manipulating strings mainly for matching purposes
/// should extend existing options
import 'package:diacritic/diacritic.dart';
class TextTools{
/// creates "normalized" version of text
   static String normText(String inText){
    inText = inText.toLowerCase().trim(); //TODO: consider removing all whitespace
    inText= removeDiacritics(inText);


    return inText;
  }
  /// return True if two strings are similar
   ///
  static bool looseCmp(String a, String b){
     a = normText(a);
     b = normText(b);
     return a == b;
  }


}