import 'package:campus_connect/screens/utilities/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'location_search_screen.dart';

class RideSearchScreen extends StatefulWidget {
  const RideSearchScreen({super.key});

  @override
  _RideSearchScreenState createState() => _RideSearchScreenState();
}

class _RideSearchScreenState extends State<RideSearchScreen> {
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  String? _selectedDateTime;

  LatLng? _fromLocation;
  LatLng? _toLocation;

  late GoogleMapController _mapController;
  Set<Marker> _markers = {};
  Polyline? _routePolyline;

  late String googleApiKey = Constants.googleApiKey;

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    googleApiKey = 'AIzaSyDYcWPWWFCBxoe29GllyuPGwV3IXN0F750';
    debugPrint("Google API Key Initialized: $googleApiKey");
  }

  Future<void> _navigateToSearch(
      String title, TextEditingController controller, bool isFrom) async {
    debugPrint("Navigating to search with API Key: $googleApiKey");
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
      debugPrint("Search Result: $result");
      controller.text = result['description'] ?? "Unknown Location";

      final lat = result['lat'];
      final lng = result['lng'];

      if (lat != null && lng != null) {
        if (isFrom) {
          _fromLocation = LatLng(lat, lng);
        } else {
          _toLocation = LatLng(lat, lng);
        }
      } else {
        debugPrint("Lat/Lng are null in result.");
      }

      setState(() {});
    } else {
      debugPrint("Search Result is null.");
    }
  }

  Future<void> _fetchRoute() async {
    if (_fromLocation == null || _toLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select both locations.")),
      );
      return;
    }

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

          // Update camera to fit the route
          LatLngBounds bounds = _getBoundsForPolyline(decodedPoints);
          _mapController
              .animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
        });

        debugPrint("Route Polyline Set: $decodedPoints");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No route found between locations.")),
        );
      }
    } else {
      debugPrint("Failed API Response: ${response.body}");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to fetch route from API.")),
      );
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

  void _onSearchRoute() {
    if (_fromLocation == null || _toLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select both locations.")),
      );
      return;
    }

    debugPrint("From Location: ${_fromController.text}");
    debugPrint(
        "From LatLng: ${_fromLocation?.latitude}, ${_fromLocation?.longitude}");

    debugPrint("To Location: ${_toController.text}");
    debugPrint(
        "To LatLng: ${_toLocation?.latitude}, ${_toLocation?.longitude}");

    _markers.clear();
    _markers.add(Marker(
      markerId: const MarkerId("from"),
      position: _fromLocation!,
      infoWindow: const InfoWindow(title: "From"),
    ));
    _markers.add(Marker(
      markerId: const MarkerId("to"),
      position: _toLocation!,
      infoWindow: const InfoWindow(title: "To"),
    ));

    _fetchRoute();
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

  void _updateCameraBounds() {
    if (_fromLocation != null && _toLocation != null) {
      LatLngBounds bounds = LatLngBounds(
        southwest: LatLng(
          _fromLocation!.latitude < _toLocation!.latitude
              ? _fromLocation!.latitude
              : _toLocation!.latitude,
          _fromLocation!.longitude < _toLocation!.longitude
              ? _fromLocation!.longitude
              : _toLocation!.longitude,
        ),
        northeast: LatLng(
          _fromLocation!.latitude > _toLocation!.latitude
              ? _fromLocation!.latitude
              : _toLocation!.latitude,
          _fromLocation!.longitude > _toLocation!.longitude
              ? _fromLocation!.longitude
              : _toLocation!.longitude,
        ),
      );
      debugPrint("Updating camera bounds: $bounds");
      _mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search for a Ride'),
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
                ElevatedButton(
                  onPressed: _onSearchRoute,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text(
                    "Search Route",
                    style: TextStyle(color: Colors.white),
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
                _updateCameraBounds();
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
