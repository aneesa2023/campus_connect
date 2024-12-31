import 'package:campus_connect/screens/edit_profile.dart';
import 'package:flutter/material.dart';

class ViewProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'View Profile',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.brown,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.edit,
              color: Colors.white,
            ),
            onPressed: () {
              // Navigate to Edit Profile Screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.grey[400],
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'User Name',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'username@gmail.com',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Divider(),

            // Personal Details
            Text('Personal Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            _buildReadOnlyField('Full Name', 'John Doe'),
            SizedBox(height: 10),
            _buildReadOnlyField('Email Address', 'johndoe@example.com'),
            SizedBox(height: 10),
            _buildReadOnlyField('Phone Number', '123-456-7890'),
            SizedBox(height: 20),
            Divider(),

            // Vehicle Details
            Text('Vehicle Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            _buildReadOnlyField('Vehicle Name/Model', 'Toyota Corolla'),
            SizedBox(height: 10),
            _buildReadOnlyField('Driving License Number', 'DL12345678'),
            SizedBox(height: 20),
            Divider(),
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 5),
        Text(value, style: TextStyle(fontSize: 16)),
        SizedBox(height: 10),
      ],
    );
  }
}
