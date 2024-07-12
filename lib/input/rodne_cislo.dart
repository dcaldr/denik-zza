class RodneCislo {
  String rc;
  bool valid = false;

  RodneCislo(this.rc) {
    rc = formatRc(rc);
    if (!_isValidFormat(rc)) {
      valid = false;
    } else {
      valid = true;
    }
    if (!rc.contains('/')) {
      rc = '${rc.substring(0, 6)}/${rc.substring(6, 10)}';
    }
  }

  String formatRc(String rcCandidate) {
  // Removes dashes, slashes, spaces, and all whitespace characters
  return rcCandidate.replaceAll(RegExp(r'[-/\s]'), '');
}

  bool _isValidFormat(String rc) {
    // Kontrola délky a toho, zda obsahuje pouze číslice (kromě případného lomítka)
    if (rc.length == 10 || (rc.length == 11 && rc[6] == '/')) {
      String digits = rc.replaceAll('/', '');
      return RegExp(r'^\d{9,10}$').hasMatch(digits);
    }
    return false;
  }

  int getPohlavi() {
    int mesic = getHrubyMesic();
    if (mesic < 50) {
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
    int den = int.parse(rc.substring(4, 6));
    return den;
  }

  int getHrubyMesic() {
    int mesic = int.parse(rc.substring(2, 4));
    return mesic;
  }

  int getRok() {
    int rok = int.parse(rc.substring(0, 2));
    return rok;
  }
}
