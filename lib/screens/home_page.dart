import 'package:campus_connect/screens/custom_drawer.dart';
import 'package:campus_connect/services/auth_service.dart';
import 'package:campus_connect/services/api_service.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  String? userId;
  bool? isDriverRegistered;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  /// Fetch User ID & Driver Status
  Future<void> _loadUserDetails() async {
    String? storedUserId = await AuthService.getUserId();
    if (storedUserId != null) {
      _fetchDriverStatus(storedUserId);
    } else {
      setState(() {
        userId = 'Unknown';
        isLoading = false;
      });
    }
  }

  /// Fetch `is_driver` from API
  Future<void> _fetchDriverStatus(String userId) async {
    try {
      final response = await ApiService.getRequest(
        module: 'user',
        endpoint: 'user/$userId',
      );

      bool isDriver = response['is_driver'] ?? false;

      setState(() {
        this.userId = userId;
        isDriverRegistered = isDriver;
        isLoading = false;
      });

      print("User ID: $userId | is_driver: $isDriver");
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching user data: $e");
    }
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
        child: isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      if (isDriverRegistered == true) {
                        Navigator.pushNamed(context, '/postRide');
                      } else {
                        final result = await Navigator.pushNamed(
                            context, '/registerDriver');

                        if (result != null) {
                          _loadUserDetails();
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
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/searchRide');
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      minimumSize: const Size(200, 50),
                      side: const BorderSide(color: Colors.brown),
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
