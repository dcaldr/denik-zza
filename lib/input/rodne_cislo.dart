class RodneCislo {

  String _rc;
  bool hasValidFormat = false;
  bool hasValidSum = false;

  RodneCislo(this._rc) {
    _rc = formatRc(_rc);
    if (!_isValidFormat(_rc)) {
      hasValidFormat = false;
    } else {
      hasValidFormat = true;
    }
    hasValidSum = isValidSum();

  }

  String formatRc(String rcCandidate) {
  // Removes dashes, slashes, spaces, and all whitespace characters
  return rcCandidate.replaceAll(RegExp(r'[-/\s]'), '');
}

  bool _isValidFormat(String rc) {
    // Kontrola délky a toho, zda obsahuje pouze číslice (kromě případného lomítka)
    if (rc.length == 10 || (rc.length == 11 && rc[6] == '/')) {
     // String digits = rc.replaceAll('/', '');
      return RegExp(r'^\d{9,10}$').hasMatch(rc);
    }
    return false;
  }
  /// modus 11 - check
  bool isValidSum(){
    if (!_isValidFormat(_rc)) {
      return false;
    }

    int sum = int.parse(_rc);
    int modulo = sum % 11;

    return (modulo == 0) || (modulo == 1 && _rc.endsWith('0'));
  }

  int getPohlavi() {
    //int mesic = getHrubyMesic();
    if (getHrubyMesic() < 50) {
      return 1;
    } else {
      return 2;
    }
  }

  DateTime getDatumNarozeni() {
    int rok = getRok();
    int mesic = getHrubyMesic();
    int den = getDen();

    // Úprava měsíce pro ženy a alternativní čísla
    if (mesic > 50) {
      mesic -= 50;
    }
    if (mesic > 20) {
      mesic -= 20;
    }

    if (rok < 54) {
      rok += 2000;
    } else {
      rok += 1900;
    }

    return DateTime(rok, mesic, den);
  }

  int getDen() {
    int den = int.parse(_rc.substring(4, 6));
    return den;
  }

  int getHrubyMesic() {
    int mesic = int.parse(_rc.substring(2, 4));
    return mesic;
  }

  int getRok() {
    int rok = int.parse(_rc.substring(0, 2));
    return rok;
  }

  String getRc() {
  String outRc = _rc;
  if (!_rc.contains('/')) {
    outRc = '${_rc.substring(0, 6)}/${_rc.substring(6)}';
  };
  return outRc;
}

  @override
  String toString() {
    return getRc();
  }
}
