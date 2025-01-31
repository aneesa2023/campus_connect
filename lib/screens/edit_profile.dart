import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'dart:io';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  EditProfileScreenState createState() => EditProfileScreenState();
}

class EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _collegeNameController = TextEditingController();
  final TextEditingController _collegeEmailIdController =
      TextEditingController();
  final TextEditingController _collegeIdController = TextEditingController();
  final TextEditingController _vehicleModelController = TextEditingController();
  final TextEditingController _licensePlateController = TextEditingController();
  final TextEditingController _licenseNumberController =
      TextEditingController();

  File? _profileImage;
  File? _licenseImage;
  List<Map<String, String>> _vehicles = [];
  int? _editingIndex;

  @override
  void initState() {
    super.initState();
    _nameController.text = 'John Doe';
    _emailController.text = 'johndoe@example.com';
    _phoneController.text = '123-456-7890';
    _collegeNameController.text = 'Rutgers University';
    _collegeEmailIdController.text = 'netid@rutgers.edu';
    _collegeIdController.text = 'netid123';

    _vehicles = [
      {
        'model': 'Toyota Corolla',
        'license': 'XYZ123',
        'license_number': 'ABC987'
      },
    ];
  }

  // 📷 Pick Profile Image
  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _profileImage = File(pickedImage.path);
      });
    }
  }

  // 🚗 Pick Vehicle License Image and Extract Text (OCR)
  Future<void> _pickAndScanLicense() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.camera);

    if (pickedImage != null) {
      final inputImage = InputImage.fromFilePath(pickedImage.path);
      final textRecognizer = GoogleMlKit.vision.textRecognizer();
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);

      setState(() {
        _licenseImage = File(pickedImage.path);
        _licenseNumberController.text =
            _extractLicenseNumber(recognizedText.text);
      });

      textRecognizer.close();
    }
  }

  // 🔍 Extract License Number from OCR Output
  String _extractLicenseNumber(String text) {
    RegExp regExp =
        RegExp(r'[A-Z0-9]{6,10}'); // Basic pattern for license numbers
    Iterable<Match> matches = regExp.allMatches(text);
    return matches.isNotEmpty ? matches.first.group(0) ?? '' : '';
  }

  // ✅ Validate License Before Adding
  bool _isLicenseValid(String license) {
    return RegExp(r'^[A-Z0-9]{6,10}$').hasMatch(license);
  }

  void _addOrEditVehicle() {
    if (_vehicleModelController.text.isNotEmpty &&
        _licensePlateController.text.isNotEmpty &&
        _licenseNumberController.text.isNotEmpty) {
      if (!_isLicenseValid(_licenseNumberController.text)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid License Number Format!')),
        );
        return;
      }

      setState(() {
        if (_editingIndex != null) {
          _vehicles[_editingIndex!] = {
            'model': _vehicleModelController.text,
            'license': _licensePlateController.text,
            'license_number': _licenseNumberController.text,
          };
        } else {
          _vehicles.add({
            'model': _vehicleModelController.text,
            'license': _licensePlateController.text,
            'license_number': _licenseNumberController.text,
          });
        }
        _vehicleModelController.clear();
        _licensePlateController.clear();
        _licenseNumberController.clear();
        _editingIndex = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all vehicle details')),
      );
    }
  }

  void _editVehicle(int index) {
    setState(() {
      _vehicleModelController.text = _vehicles[index]['model']!;
      _licensePlateController.text = _vehicles[index]['license']!;
      _licenseNumberController.text = _vehicles[index]['license_number']!;
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
            // Profile Image
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : null,
                    child: _profileImage == null
                        ? Icon(Icons.person, size: 50, color: Colors.grey[400])
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: _pickProfileImage,
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

            // Personal & College Details
            _buildSectionCard('Personal Details', [
              _buildEditableField('Full Name', _nameController),
              _buildEditableField('Email Address', _emailController),
              _buildEditableField('Phone Number', _phoneController),
            ]),

            _buildSectionCard('College Details', [
              _buildEditableField('College Name', _collegeNameController),
              _buildEditableField(
                  'College Email ID', _collegeEmailIdController),
              _buildEditableField('College ID', _collegeIdController),
            ]),

            // Vehicle Details
            _buildSectionCard('Vehicle Details', [
              ..._vehicles
                  .asMap()
                  .entries
                  .map((entry) => _buildVehicleRow(entry.key, entry.value)),
              const Divider(),
              _buildEditableField('Vehicle Model', _vehicleModelController),
              _buildEditableField('License Plate', _licensePlateController),
              _buildEditableField('License Number', _licenseNumberController),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _pickAndScanLicense,
                child: const Text('Scan License'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _addOrEditVehicle,
                child: Text(
                    _editingIndex != null ? 'Update Vehicle' : 'Add Vehicle'),
              ),
            ]),
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
          decoration: InputDecoration(labelText: label)),
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    return Card(
        child: Padding(
            padding: const EdgeInsets.all(16.0),
            child:
                Column(children: [Text(title), const Divider(), ...children])));
  }

  Widget _buildVehicleRow(int index, Map<String, String> vehicle) {
    return ListTile(
      title: Text(vehicle['model'] ?? 'Unknown Model'),
      subtitle: Text('License Plate: ${vehicle['license'] ?? 'N/A'}\n'
          'License Number: ${vehicle['license_number'] ?? 'N/A'}'),
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
  }
}
