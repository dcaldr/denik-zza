/// Czech national identification number (rodné číslo) validation and parsing class
/// 
/// Handles validation of Czech national ID format and checksum calculation
/// according to Czech Republic regulations
class RodneCislo {
  /// Tested national ID number
  String _rc;
  bool hasValidFormat = false;
  bool hasValidSum = false;

  /// Creates a new RodneCislo instance and validates the provided number
  /// 
  /// [_rc] - the national ID number to validate
  RodneCislo(this._rc) {
    _rc = formatRc(_rc);
    if (!_isValidFormat(_rc)) {
      hasValidFormat = false;
    } else {
      hasValidFormat = true;
    }
    hasValidSum = isValidSum();
  }

  /// Formats the national ID number by removing separators
  /// 
  /// Removes dashes, slashes, spaces, and all whitespace characters
  String formatRc(String rcCandidate) {
    return rcCandidate.replaceAll(RegExp(r'[-/\s]'), '');
  }

  /// Validates the format of the national ID number
  /// 
  /// Checks length and ensures it contains only digits
  bool _isValidFormat(String rc) {
    // Check length and that it contains only digits (except possible slash)
    if (rc.length == 10 || (rc.length == 11 && rc[6] == '/')) {
      return RegExp(r'^\d{9,10}$').hasMatch(rc);
    }
    return false;
  }
  /// Validates checksum using modulo 11 algorithm
  /// 
  /// Returns true if the checksum is valid according to Czech national ID rules
  bool isValidSum() {
    if (!_isValidFormat(_rc)) {
      return false;
    }

    int sum = int.parse(_rc);
    int modulo = sum % 11;

    return (modulo == 0) || (modulo == 1 && _rc.endsWith('0'));
  }

  /// Determines gender from the national ID number
  /// 
  /// Returns 1 for male, 2 for female based on month field
  int getPohlavi() {
    if (getHrubyMesic() < 50) {
      return 1; // Male
    } else {
      return 2; // Female
    }
  }

  /// Extracts birth date from the national ID number
  /// 
  /// Handles century determination and month adjustments for gender
  DateTime getDatumNarozeni() {
    int rok = getRok();
    int mesic = getHrubyMesic();
    int den = getDen();

    // Month adjustment for women and alternative numbers
    if (mesic > 50) {
      mesic -= 50;
    }
    if (mesic > 20) {
      mesic -= 20;
    }

    // Century determination
    if (rok < 54) {
      rok += 2000;
    } else {
      rok += 1900;
    }

    return DateTime(rok, mesic, den);
  }

  /// Extracts day from national ID number
  int getDen() {
    int den = int.parse(_rc.substring(4, 6));
    return den;
  }

  /// Extracts raw month value from national ID number (before gender adjustment)
  int getHrubyMesic() {
    int mesic = int.parse(_rc.substring(2, 4));
    return mesic;
  }

  /// Extracts year from national ID number
  int getRok() {
    int rok = int.parse(_rc.substring(0, 2));
    return rok;
  }
  /// Returns the national ID number in human-readable format (123456/7890)
  /// 
  /// Adds slash separator if not already present
  String getRc() {
    String outRc = _rc;
    if (!_rc.contains('/')) {
      outRc = '${_rc.substring(0, 6)}/${_rc.substring(6)}';
    }
    return outRc;
  }

  @override
  String toString() {
    return getRc();
  }
}
