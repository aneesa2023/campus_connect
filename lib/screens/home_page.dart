import 'package:campus_connect/screens/custom_drawer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<bool> _isUserRegistered() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isDriverRegistered') ?? false;
  }

  Future<void> _setUserRegistered() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDriverRegistered', true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Connect'),
        centerTitle: true,
        backgroundColor: Colors.brown,
      ),
      drawer: const CustomDrawer(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Post a Ride Button
            ElevatedButton(
              onPressed: () async {
                final isRegistered = await _isUserRegistered();

                if (!context.mounted) return;

                if (isRegistered) {
                  // Navigate directly to Post a Ride page
                  Navigator.pushNamed(context, '/postRide');
                } else {
                  // Navigate to Register Driver page
                  final result =
                      await Navigator.pushNamed(context, '/registerDriver');

                  if (!context.mounted) return;

                  if (result != null) {
                    if (kDebugMode) {
                      print(result);
                    } // Example: {'licenseNumber': '1234', ...}
                    await _setUserRegistered();

                    if (!context.mounted) {
                      return;
                    }

                    Navigator.pushNamed(context, '/postRide');
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.brown,
                minimumSize: const Size(200, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Post a Ride'),
            ),

            const SizedBox(height: 20),
            // Search for a Ride Button
            OutlinedButton(
              onPressed: () {
                // Navigate to the Search for a Ride page
                Navigator.pushNamed(context, '/searchRide');
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black,
                minimumSize: const Size(200, 50),
                side: const BorderSide(color: Colors.black),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Search for a Ride'),
            ),
          ],
        ),
      ),
    );
  }
}
