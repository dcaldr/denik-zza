import 'package:flutter/material.dart';
import 'package:denik_zza/print_ops/printer_woodoo.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';

/// Widget for displaying a list of people with checkboxes.
class OsobyListView extends StatefulWidget {
  final Future<List<MemoryOsoba>> futureOsobyList;

  const OsobyListView({required this.futureOsobyList, super.key});

  @override
  State<OsobyListView> createState() => _OsobyListViewState();
}

class _OsobyListViewState extends State<OsobyListView> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MemoryOsoba>>(
      future: widget.futureOsobyList,
      builder: (BuildContext context, AsyncSnapshot<List<MemoryOsoba>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              bool checkboxValue = snapshot.data![index].wasPrinted ?? false;

              return CheckboxListTile(
                value: !checkboxValue,
                onChanged: (bool? value) {
                  setState(() {
                    snapshot.data![index].wasPrinted = !value!;
                  });
                },
                title: Text(
                  '${snapshot.data![index].jmeno} ${snapshot.data![index].prijmeni}, ${snapshot.data![index].datumNarozeni?.day.toString().padLeft(2, '0')}.${snapshot.data![index].datumNarozeni?.month.toString().padLeft(2, '0')}.${snapshot.data![index].datumNarozeni?.year}',
                ),
              );
            },
          );
        }
      },
    );
  }
}

/// Shows a dialog for selecting people for printing.
Future<List<MemoryOsoba>> showOsobyDialog(
    BuildContext context, Future<List<MemoryOsoba>> futureOsobyList) async {
  List<MemoryOsoba> emptyList = [];

  final result = await showDialog<List<MemoryOsoba>>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Vyberte osoby k tisku'),
        content: SizedBox(
          width: double.maxFinite,
          child: OsobyListView(futureOsobyList: futureOsobyList),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Vrátit se'),
            onPressed: () {
              Navigator.of(context).pop(emptyList);
            },
          ),
          TextButton(
            child: const Text('Potvrdit'),
            onPressed: () async {
              Navigator.of(context).pop(await futureOsobyList);
            },
          ),
        ],
      );
    },
  );

  return result ?? emptyList;
}
