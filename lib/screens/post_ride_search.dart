import 'package:campus_connect/screens/utilities/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'location_search_screen.dart';

class PostRideLocationScreen extends StatefulWidget {
  const PostRideLocationScreen({super.key});

  @override
  _PostRideLocationScreenState createState() => _PostRideLocationScreenState();
}

class _PostRideLocationScreenState extends State<PostRideLocationScreen> {
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  String? _selectedDateTime;

  LatLng? _fromLocation;
  LatLng? _toLocation;

  late GoogleMapController _mapController;
  Set<Marker> _markers = {};
  Polyline? _routePolyline;

  final String googleApiKey = Constants.googleApiKey;

  bool _isRouteFetched = false;

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  Future<void> _navigateToSearch(
      String title, TextEditingController controller, bool isFrom) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationSearchScreen(
          title: title,
          googleApiKey: googleApiKey,
        ),
      ),
    );

    if (result != null) {
      controller.text = result['description'] ?? "Unknown Location";

      final lat = result['lat'];
      final lng = result['lng'];

      if (lat != null && lng != null) {
        if (isFrom) {
          _fromLocation = LatLng(lat, lng);
        } else {
          _toLocation = LatLng(lat, lng);
        }
      }
      setState(() {});
    }
  }

  Future<void> _fetchRoute() async {
    if (_fromLocation == null || _toLocation == null) return;

    final response = await http.get(
      Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json?origin=${_fromLocation!.latitude},${_fromLocation!.longitude}&destination=${_toLocation!.latitude},${_toLocation!.longitude}&key=$googleApiKey',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['routes'] != null && data['routes'].isNotEmpty) {
        final polylinePoints = data['routes'][0]['overview_polyline']['points'];
        List<LatLng> decodedPoints = _decodePolyline(polylinePoints);

        setState(() {
          _routePolyline = Polyline(
            polylineId: const PolylineId("route"),
            points: decodedPoints,
            color: Colors.blue,
            width: 4,
          );

          LatLngBounds bounds = _getBoundsForPolyline(decodedPoints);
          _mapController
              .animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));

          _isRouteFetched = true;
        });
      }
    }
  }

  LatLngBounds _getBoundsForPolyline(List<LatLng> polylinePoints) {
    double minLat = polylinePoints.first.latitude;
    double maxLat = polylinePoints.first.latitude;
    double minLng = polylinePoints.first.longitude;
    double maxLng = polylinePoints.first.longitude;

    for (LatLng point in polylinePoints) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post a Ride'),
        backgroundColor: Colors.brown,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => _navigateToSearch(
                      "Select From Location", _fromController, true),
                  child: TextField(
                    controller: _fromController,
                    enabled: false,
                    decoration: InputDecoration(
                      labelText: "From",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      suffixIcon: const Icon(Icons.location_on),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => _navigateToSearch(
                      "Select To Location", _toController, false),
                  child: TextField(
                    controller: _toController,
                    enabled: false,
                    decoration: InputDecoration(
                      labelText: "To",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      suffixIcon: const Icon(Icons.location_on),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    DatePicker.showDateTimePicker(
                      context,
                      showTitleActions: true,
                      minTime: DateTime.now(),
                      maxTime: DateTime(2025, 12, 31),
                      onConfirm: (date) {
                        setState(() {
                          _selectedDateTime =
                              "${date.month}-${date.day}-${date.year} ${date.hour}:${date.minute}";
                        });
                      },
                      currentTime: DateTime.now(),
                    );
                  },
                  child: TextField(
                    enabled: false,
                    decoration: InputDecoration(
                      labelText: _selectedDateTime ?? "Select Date & Time",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      suffixIcon: const Icon(
                        Icons.calendar_today,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isRouteFetched
                      ? () {
                          Navigator.pushNamed(context, '/postRideDetails');
                        }
                      : _fetchRoute,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: Text(
                    _isRouteFetched ? "Post Ride" : "Get Route",
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(37.7749, -122.4194),
                zoom: 6,
              ),
              onMapCreated: (controller) {
                _mapController = controller;
              },
              markers: _markers,
              polylines: _routePolyline != null ? {_routePolyline!} : {},
            ),
          ),
        ],
      ),
    );
  }
}
