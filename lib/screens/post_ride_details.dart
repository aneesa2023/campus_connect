import 'package:flutter/material.dart';
import 'package:campus_connect/services/api_service.dart';
import 'package:campus_connect/services/auth_service.dart';

class PostRideDetails extends StatefulWidget {
  final String fromLocation;
  final double fromLat;
  final double fromLong;
  final String toLocation;
  final double toLat;
  final double toLong;
  final String departureTime;

  const PostRideDetails({
    super.key,
    required this.fromLocation,
    required this.fromLat,
    required this.fromLong,
    required this.toLocation,
    required this.toLat,
    required this.toLong,
    required this.departureTime,
  });

  @override
  PostRideDetailsState createState() => PostRideDetailsState();
}

class PostRideDetailsState extends State<PostRideDetails> {
  final TextEditingController _totalSeatsController = TextEditingController();
  final TextEditingController _availableSeatsController =
      TextEditingController();
  final TextEditingController _noteToRidersController = TextEditingController();
  final TextEditingController _vehicleModelController = TextEditingController();
  final TextEditingController _vehicleLicenseController =
      TextEditingController();

  String? _selectedVehicle;
  List<Map<String, String>> _savedVehicles = [];
  bool _isLoading = true;
  bool _isAddingVehicle = false;

  final List<String> _multiSelectOptions = [
    'Pet Friendly',
    'Trunk Space',
    'Air Conditioning',
    'Wheelchair Accessible'
  ];
  final Map<String, bool> _selectedOptions = {
    'pet_friendly': false,
    'trunk_space': false,
    'air_conditioning': false,
    'wheelchair_access': false
  };

  @override
  void initState() {
    super.initState();
    _fetchSavedVehicles();
  }

  /// Fetch Saved Vehicles from API
  Future<void> _fetchSavedVehicles() async {
    setState(() => _isLoading = true);
    try {
      String? userId = await AuthService.getUserId();
      if (userId == null) throw Exception("User ID not found");

      final vehicleResponse = await ApiService.getRequest(
        module: 'cars',
        endpoint: 'users/$userId/cars',
      );

      List<Map<String, String>> vehiclesList = [];

      if (vehicleResponse is Map<String, dynamic> &&
          vehicleResponse.containsKey('cars') &&
          vehicleResponse['cars'] is List) {
        vehiclesList = List<Map<String, String>>.from(
          vehicleResponse['cars'].map((car) => {
                'model': car['car_model']?.toString() ?? '',
                'license': car['license_number']?.toString() ?? '',
                'car_id': car['car_id']?.toString() ?? '',
              }),
        );
      }

      setState(() {
        _savedVehicles = vehiclesList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print("Error fetching vehicles: $e");
    }
  }

  /// Add New Vehicle to API
  Future<void> _addVehicle() async {
    if (_vehicleModelController.text.isEmpty ||
        _vehicleLicenseController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all Vehicle details'),
        ),
      );
      return;
    }

    try {
      String? userId = await AuthService.getUserId();
      if (userId == null) return;

      final newVehicle = {
        "car_model": _vehicleModelController.text,
        "license_number": _vehicleLicenseController.text,
      };

      final response = await ApiService.postRequest(
        module: 'cars',
        endpoint: 'users/$userId/cars',
        body: newVehicle,
      );

      if (response.containsKey('car_id')) {
        await _fetchSavedVehicles();
        _vehicleModelController.clear();
        _vehicleLicenseController.clear();
        setState(() => _isAddingVehicle = false);
      }
    } catch (e) {
      print("Error adding vehicle: $e");
    }
  }

  /// Submit Ride to API
  Future<void> _submitRide() async {
    if (_selectedVehicle == null ||
        _totalSeatsController.text.isEmpty ||
        _availableSeatsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all required fields"),
        ),
      );
      return;
    }

    try {
      String? userId = await AuthService.getUserId();
      if (userId == null) throw Exception("User ID not found");

      final rideData = {
        "user_id": userId,
        "car_id": _selectedVehicle,
        "from_location": widget.fromLocation,
        "from_lat": widget.fromLat,
        "from_long": widget.fromLong,
        "to_location": widget.toLocation,
        "to_lat": widget.toLat,
        "to_long": widget.toLong,
        "total_seats": int.tryParse(_totalSeatsController.text) ?? 1,
        "available_seats": int.tryParse(_availableSeatsController.text) ?? 1,
        "departure_time": widget.departureTime,
        "pet_friendly": _selectedOptions['pet_friendly'].toString(),
        "trunk_space": _selectedOptions['trunk_space'].toString(),
        "air_conditioning": _selectedOptions['air_conditioning'].toString(),
        "wheelchair_access": _selectedOptions['wheelchair_access'].toString(),
        "note": _noteToRidersController.text,
        "ride_status": "scheduled",
        "created_at": DateTime.now().toIso8601String(),
      };

      await ApiService.postRequest(
        module: 'post_ride',
        endpoint: '/rides/create',
        body: rideData,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Ride posted successfully!"),
        ),
      );

      Navigator.pushNamed(context, '/home');
    } catch (e) {
      print("Error posting ride: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to post ride: ${e.toString()}"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post a Ride'),
        backgroundColor: Colors.brown,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Select Vehicle
                    DropdownButtonFormField<String>(
                      value: _selectedVehicle,
                      hint: const Text("Select Saved Vehicle"),
                      isExpanded: true,
                      items: _savedVehicles.map((vehicle) {
                        return DropdownMenuItem(
                          value: vehicle['car_id'],
                          child: Text(
                              "${vehicle['model']} (${vehicle['license']})"),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedVehicle = value;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: "Select Vehicle",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),

                    ElevatedButton(
                      onPressed: () {
                        setState(() => _isAddingVehicle = !_isAddingVehicle);
                      },
                      child: Text(
                        _isAddingVehicle ? "Cancel" : "Add New Vehicle",
                        style: TextStyle(color: Colors.brown),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (_isAddingVehicle)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Add new vehicle',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14),
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                TextField(
                                  controller: _vehicleModelController,
                                  decoration: const InputDecoration(
                                    labelText: "Vehicle Model",
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: _vehicleLicenseController,
                                  decoration: const InputDecoration(
                                    labelText: "License Plate",
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                ElevatedButton(
                                  onPressed: _addVehicle,
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.brown),
                                  child: const Text(
                                    "Save Vehicle",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    // **Total Seats**
                    TextField(
                      controller: _totalSeatsController,
                      decoration: const InputDecoration(
                        labelText: "Total Seat Capacity",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 10),

                    // **Available Seats**
                    TextField(
                      controller: _availableSeatsController,
                      decoration: const InputDecoration(
                        labelText: "Available Seats",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 10),

                    // **Note to Riders**
                    TextField(
                      controller: _noteToRidersController,
                      decoration: const InputDecoration(
                        labelText: "Note to Riders - Guidelines",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text("Additional Options",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500)),
                            SizedBox(
                              height: 8,
                            ),
                            Wrap(
                              spacing: 8,
                              children: _multiSelectOptions.map((option) {
                                String key =
                                    option.toLowerCase().replaceAll(' ', '_');
                                if (key == 'wheelchair_accessible')
                                  key = 'wheelchair_access';

                                return FilterChip(
                                  label: Text(option),
                                  selected: _selectedOptions[key] ?? false,
                                  onSelected: (selected) {
                                    setState(() {
                                      _selectedOptions[key] = selected;
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitRide,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.brown),
                        child: const Text("Post Ride",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
