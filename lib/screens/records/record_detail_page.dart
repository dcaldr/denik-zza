import 'package:flutter/material.dart';

/// Widget for displaying details of a record.
class RecordDetailPage extends StatelessWidget {
  // Placeholder record data
  final String recordTitle = "Záznam 1";
  final String recordDate = "2022-03-01";
  final String recordTime = "14:30";
  final String recordDescription =
      "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer nec odio. Praesent libero. Sed cursus ante dapibus diam.";
  final String recordTreatment =
      "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer nec odio. Praesent libero. Sed cursus ante dapibus diam.";

  const RecordDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Záznamu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to another screen for editing record details
              // Replace `EditRecordPage` with your actual edit page
              // Navigator.push(context, MaterialPageRoute(builder: (context) => EditRecordPage()));
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 0),
            // Header with record title
            Text(
              recordTitle,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            const SizedBox(height: 20),
            // Bubbles with record information
            // Bubble for the date
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 226, 226, 226),
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              margin: const EdgeInsets.only(bottom: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Datum',
                    style: TextStyle(fontSize: 10, color: Colors.black),
                  ),
                  Text(
                    recordDate,
                    style: const TextStyle(fontSize: 14, color: Colors.black),
                  ),
                ],
              ),
            ),
            // Divider to separate date and time
            // Bubble for the time
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 226, 226, 226),
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              margin: const EdgeInsets.only(bottom: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Čas',
                    style: TextStyle(fontSize: 10, color: Colors.black),
                  ),
                  Text(
                    recordTime,
                    style: const TextStyle(fontSize: 14, color: Colors.black),
                  ),
                ],
              ),
            ),
            const Divider(),
            const SizedBox(height: 20),
            // Description section
            const Text(
              'Popis',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            // Text with record description
            Text(
              recordDescription,
              style: const TextStyle(fontSize: 14, color: Colors.black),
            ),
            const SizedBox(height: 20),
            // Divider to separate description and treatment
            //Divider(),
            // Treatment section
            //Text(
            //  'Léčba',
            //  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            //),
            //SizedBox(height: 10),
            // Text with record treatment
            //Text(
            //  recordTreatment,
            //  style: TextStyle(fontSize: 14, color: Colors.black),
            //),
          ],
        ),
      ),
    );
  }
}
