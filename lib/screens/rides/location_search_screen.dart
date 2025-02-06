import 'package:campus_connect/screens/utilities/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_webservice/places.dart' as gmaps;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LocationSearchScreen extends StatefulWidget {
  final String title;
  final String googleApiKey;

  const LocationSearchScreen({
    super.key,
    required this.title,
    required this.googleApiKey,
  });

  @override
  LocationSearchScreenState createState() => LocationSearchScreenState();
}

class LocationSearchScreenState extends State<LocationSearchScreen> {
  final TextEditingController _textEditingController = TextEditingController();
  final gmaps.GoogleMapsPlaces _places;

  LatLng? _selectedLocation;
  Marker? _selectedMarker;
  late GoogleMapController _mapController;

  LocationSearchScreenState()
      : _places = gmaps.GoogleMapsPlaces(apiKey: Constants.googleApiKey);

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  Future<void> _fetchAddressFromLatLng(LatLng position) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=${widget.googleApiKey}',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'] != null && data['results'].isNotEmpty) {
        if (mounted) {
          setState(() {
            _textEditingController.text =
                data['results'][0]['formatted_address'] ?? 'Unknown Address';
          });
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to fetch address.")),
        );
      }
    }
  }

  Future<void> _handlePredictionSelection(gmaps.Prediction prediction) async {
    final placeDetails = await _places.getDetailsByPlaceId(prediction.placeId!);

    if (placeDetails.status == "OK" && placeDetails.result.geometry != null) {
      final location = placeDetails.result.geometry!.location;
      final lat = location.lat;
      final lng = location.lng;

      if (mounted) {
        setState(() {
          _textEditingController.text = prediction.description!;
          _selectedLocation = LatLng(lat, lng);
          _selectedMarker = Marker(
            markerId: const MarkerId("selected"),
            position: _selectedLocation!,
            draggable: true,
            onDragEnd: (newPosition) {
              setState(() {
                _selectedLocation = newPosition;
              });
              _fetchAddressFromLatLng(newPosition);
            },
          );
          _mapController.animateCamera(
            CameraUpdate.newLatLngZoom(_selectedLocation!, 15),
          );
        });
      }
    }
  }

  Future<List<gmaps.Prediction>> _fetchPredictions(String input) async {
    final response = await _places.autocomplete(
      input,
      components: [gmaps.Component(gmaps.Component.country, "us")],
    );
    return response.predictions;
  }

  Future<void> _setCurrentLocation() async {
    final location = Location();

    final permissionStatus = await location.requestPermission();
    if (permissionStatus != PermissionStatus.granted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location permission denied.")),
        );
      }
      return;
    }

    try {
      final currentLocation = await location.getLocation();
      final currentLatLng =
          LatLng(currentLocation.latitude!, currentLocation.longitude!);

      if (mounted) {
        setState(() {
          _selectedLocation = currentLatLng;
          _selectedMarker = Marker(
            markerId: const MarkerId("current"),
            position: _selectedLocation!,
            draggable: true,
            onDragEnd: (newPosition) {
              setState(() {
                _selectedLocation = newPosition;
              });
              _fetchAddressFromLatLng(newPosition);
            },
          );
        });

        _mapController.animateCamera(
          CameraUpdate.newLatLngZoom(_selectedLocation!, 15),
        );

        // Fetch and set address for current location
        await _fetchAddressFromLatLng(currentLatLng);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to fetch current location.")),
        );
      }
    }
  }

  void _confirmLocation() {
    if (_selectedLocation != null) {
      Navigator.pop(context, {
        'description': _textEditingController.text,
        'lat': _selectedLocation!.latitude,
        'lng': _selectedLocation!.longitude,
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select a location.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.brown,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _textEditingController,
                  decoration: InputDecoration(
                    labelText: "Search or Type Location",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () async {
                        final predictions = await _fetchPredictions(
                            _textEditingController.text);

                        if (!mounted) {
                          return;
                        }
                        showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return ListView.builder(
                              itemCount: predictions.length,
                              itemBuilder: (context, index) {
                                final prediction = predictions[index];
                                return ListTile(
                                  title: Text(prediction.description ??
                                      "Unknown Location"),
                                  onTap: () {
                                    Navigator.pop(context);
                                    _handlePredictionSelection(prediction);
                                  },
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _setCurrentLocation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text(
                          "Current Location",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _confirmLocation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text(
                          "Confirm Location",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(
                    40.500618, -74.447449), // Rutgers University, New Brunswick
                zoom: 15,
              ),
              markers: _selectedMarker != null ? {_selectedMarker!} : {},
              onMapCreated: (controller) {
                _mapController = controller;
              },
              onTap: (position) {
                setState(() {
                  _selectedLocation = position;
                  _selectedMarker = Marker(
                    markerId: const MarkerId("selected"),
                    position: position,
                    draggable: true,
                    onDragEnd: (newPosition) {
                      setState(() {
                        _selectedLocation = newPosition;
                      });
                      _fetchAddressFromLatLng(newPosition);
                    },
                  );
                });
                _fetchAddressFromLatLng(position);
              },
            ),
          ),
        ],
      ),
    );
  }
}
