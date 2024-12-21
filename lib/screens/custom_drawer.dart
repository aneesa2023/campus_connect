import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            accountName: Text(
              'User Name',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(
              'username@gmail.com',
              style: TextStyle(color: Colors.black54),
            ),
          ),
          Expanded(
            child: ListView(padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(Icons.person, 'Profile', () {}),
                _buildDrawerItem(Icons.directions_car, 'My Trips', () {}),
                _buildDrawerItem(Icons.info, 'About', () {}),
                _buildDrawerItem(Icons.notifications, 'Notifications', () {}),
                _buildDrawerItem(Icons.settings, 'Settings', () {}),
                _buildDrawerItem(Icons.help, 'Help and Support', () {}),
                _buildDrawerItem(Icons.logout, 'Logout', () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title, style: TextStyle(fontSize: 16)),
      onTap: onTap,
    );
  }
}
