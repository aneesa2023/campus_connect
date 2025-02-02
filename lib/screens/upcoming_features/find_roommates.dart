import 'package:flutter/material.dart';

class FindRoommatesScreen extends StatelessWidget {
  FindRoommatesScreen({super.key});

  final List<Map<String, String>> roommates = [
    {
      "name": "John Doe",
      "gender": "Male",
      "budget": "\$500",
      "location": "Downtown"
    },
    {
      "name": "Jane Smith",
      "gender": "Female",
      "budget": "\$600",
      "location": "Near Campus"
    },
    {
      "name": "Sam Wilson",
      "gender": "Male",
      "budget": "\$550",
      "location": "City Center"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Find Roommates")),
      body: ListView.builder(
        itemCount: roommates.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(8),
            child: ListTile(
              leading: Icon(Icons.person, size: 40, color: Colors.blue),
              title: Text(roommates[index]["name"]!,
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                  "Budget: ${roommates[index]["budget"]!} | Location: ${roommates[index]["location"]!}"),
              trailing: Icon(Icons.chat_bubble, color: Colors.blue),
            ),
          );
        },
      ),
    );
  }
}
