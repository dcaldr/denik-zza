/// Tools for manipulating strings mainly for matching purposes
/// should extend existing options
library;
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
   static bool looseCmpWithList(String a, List<String> bList) {
     a = normText(a);
     for (String b in bList) {
       b = normText(b);
       if (a == b) {
         return true;
       }
     }
     return false;
   }
   static DateTime? parseDate(String date) {
     DateTime? parsedDate;
     try {
       parsedDate = DateTime.parse(date);
     } catch (e) {
       parsedDate = null;
     }
     if (parsedDate != null) {
       return myParseDate(date);
     }



     return null;
   }
   static myParseDate(String date){
     DateTime? parsedDate;
     // split text
     List<String> splitted= date.split(RegExp(r'[-/.\s]'));
      if(splitted.length != 3){
        return null;
      }
      // try to parse

     if(splitted[0].length == 4){
       //1) yyyy.mm.dd
       try {
         parsedDate = DateTime(int.parse(splitted[0]), int.parse(splitted[1]), int.parse(splitted[2]));
       } catch (e) {
         parsedDate = null;
       }
       if (parsedDate != null) {
         return parsedDate;
       }
     }

     //1) dd.mm.yyyy
      try {
        parsedDate = DateTime(int.parse(splitted[2]), int.parse(splitted[1]), int.parse(splitted[0]));
      } catch (e) {
        parsedDate = null;
      }
      if (parsedDate != null) {
        return parsedDate;
      }


   }




}