import 'package:flutter/material.dart';

class PollsScreen extends StatelessWidget {
  PollsScreen({super.key});
  final List<Map<String, dynamic>> polls = [
    {
      "question": "Should we have more bike racks on campus?",
      "options": ["Yes", "No", "Maybe"]
    },
    {
      "question": "Best time for a study group?",
      "options": ["Morning", "Afternoon", "Evening"]
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Polls")),
      body: ListView.builder(
        itemCount: polls.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(polls[index]["question"]!,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                ...polls[index]["options"]
                    .map<Widget>((option) => RadioListTile(
                          title: Text(option),
                          value: option,
                          groupValue: null,
                          onChanged: (value) {},
                        ))
                    .toList(),
              ],
            ),
          );
        },
      ),
    );
  }
}
