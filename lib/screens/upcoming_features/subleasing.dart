import 'package:flutter/material.dart';

class SubleasingScreen extends StatelessWidget {
  SubleasingScreen({super.key});

  final List<Map<String, String>> subleases = [
    {
      "location": "Downtown",
      "price": "\$1200",
      "date": "Available from Feb 2025"
    },
    {
      "location": "Near Campus",
      "price": "\$950",
      "date": "Available from March 2025"
    },
    {
      "location": "City Center",
      "price": "\$1100",
      "date": "Available from April 2025"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Subleasing")),
      body: ListView.builder(
        itemCount: subleases.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(8),
            child: ListTile(
              leading: Icon(Icons.home, size: 40, color: Colors.blue),
              title: Text("Location: ${subleases[index]["location"]!}"),
              subtitle: Text(
                  "Price: ${subleases[index]["price"]!} | ${subleases[index]["date"]!}"),
              trailing: Icon(Icons.chat_bubble, color: Colors.blue),
            ),
          );
        },
      ),
    );
  }
}
