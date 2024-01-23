import 'package:flutter/material.dart';
import 'package:denik_zza/database/in_memory_structures_tmp/memory_osoba.dart';

class SingleOsobaSelector extends StatefulWidget {
  final Future<List<MemoryOsoba>> futureOsobyList;
  final ValueChanged<MemoryOsoba?> onOsobaSelected;

  const SingleOsobaSelector({required this.futureOsobyList, required this.onOsobaSelected, super.key});

  @override
  State<SingleOsobaSelector> createState() => _SingleOsobaSelectorState();
}

class _SingleOsobaSelectorState extends State<SingleOsobaSelector> {
  MemoryOsoba? selectedOsoba;

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
              return RadioListTile<MemoryOsoba>(
                value: snapshot.data![index],
                groupValue: selectedOsoba,
                onChanged: (MemoryOsoba? value) {
                  setState(() {
                    if (selectedOsoba == value) {
                      selectedOsoba = null;
                    } else {
                      selectedOsoba = value;
                    }
                  });
                  widget.onOsobaSelected(selectedOsoba);
                },
                title: Text(
                    '${snapshot.data![index].jmeno} ${snapshot.data![index].prijmeni}, ${snapshot.data![index].datumNarozeni?.day.toString().padLeft(2, '0')}.${snapshot.data![index].datumNarozeni?.month.toString().padLeft(2, '0')}.${snapshot.data![index].datumNarozeni?.year}' //TODO: improve as mentioned in pdf.dart //DT1
                ),
              );
            },
          );
        }
      },
    );
  }
}

Future<MemoryOsoba?> showSingleOsobaDialog(
    BuildContext context, Future<List<MemoryOsoba>> futureOsobyList) async {
  MemoryOsoba? selectedOsoba;

  final result = await showDialog<MemoryOsoba>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Vyberte osobu'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleOsobaSelector(
            futureOsobyList: futureOsobyList,
            onOsobaSelected: (MemoryOsoba? osoba) {
              selectedOsoba = osoba;
            },
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Vrátit se'),
            onPressed: () {
              Navigator.of(context).pop(null);
            },
          ),
          TextButton(
            child: const Text('poslat tisknout'),
            onPressed: () {
              Navigator.of(context).pop(selectedOsoba);
            },
          ),
        ],
      );
    },
  );

  return result;
}