import 'package:flutter/material.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
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
  _LocationSearchScreenState createState() => _LocationSearchScreenState();
}

class _LocationSearchScreenState extends State<LocationSearchScreen> {
  final TextEditingController _textEditingController = TextEditingController();
  double? _manualLat;
  double? _manualLng;

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  Future<void> _fetchLatLngFromAddress(String address) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json?address=$address&key=${widget.googleApiKey}',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      debugPrint("Geocode API Response: $data");
      if (data['results'] != null && data['results'].isNotEmpty) {
        final location = data['results'][0]['geometry']['location'];
        setState(() {
          _manualLat = location['lat'];
          _manualLng = location['lng'];
        });
      }
    } else {
      debugPrint("Failed Geocode API Response: ${response.body}");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to connect to Geocoding API.")),
      );
    }
  }

  void _handlePredictionSelection(prediction) async {
    if (prediction == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No prediction found.")),
      );
      return;
    }

    debugPrint("Prediction Clicked: ${prediction.description}");

    // Validate description
    if (prediction.description == null || prediction.description!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selected location has no description.")),
      );
      return;
    }

    // Extract latitude and longitude
    final placeId = prediction.placeId;
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=${widget.googleApiKey}',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['result'] != null &&
          data['result']['geometry'] != null &&
          data['result']['geometry']['location'] != null) {
        final location = data['result']['geometry']['location'];
        final lat = location['lat'];
        final lng = location['lng'];

        debugPrint("Lat: $lat, Lng: $lng");

        // Update text field and pass the data
        setState(() {
          _textEditingController.text = prediction.description!;
        });

        Navigator.pop(context, {
          'description': prediction.description,
          'lat': lat,
          'lng': lng,
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to fetch location details.")),
        );
      }
    } else {
      debugPrint("Place Details API Failed: ${response.body}");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to connect to Place Details API.")),
      );
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GooglePlaceAutoCompleteTextField(
              googleAPIKey: widget.googleApiKey,
              textEditingController: _textEditingController,
              inputDecoration: InputDecoration(
                labelText: "Search or Type Location",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _textEditingController.clear();
                  },
                ),
              ),
              debounceTime: 500,
              countries: ["us"],
              isLatLngRequired: true,
              itemClick: (prediction) {
                _handlePredictionSelection(prediction);
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final enteredText = _textEditingController.text;
                if (enteredText.isNotEmpty) {
                  await _fetchLatLngFromAddress(enteredText);

                  if (_manualLat != null && _manualLng != null) {
                    Navigator.pop(context, {
                      'description': enteredText,
                      'lat': _manualLat,
                      'lng': _manualLng,
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Please enter a valid address.")),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Please enter or select a location.")),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                "Confirm Location",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
