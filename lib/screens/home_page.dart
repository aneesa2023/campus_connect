import 'package:campus_connect/screens/custom_drawer.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Campus Connect'),
        centerTitle: true,
        backgroundColor: Colors.brown,
      ),
      drawer: CustomDrawer(), // Include the custom drawer here
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Post a Ride Button
            ElevatedButton(
              onPressed: () {
                // Navigate to the Post a Ride page
                Navigator.pushNamed(context, '/postRide');
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.brown, // White text
                minimumSize: Size(200, 50), // Button size
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text('Post a Ride'),
            ),
            SizedBox(height: 20), // Spacing between the buttons
            // Search for a Ride Button
            OutlinedButton(
              onPressed: () {
                // Navigate to the Search for a Ride page
                Navigator.pushNamed(context, '/searchRide');
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black,
                minimumSize: Size(200, 50), // Button size
                side: BorderSide(color: Colors.black), // Black border
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text('Search for a Ride'),
            ),
          ],
        ),
      ),
    );
  }
}
