import 'package:flutter/material.dart';
class MoveOutSaleScreen extends StatelessWidget {
  final List<Map<String, String>> itemsForSale = [
    {"item": "Study Desk", "price": "\$50", "location": "Dorm A"},
    {"item": "Microwave", "price": "\$30", "location": "Off-Campus Apartment"},
    {"item": "Bicycle", "price": "\$100", "location": "Near Campus"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Move Out Sale")),
      body: ListView.builder(
        itemCount: itemsForSale.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(8),
            child: ListTile(
              leading: Icon(Icons.shopping_bag, size: 40, color: Colors.blue),
              title: Text(itemsForSale[index]["item"]!,
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                  "Price: ${itemsForSale[index]["price"]!} | Location: ${itemsForSale[index]["location"]!}"),
              trailing: Icon(Icons.chat_bubble, color: Colors.blue),
            ),
          );
        },
      ),
    );
  }
}