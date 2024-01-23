import 'package:flutter/material.dart';
import 'package:denik_zza/print_ops/printer_woodoo.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';

class OsobyListView extends StatefulWidget {

  const OsobyListView({super.key});

  @override
  State<OsobyListView> createState() => _OsobyListViewState();
}

class _OsobyListViewState extends State<OsobyListView> {
  final PrinterWoodoo printer = PrinterWoodoo();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MemoryOsoba>>(
      future: printer.getOsobyForPrint(),
      builder:
          (BuildContext context, AsyncSnapshot<List<MemoryOsoba>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(); // Show a loading spinner while waiting
        } else if (snapshot.hasError) {
          return Text(
              'Error: ${snapshot.error}'); // Show error if something went wrong
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return CheckboxListTile(
                value: snapshot
                    .data![index].wasPrinted, // Replace with actual property
                onChanged: (bool? value) {
                  setState(() {

                  });
                },
                title: Text(
                    '${snapshot.data![index].jmeno} ${snapshot.data![index].prijmeni}, ${snapshot.data![index].datumNarozeni?.day.toString().padLeft(2, '0')}.${snapshot.data![index].datumNarozeni?.month.toString().padLeft(2, '0')}.${snapshot.data![index].datumNarozeni?.year}'),
              );
              // Add more properties of MemoryOsoba as needed
            },
          );
        }
      },
    );
  }
}

void showOsobyDialog(BuildContext context) async {
  List<MemoryOsoba> selectedOsoby = [];

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: SizedBox(
          width: double.maxFinite,
          child: OsobyListView(
            onOsobaSelected: (osoba, isSelected) {
              if (isSelected) {
                selectedOsoby.add(osoba);
              } else {
                selectedOsoby.remove(osoba);
              }
            },
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Return'),
            onPressed: () {
              Navigator.of(context).pop(selectedOsoby);
            },
          ),
        ],
      );
    },
  );
}
