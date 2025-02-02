import 'package:flutter/material.dart';

class CommunityFeedScreen extends StatelessWidget {
  CommunityFeedScreen({super.key});

  final List<Map<String, String>> posts = [
    {
      "author": "Alice",
      "content": "Anyone knows a good place for groceries near campus?"
    },
    {
      "author": "Bob",
      "content": "Study group for CS101 this weekend, anyone interested?"
    },
    {
      "author": "Charlie",
      "content": "Lost my bike near the library, please let me know if found."
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Community Feed")),
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(8),
            child: ListTile(
              title: Text(posts[index]["author"]!,
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(posts[index]["content"]!),
            ),
          );
        },
      ),
    );
  }
}
