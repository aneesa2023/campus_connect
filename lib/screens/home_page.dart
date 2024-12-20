import 'package:campus_connect/screens/custom_drawer.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Campus Connect'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      drawer: CustomDrawer(), // Include the custom drawer here
      body: Center(
        child: Text(
          'Welcome to Campus Connect!',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Action for the floating button (e.g., Add a new trip)
        },
        backgroundColor: Colors.blue,
        child: Icon(Icons.add),
      ),
    );
  }
}
