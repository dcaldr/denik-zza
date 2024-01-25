import 'dart:typed_data';

import 'package:denik_zza/database/database_wrapper.dart';
import 'package:denik_zza/print_ops/printer_woodoo.dart';
import 'package:denik_zza/print_ops/select_person_to_append.dart';
import 'package:denik_zza/print_ops/select_person_to_print.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../database/database_interface.dart';
import '../database/in_memory_structures_tmp/memory_osoba.dart';
import '../database/in_memory_structures_tmp/memory_zaznam.dart';
import 'dev_pdf_view.dart';
/// Should ask user how the printing went
///
/// realy this brings a lot of dilemma return widget or what
class ConfirmPrint {
  DatabaseInterface db = DatabaseWrapper.getDatabase();
  Future<void> showConfirmPrintDialog(BuildContext context, PrintPack printPack) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Stav Tisknutí'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Jak dopadlo Tisknutí?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Vše v pořádku'),
              onPressed: () {
                    forAllSendResult(printPack.osoby, true);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Chci zopakovat tisk'),
              onPressed: () {
                //print('User wants to redo the printing');
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Nechci tisknout'),
              onPressed: () { //TODO: add confirm?
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pokud si to rozmyslíte, můžete zadat tisk znovu'),
                  ),
                );
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Tisk se nepovedl'),
              onPressed: () {
                forAllSendResult(printPack.osoby, false);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Osoby jsou označené jako netištěné '),
                  ),
                );
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  /// marks [MemoryOsoby] as printed-notPrinted
  Future<bool> forAllSendResult(List<MemoryOsoba> osoby, bool isPrinted) async {
    for (var item in osoby) {
      List<MemoryZaznam> zaznamy = await db.getRecordsByParticipantID(item.id);
      db.setParticipantPrintedValue(item.id, isPrinted);
      /// for [isPrinted] this is overkill but i cannot be bothered now //Todo: maybe optimize
      for(var zaznam in zaznamy){
        db.setRecordPrintedValue(zaznam.idZaznamu, isPrinted);
      }
    }
    return true;
  }

}