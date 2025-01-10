import 'package:flutter/material.dart';

class PostRideDetails extends StatefulWidget {
  const PostRideDetails({super.key});

  @override
  _PostRideDetailsState createState() => _PostRideDetailsState();
}

class _PostRideDetailsState extends State<PostRideDetails> {
  final TextEditingController _capacityController = TextEditingController();
  final TextEditingController _vehicleTypeController = TextEditingController();
  final TextEditingController _vehicleModelController = TextEditingController();
  final TextEditingController _vehicleLicenseController =
      TextEditingController();
  final TextEditingController _noteToRidersController = TextEditingController();

  String? _selectedVehicle;
  final List<String> _savedVehicles = [
    'Sedan - Honda Accord (XYZ123)',
    'SUV - Toyota Highlander (ABC456)',
  ];
  final List<String> _multiSelectOptions = [
    'Pet Friendly',
    'Trunk Space',
    'Air Conditioning',
    'Wheelchair Accessible'
  ];
  final List<String> _selectedOptions = [];

  void _addVehicle() {
    if (_vehicleTypeController.text.isNotEmpty &&
        _vehicleModelController.text.isNotEmpty &&
        _vehicleLicenseController.text.isNotEmpty) {
      setState(() {
        _savedVehicles.add(
            '${_vehicleTypeController.text} - ${_vehicleModelController.text} (${_vehicleLicenseController.text})');
        _vehicleTypeController.clear();
        _vehicleModelController.clear();
        _vehicleLicenseController.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all Vehicle details')),
      );
    }
  }

  @override
  void dispose() {
    _capacityController.dispose();
    _vehicleTypeController.dispose();
    _vehicleModelController.dispose();
    _vehicleLicenseController.dispose();
    _noteToRidersController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post a Ride'),
        backgroundColor: Colors.brown,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _capacityController,
                decoration: const InputDecoration(
                  labelText: "Member Capacity",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              // Select Vehicle Section
              if (_savedVehicles.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16.0),
                  margin: const EdgeInsets.only(bottom: 16.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Select Saved Vehicle",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButton<String>(
                        value: _selectedVehicle,
                        hint: const Text(
                          "Select Saved Vehicle",
                        ),
                        isExpanded: true,
                        items: _savedVehicles.map((vehicle) {
                          return DropdownMenuItem(
                            value: vehicle,
                            child: Text(vehicle),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedVehicle = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              // Add New Vehicle Section
              Container(
                padding: const EdgeInsets.all(16.0),
                margin: const EdgeInsets.only(bottom: 16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Add New Vehicle",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _vehicleTypeController,
                      decoration: const InputDecoration(
                        labelText: "Vehicle Type",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _vehicleModelController,
                      decoration: const InputDecoration(
                        labelText: "Vehicle Model",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _vehicleLicenseController,
                      decoration: const InputDecoration(
                        labelText: "Vehicle License Number",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: _addVehicle,
                        icon: const Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                        label: const Text(
                          "Add Vehicle",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Note to Riders Section
              TextField(
                controller: _noteToRidersController,
                decoration: const InputDecoration(
                  labelText: "Note to Riders - Guidelines",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              // Additional Options Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                color: Colors.grey[300],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Additional Options",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Wrap(
                      spacing: 8,
                      children: _multiSelectOptions.map((option) {
                        return FilterChip(
                          label: Text(option),
                          selected: _selectedOptions.contains(option),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedOptions.add(option);
                              } else {
                                _selectedOptions.remove(option);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Confirm Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, {
                      'capacity': _capacityController.text,
                      'vehicle': _selectedVehicle,
                      'note': _noteToRidersController.text,
                      'options': _selectedOptions,
                    });
                    print(
                        "ride details: ${_capacityController.text}, ${_selectedVehicle!}, ${_noteToRidersController.text}, $_selectedOptions");
                    if (_selectedVehicle!.isNotEmpty) {
                      Navigator.pushNamed(context, '/home');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Fill mandatory fields to proceed"),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    "Confirm",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
