import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RideSearchScreen extends StatefulWidget {
  const RideSearchScreen({super.key});

  @override
  _RideSearchScreenState createState() => _RideSearchScreenState();
}

class _RideSearchScreenState extends State<RideSearchScreen> {
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  String? _selectedDateTime;

  late GoogleMapController _mapController;
  LatLng? _fromLocation;
  LatLng? _toLocation;

  Set<Marker> _markers = {};
  Polyline? _routePolyline;

  // Dummy Route Data for Display
  final LatLng _dummyFrom = LatLng(37.7749, -122.4194); // San Francisco
  final LatLng _dummyTo = LatLng(34.0522, -118.2437); // Los Angeles

  @override
  void initState() {
    super.initState();
    _initializeMapData();
  }

  void _initializeMapData() {
    _fromLocation = _dummyFrom;
    _toLocation = _dummyTo;

    _markers = {
      Marker(
          markerId: MarkerId("from"),
          position: _dummyFrom,
          infoWindow: InfoWindow(title: "From")),
      Marker(
          markerId: MarkerId("to"),
          position: _dummyTo,
          infoWindow: InfoWindow(title: "To")),
    };

    _routePolyline = Polyline(
      polylineId: PolylineId("route"),
      points: [_dummyFrom, _dummyTo],
      color: Colors.brown,
      width: 4,
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _updateCameraBounds();
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
      _mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
    }
  }

  void _selectDateTime() {
    DatePicker.showDateTimePicker(
      context,
      showTitleActions: true,
      minTime: DateTime.now(),
      maxTime: DateTime(2025, 12, 31),
      onConfirm: (date) {
        setState(() {
          _selectedDateTime = "${date.toLocal()}".split(' ')[0] +
              ' ${date.hour}:${date.minute}';
        });
      },
      currentTime: DateTime.now(),
    );
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
                // From Location
                TextField(
                  controller: _fromController,
                  decoration: InputDecoration(
                    labelText: "From",
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.location_on),
                  ),
                ),
                const SizedBox(height: 10),

                // To Location
                TextField(
                  controller: _toController,
                  decoration: InputDecoration(
                    labelText: "To",
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.location_on),
                  ),
                ),
                const SizedBox(height: 10),

                // Date & Time Selection
                GestureDetector(
                  onTap: _selectDateTime,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 12.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedDateTime ?? "Select Date & Time",
                          style: TextStyle(
                              color: _selectedDateTime == null
                                  ? Colors.grey
                                  : Colors.black),
                        ),
                        Icon(Icons.calendar_today, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Map Display
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _dummyFrom,
                zoom: 6,
              ),
              onMapCreated: _onMapCreated,
              markers: _markers,
              polylines: _routePolyline != null ? {_routePolyline!} : {},
            ),
          ),
        ],
      ),
    );
  }
}
