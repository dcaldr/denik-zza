import 'package:flutter/material.dart';
import '../database/in_memory_structures_tmp/memory_zaznam.dart';
/// Quick view of zraneni of one person (?)
///
/// Could be foundation for other screens ie. list of old zraneni
class ZraneniListItem extends StatelessWidget {
  final MemoryZaznam zraneni;

  const ZraneniListItem(this.zraneni, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start, // Align everything to the left
        children: <Widget>[
          Flexible(
            fit: FlexFit.loose, // Make the column only take up as much space as it needs
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '${zraneni.casZaznamu?.day.toString().padLeft(2, '0')}.${zraneni.casZaznamu?.month.toString().padLeft(2, '0')}.${zraneni.casZaznamu?.year}',
                  style: const TextStyle(fontSize: 10.0),
                ),
                Text(
                  '${zraneni.casZaznamu?.hour.toString().padLeft(2, '0')}:${zraneni.casZaznamu?.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 13.0),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20), // No space between the two columns
          Flexible(
            fit: FlexFit.tight, // Make the column only take up as much space as it needs
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(zraneni.nazev ?? 'No title'),
                Text(zraneni.popis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}