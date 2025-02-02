import 'package:campus_connect/screens/view_ride_requests_list.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:campus_connect/services/api_service.dart';
import 'package:campus_connect/services/auth_service.dart';

class PostedRidesList extends StatefulWidget {
  const PostedRidesList({super.key});

  @override
  State<PostedRidesList> createState() => _PostedRidesListState();
}

class _PostedRidesListState extends State<PostedRidesList> {
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchPostedRides();
  }

  final List<Map<String, dynamic>> _scheduledRides = [];
  final List<Map<String, dynamic>> _cancelledRides = [];
  final List<Map<String, dynamic>> _completedRides = [];

  Future<void> _fetchPostedRides() async {
    setState(() => _isLoading = true);

    try {
      String? userId = await AuthService.getUserId();
      if (userId == null) throw Exception("User ID not found");

      final response = await ApiService.getRequest(
        module: 'post_ride',
        endpoint: '$userId/rides',
      );

      print("API Response: $response");

      if (response.containsKey('car_rides') && response['car_rides'] is List) {
        List<dynamic> rideData = response['car_rides'];

        _scheduledRides.clear();
        _cancelledRides.clear();
        _completedRides.clear();

        for (var item in rideData) {
          if (item is Map<String, dynamic>) {
            Map<String, dynamic> ride = {
              "ride_id": item["ride_id"] ?? "N/A",
              "car_id": item["car_id"] ?? "N/A",
              "from_location": item["from_location"]?.toString() ?? "N/A",
              "to_location": item["to_location"]?.toString() ?? "N/A",
              "departure_time": _formatDate(item["departure_time"]),
              "created_at": _formatDate(item["created_at"]),
              "ride_status": item["ride_status"]?.toString() ?? "N/A",
              "total_seats": _parseSeats(item["total_seats"]),
              "available_seats": _parseSeats(item["available_seats"]),
              "note": item["note"]?.toString() ?? "No notes",
            };

            // Sort rides into different lists
            if (ride["ride_status"] == "scheduled") {
              _scheduledRides.add(ride);
            } else if (ride["ride_status"] == "cancelled") {
              _cancelledRides.add(ride);
            } else if (ride["ride_status"] == "completed") {
              _completedRides.add(ride);
            }
          }
        }
      } else {
        print("No 'car_rides' key found or incorrect format.");
      }

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Failed to load rides: ${e.toString()}";
          _isLoading = false;
        });
      }
      print("Error fetching rides: $e");
    }
  }

  Future<void> _cancelRide(String rideId) async {
    bool confirmCancel = await _showCancelConfirmationDialog();
    if (!confirmCancel) return;

    setState(() {
      _isLoading = true;
    });

    final body = {
      "ride_status": "cancelled",
      "updated_at": DateTime.now().toIso8601String()
    };

    try {
      final response = await ApiService.putRequest(
        module: 'post_ride',
        endpoint: 'rides/$rideId',
        body: body,
      );

      if (response['success'] == true) {
        await _fetchPostedRides();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Ride cancelled successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception("Failed to cancel ride.");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool> _showCancelConfirmationDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Cancel Ride"),
            content: const Text("Are you sure you want to cancel this ride?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("No"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text("Yes"),
              ),
            ],
          ),
        ) ??
        false;
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty || dateString == "N/A") {
      return "Unknown";
    }
    try {
      DateTime dateTime = DateTime.parse(dateString);
      return DateFormat("MMM dd, yyyy - hh:mm a").format(dateTime);
    } catch (e) {
      return "Invalid Date";
    }
  }

  num _parseSeats(dynamic seatValue) {
    if (seatValue is num) return seatValue;
    if (seatValue is String) return double.tryParse(seatValue) ?? 0;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("My Posted Rides"),
          backgroundColor: Colors.brown,
          bottom: TabBar(
            indicatorColor: Colors.brown.shade900,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(
                text: "Scheduled",
              ),
              Tab(text: "Cancelled"),
              Tab(text: "Completed"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildRideList("scheduled"),
            _buildRideList("cancelled"),
            _buildRideList("completed"),
          ],
        ),
      ),
    );
  }

// Helper function to filter rides based on status
  Widget _buildRideList(String status) {
    List<Map<String, dynamic>> rideList;

    if (status == "scheduled") {
      rideList = _scheduledRides;
    } else if (status == "cancelled") {
      rideList = _cancelledRides;
    } else if (status == "completed") {
      rideList = _completedRides;
    } else {
      rideList = _scheduledRides;
    }

    if (rideList.isEmpty) {
      return const Center(child: Text("No rides available."));
    }
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

    return RefreshIndicator(
      onRefresh: _fetchPostedRides,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Text(_errorMessage!,
                      style: const TextStyle(color: Colors.red)))
              : rideList.isEmpty
                  ? const Center(child: Text("No rides posted yet."))
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
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      ride['departure_time']!,
                                      style: const TextStyle(
                                          color: Colors.green,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    Chip(
                                      label: Text(
                                          ride['ride_status']!.toUpperCase()),
                                      backgroundColor:
                                          ride['ride_status'] == 'scheduled'
                                              ? Colors.green.shade200
                                              : Colors.orange.shade200,
                                    ),
                                  ],
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
                                if (status == "scheduled")
                                  Center(
                                    child: ElevatedButton(
                                      onPressed: () =>
                                          _cancelRide(ride['ride_id']),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        minimumSize:
                                            const Size(double.infinity, 40),
                                      ),
                                      child: const Text(
                                        'Cancel Ride',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ViewRideRequestsList(
                                          rideId: '${ride['ride_id']}',
                                        ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.brown,
                                    minimumSize:
                                        const Size(double.infinity, 40),
                                  ),
                                  child: const Text(
                                    'View All Ride Requests',
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
