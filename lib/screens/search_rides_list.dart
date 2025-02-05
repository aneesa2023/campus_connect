import 'package:campus_connect/screens/driver_profile.dart';
import 'package:campus_connect/services/api_service.dart';
import 'package:campus_connect/services/auth_service.dart';
import 'package:flutter/material.dart';

class SearchedRidesList extends StatefulWidget {
  final String fromLocation;
  final double fromLat;
  final double fromLong;
  final String toLocation;
  final double toLat;
  final double toLong;
  final String departureTime;
  final bool petFriendly;
  final bool trunkSpace;
  final bool wheelchairAccess;
  final int seatsRequested;

  const SearchedRidesList({
    super.key,
    required this.fromLocation,
    required this.fromLat,
    required this.fromLong,
    required this.toLocation,
    required this.toLat,
    required this.toLong,
    required this.departureTime,
    required this.petFriendly,
    required this.trunkSpace,
    required this.wheelchairAccess,
    required this.seatsRequested,
  });

  @override
  State<SearchedRidesList> createState() => _SearchedRidesListState();
}

class _SearchedRidesListState extends State<SearchedRidesList> {
  List<Map<String, dynamic>> _rides = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? riderUserId;
  TextEditingController noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchSearchedRides();
    _loadUserDetails();
  }

  /// Fetch available rides from API
  Future<void> _fetchSearchedRides() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final routeDetails = {
        "from_lat": widget.fromLat,
        "from_long": widget.fromLong,
        "to_lat": widget.toLat,
        "to_long": widget.toLong,
        "departure_time": widget.departureTime,
        "pet_friendly": widget.petFriendly,
        "trunk_space": widget.trunkSpace,
        "wheelchair_access": widget.wheelchairAccess,
        "seats_requested": widget.seatsRequested
      };
      final response = await ApiService.postRequest(
        module: 'search_ride',
        endpoint: 'rides/search',
        body: routeDetails,
      );
      print("routeDetails $routeDetails");

      if (response.containsKey('rides')) {
        setState(() {
          _rides = List<Map<String, dynamic>>.from(response["rides"]);
          _isLoading = false;
        });
        print(_rides);
      } else {
        setState(() {
          _errorMessage = "Failed to load rides. Please try again.";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error fetching rides: ${e.toString()}";
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUserDetails() async {
    String? storedUserId = await AuthService.getUserId();
    if (storedUserId != null) {
      riderUserId = storedUserId;
    } else {
      setState(() {
        riderUserId = 'Unknown';
      });
    }
  }

  Future<void> _showNoteDialog(String rideId) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add a Note"),
        content: TextField(
          controller: noteController,
          decoration: const InputDecoration(
            labelText: "Enter your message for the driver",
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _requestRide(rideId, noteController.text);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.brown),
            child: const Text(
              "Send Request",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _requestRide(String rideId, String notes) async {
    try {
      final requestPayload = {
        "rider_id": riderUserId,
        "ride_status": "pending",
        "seats_requested": widget.seatsRequested,
        "notes": notes
      };
      _isLoading = true;
      print("$rideId-----$riderUserId");
      final response = await ApiService.postRequest(
        module: 'request_ride',
        endpoint: 'rides/$rideId/request',
        body: requestPayload,
      );

      if (response.containsKey("message")) {
        print("test print" + response.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response["message"]),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _fetchSearchedRides();
          _isLoading = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to request ride: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Available Rides"),
        backgroundColor: Colors.brown,
      ),
      body: _buildRideList("scheduled"),
    );
  }

  Widget _buildRideList(String status) {
    List<Map<String, dynamic>> rideList;

    rideList = _rides;
    String getEnabledOptions(Map<String, dynamic> ride) {
      List<String> enabledOptions = [];

      if (ride['pet_friendly'] == "true") enabledOptions.add("Pet Friendly");
      if (ride['trunk_space'] == "true") enabledOptions.add("Trunk Space");
      if (ride['air_conditioning'] == "true") {
        enabledOptions.add("Air Conditioning");
      }
      if (ride['wheelchair_access'] == "true") {
        enabledOptions.add("Wheelchair Accessible");
      }

      return enabledOptions.isNotEmpty
          ? enabledOptions.join(", ")
          : "No Additional Features Available";
    }

    if (rideList.isEmpty) {
      return const Center(child: Text("No rides available."));
    }
    return RefreshIndicator(
      onRefresh: _fetchSearchedRides,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              : rideList.isEmpty
                  ? const Center(child: Text("No rides found."))
                  : ListView.builder(
                      padding: const EdgeInsets.all(8.0),
                      itemCount: rideList.length,
                      itemBuilder: (context, index) {
                        final ride = rideList[index];

                        return Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          margin: const EdgeInsets.symmetric(vertical: 10.0),
                          color: Colors.white, // Background color
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Scheduled at: ${ride['departure_time']!}",
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 12),
                                const Divider(),
                                const SizedBox(height: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      ride['from_location']!,
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[700]),
                                    ),
                                    const Icon(Icons.arrow_downward,
                                        color: Colors.grey, size: 16),
                                    Text(
                                      ride['to_location']!,
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[700]),
                                    ),
                                  ],
                                ),
                                const Divider(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    OutlinedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => DriverProfile(
                                              driverId: ride['user_id'],
                                            ),
                                          ),
                                        );
                                      },
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.black,
                                        side: const BorderSide(
                                            color: Colors.brown),
                                      ),
                                      child: Text(
                                        'Driver Details',
                                        style: TextStyle(color: Colors.brown),
                                      ),
                                    ),
                                    OutlinedButton(
                                      onPressed: () {},
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.black,
                                        side: const BorderSide(
                                            color: Colors.brown),
                                      ),
                                      child: Text(
                                        'Vehicle Details',
                                        style: TextStyle(color: Colors.brown),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Price',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "--",
                                            // ride['price']!,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Vehicle',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            ride['car_id'].toString(),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Total Seats',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            ride['total_seats']!.toString(),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Available Seats',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            ride['available_seats']!.toString(),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  'Notes: ${ride['note']!}',
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.grey[700]),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Additional Features: ${getEnabledOptions(ride)}',
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.grey[700]),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    _requestRide(ride['ride_status'],
                                                    noteController.text)
                                                .toString() ==
                                            "pending"
                                        ? null
                                        : _showNoteDialog(ride['ride_id']);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.brown,
                                    minimumSize:
                                        const Size(double.infinity, 40),
                                  ),
                                  child: Text(
                                    _requestRide(ride['ride_status'],
                                                    noteController.text)
                                                .toString() ==
                                            "pending"
                                        ? 'Requested Ride'
                                        : 'Request Ride',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
