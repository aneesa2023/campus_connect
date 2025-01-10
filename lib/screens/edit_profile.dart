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
  final TextEditingController _vehicleController = TextEditingController();
  final TextEditingController _licenseController = TextEditingController();

  File? _profileImage;

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
    _vehicleController.text = 'Toyota Corolla';
    _licenseController.text = 'DL12345678';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.brown,
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              // Save profile changes
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Profile Updated')),
              );
              Navigator.pop(context);
            },
            child: Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
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
                      child: CircleAvatar(
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
            SizedBox(height: 20),
            // Personal Details
            Text('Personal Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            _buildEditableField('Full Name', _nameController),
            SizedBox(height: 10),
            _buildEditableField('Email Address', _emailController),
            SizedBox(height: 10),
            _buildEditableField('Phone Number', _phoneController),
            SizedBox(height: 20),

            // College Details
            Text('College Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            _buildEditableField('College Name', _collegeNameController),
            SizedBox(height: 10),
            _buildEditableField('College Email Id', _collegeEmailIdController),
            SizedBox(height: 10),
            _buildEditableField('College Id', _collegeIdController),
            SizedBox(height: 20),

            // Vehicle Details
            Text('Vehicle Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            _buildEditableField('Vehicle Name/Model', _vehicleController),
            SizedBox(height: 10),
            _buildEditableField('Driving License Number', _licenseController),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
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
}
