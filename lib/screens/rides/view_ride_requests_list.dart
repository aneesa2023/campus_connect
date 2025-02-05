import 'package:flutter/material.dart';
import 'package:campus_connect/services/auth_service.dart';
import 'package:campus_connect/services/api_service.dart';

class ViewRideRequestsList extends StatefulWidget {
  final String rideId;

  const ViewRideRequestsList({super.key, required this.rideId});

  @override
  State<ViewRideRequestsList> createState() => _ViewRideRequestsListState();
}

class _ViewRideRequestsListState extends State<ViewRideRequestsList> {
  List<Map<String, dynamic>> _requests = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchRideRequests();
  }

  /// **Fetch all ride requests from API**
  Future<void> _fetchRideRequests() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.getRequest(
        module: 'request_ride',
        endpoint: 'rides/${widget.rideId}/requests',
      );

      if (response.containsKey('requests')) {
        setState(() {
          _requests = List<Map<String, dynamic>>.from(response["requests"]);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = "No requests found for this ride.";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error fetching ride requests: ${e.toString()}";
        _isLoading = false;
      });
    }
  }

  /// **Accept or Reject Ride Request**
  Future<void> _updateRequestStatus(
      String requestId, String action, int index) async {
    bool confirmAction = await _showConfirmationDialog(action);
    if (!confirmAction) return;

    setState(() {
      _isLoading = true;
    });

    try {
      String? userId = await AuthService.getUserId();
      if (userId == null) throw Exception("User ID not found");

      final body = {
        "user_id": userId,
        "action": action,
      };

      final response = await ApiService.putRequest(
        module: 'rides',
        endpoint: '${widget.rideId}/request/$requestId',
        body: body,
      );

      if (response.containsKey('success') && response['success'] == true) {
        setState(() {
          _requests[index]['ride_status'] =
              action == 'accept' ? 'accepted' : 'rejected';
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Ride request ${action}ed successfully."),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception("Failed to $action request.");
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// **Confirmation Dialog**
  Future<bool> _showConfirmationDialog(String action) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("${action} Request"),
            content: Text("Are you sure you want to $action this request?"),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ride Requests List"),
        backgroundColor: Colors.brown,
      ),
      body: _buildRequestsList(),
    );
  }

  Widget _buildRequestsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Text(
          _errorMessage!,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (_requests.isEmpty) {
      return const Center(
        child: Text("No ride requests found."),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchRideRequests,
      child: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: _requests.length,
        itemBuilder: (context, index) {
          final request = _requests[index];

          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            margin: const EdgeInsets.symmetric(vertical: 10.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow("Rider ID", request['rider_id']),
                  _buildDetailRow("Status", request['ride_status']),
                  _buildDetailRow("Requested At", request['created_at']),
                  _buildDetailRow("Updated At", request['updated_at']),
                  const Divider(),
                  if (request['ride_status'] == 'pending')
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _updateRequestStatus(
                              request['request_id'], "accept", index),
                          icon: const Icon(Icons.check, color: Colors.white),
                          label: const Text("Accept"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            minimumSize: const Size(120, 40),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _updateRequestStatus(
                              request['request_id'], "reject", index),
                          icon: const Icon(Icons.cancel, color: Colors.white),
                          label: const Text("Reject"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            minimumSize: const Size(120, 40),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
