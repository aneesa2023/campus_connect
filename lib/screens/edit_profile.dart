import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _collegeNameController = TextEditingController();
  final TextEditingController _collegeEmailIdController =
      TextEditingController();
  final TextEditingController _collegeIdController = TextEditingController();

  final TextEditingController _vehicleModelController = TextEditingController();
  final TextEditingController _licensePlateController = TextEditingController();

  File? _profileImage;
  List<Map<String, String>> _vehicles = [];
  int? _editingIndex;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with dummy data for demonstration
    _nameController.text = 'John Doe';
    _emailController.text = 'johndoe@example.com';
    _phoneController.text = '123-456-7890';
    _collegeNameController.text = 'Rutgers University';
    _collegeEmailIdController.text = 'netid@rutgers.edu';
    _collegeIdController.text = 'netid123';

    // Sample vehicle list
    _vehicles = [
      {'model': 'Toyota Corolla', 'license': 'XYZ123'},
      {'model': 'Honda Accord', 'license': 'ABC456'},
    ];
  }

  // Method to pick an image
  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _profileImage = File(pickedImage.path); // Store the selected image
      });
    }
  }

  void _addOrEditVehicle() {
    if (_vehicleModelController.text.isNotEmpty &&
        _licensePlateController.text.isNotEmpty) {
      setState(() {
        if (_editingIndex != null) {
          // Update an existing vehicle
          _vehicles[_editingIndex!] = {
            'model': _vehicleModelController.text,
            'license': _licensePlateController.text,
          };
        } else {
          // Add a new vehicle
          _vehicles.add({
            'model': _vehicleModelController.text,
            'license': _licensePlateController.text,
          });
        }

        _vehicleModelController.clear();
        _licensePlateController.clear();
        _editingIndex = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in both fields')),
      );
    }
  }

  void _editVehicle(int index) {
    setState(() {
      _vehicleModelController.text = _vehicles[index]['model']!;
      _licensePlateController.text = _vehicles[index]['license']!;
      _editingIndex = index;
    });
  }

  void _deleteVehicle(int index) {
    setState(() {
      _vehicles.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.brown,
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              // Save profile changes
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile Updated')),
              );
              Navigator.pop(context);
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header with Profile Icon
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : null, // Display uploaded image if available
                    child: _profileImage == null
                        ? Icon(
                            Icons.person, // Default profile icon
                            size: 50,
                            color: Colors.grey[400],
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: _pickImage,
                      child: const CircleAvatar(
                        backgroundColor: Colors.brown,
                        radius: 18,
                        child: Icon(Icons.camera_alt,
                            color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Personal Details
            _buildSectionCard(
              title: 'Personal Details',
              children: [
                _buildEditableField('Full Name', _nameController),
                _buildEditableField('Email Address', _emailController),
                _buildEditableField('Phone Number', _phoneController),
              ],
            ),

            // College Details
            _buildSectionCard(
              title: 'College Details',
              children: [
                _buildEditableField('College Name', _collegeNameController),
                _buildEditableField(
                    'College Email ID', _collegeEmailIdController),
                _buildEditableField('College ID', _collegeIdController),
              ],
            ),

            // Vehicle Details
            _buildSectionCard(
              title: 'Vehicle Details',
              children: [
                ..._vehicles.asMap().entries.map((entry) {
                  int index = entry.key;
                  Map<String, String> vehicle = entry.value;
                  return ListTile(
                    title: Text(vehicle['model']!),
                    subtitle: Text('License Plate: ${vehicle['license']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.brown),
                          onPressed: () => _editVehicle(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteVehicle(index),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                const Divider(),
                TextField(
                  controller: _vehicleModelController,
                  decoration: const InputDecoration(
                    labelText: 'Vehicle Model',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _licensePlateController,
                  decoration: const InputDecoration(
                    labelText: 'License Plate',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _addOrEditVehicle,
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.brown),
                    child: Text(
                      _editingIndex != null ? 'Update Vehicle' : 'Add Vehicle',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}
