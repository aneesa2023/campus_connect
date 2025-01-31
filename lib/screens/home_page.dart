import 'package:campus_connect/screens/custom_drawer.dart';
import 'package:campus_connect/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  String? userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  /// Fetch User ID from Secure Storage
  Future<void> _loadUserId() async {
    String? storedUserId = await AuthService.getUserId();
    if (mounted) {
      setState(() {
        userId = storedUserId ?? 'Unknown';
        print("User ID: ${userId!}");
      });
    }
  }

  /// Check if the user is registered as a driver
  Future<bool> _isUserRegistered() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isDriverRegistered') ?? false;
  }

  /// Mark the user as registered
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
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService.logout();
              if (!mounted) return;
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      drawer: const CustomDrawer(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display User ID
            userId == null
                ? const CircularProgressIndicator()
                : Column(
                    children: [
                      // const Text(
                      //   "Logged in as:",
                      //   style: TextStyle(
                      //       fontSize: 16, fontWeight: FontWeight.bold),
                      // ),
                      // Text(
                      //   userId!,
                      //   style: const TextStyle(
                      //       fontSize: 18,
                      //       color: Colors.brown,
                      //       fontWeight: FontWeight.bold),
                      // ),
                      // const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          bool isRegistered = await _isUserRegistered();

                          if (isRegistered) {
                            // Navigate directly to Post a Ride page
                            Navigator.pushNamed(context, '/postRide');
                          } else {
                            // Navigate to Register Driver page
                            final result = await Navigator.pushNamed(
                                context, '/registerDriver');
                            if (result != null) {
                              print(
                                  result); // Example: {'licenseNumber': '1234', ...}
                              await _setUserRegistered();
                              Navigator.pushNamed(context, '/postRide');
                            }
                          }
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
          ],
        ),
      ),
    );
  }
}
