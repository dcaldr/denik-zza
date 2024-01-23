import 'package:flutter/material.dart';

class RecordDetailPage extends StatelessWidget {
  // Placeholder record data
  final String recordTitle = "Záznam 1";
  final String recordDate = "2022-03-01";
  final String recordTime = "14:30";
  final String recordDescription =
      "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer nec odio. Praesent libero. Sed cursus ante dapibus diam.";
  final String recordTreatment =
      "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer nec odio. Praesent libero. Sed cursus ante dapibus diam.";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Záznamu'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              // Navigate to another screen for editing record details
              // Replace `EditRecordPage` with your actual edit page
              // Navigator.push(context, MaterialPageRoute(builder: (context) => EditRecordPage()));
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 0),
            // Header with record title
            Text(
              recordTitle,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Divider(),
            SizedBox(height: 20),
            // Bubbles with record information
            // Bubble for the date
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 226, 226, 226),
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              margin: EdgeInsets.only(bottom: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Datum',
                    style: TextStyle(fontSize: 10, color: Colors.black),
                  ),
                  Text(
                    recordDate,
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                ],
              ),
            ),
            // Divider to separate date and time
            // Bubble for the time
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 226, 226, 226),
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              margin: EdgeInsets.only(bottom: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Čas',
                    style: TextStyle(fontSize: 10, color: Colors.black),
                  ),
                  Text(
                    recordTime,
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                ],
              ),
            ),
            Divider(),
            SizedBox(height: 20),
            // Description section
            Text(
              'Popis',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            // Text with record description
            Text(
              recordDescription,
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
            SizedBox(height: 20),
            // Divider to separate description and treatment
            Divider(),
            // Treatment section
            Text(
              'Léčba',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            // Text with record treatment
            Text(
              recordTreatment,
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
