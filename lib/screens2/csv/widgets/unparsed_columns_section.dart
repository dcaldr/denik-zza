import 'package:flutter/material.dart';

/// Expansion tile that lists columns from the CSV that were not mapped.
class UnparsedColumnsSection extends StatelessWidget {
  const UnparsedColumnsSection({
    super.key,
    required this.unparsedColumns,
  });

  final List<String> unparsedColumns;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: ExpansionTile(
          key: const Key('CsvReviewScreen_unparsed_columns_tile'),
          title: const Text('Nerozpoznané sloupce'),
          children: unparsedColumns.isEmpty
              ? const <Widget>[
                  ListTile(
                    key: Key('CsvReviewScreen_unparsed_columns_empty'),
                    title: Text('Žádné nerozpoznané sloupce'),
                  ),
                ]
              : <Widget>[
                  for (int i = 0; i < unparsedColumns.length; i++)
                    ListTile(
                      key: Key('CsvReviewScreen_unparsed_column_$i'),
                      leading: const Icon(Icons.info_outline),
                      title: Text(unparsedColumns[i]),
                    ),
                ],
        ),
      ),
    );
  }
}
