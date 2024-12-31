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
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(Icons.person, 'Profile', () {
                  Navigator.pushNamed(context, '/view_profile');
                }),
                _buildDrawerItem(Icons.directions_car, 'My Trips', () {
                  Navigator.pushNamed(context, '/my_trips');
                }),
                _buildDrawerItem(Icons.info, 'About', () {
                  Navigator.pushNamed(context, '/about');
                }),
                _buildDrawerItem(Icons.notifications, 'Notifications', () {
                  Navigator.pushNamed(context, '/notifications');
                }),
                _buildDrawerItem(Icons.settings, 'Settings', () {
                  Navigator.pushNamed(context, '/settings');
                }),
                _buildDrawerItem(Icons.help, 'Help and Support', () {
                  Navigator.pushNamed(context, '/help_support');
                }),
                _buildDrawerItem(Icons.logout, 'Logout', () {
                  Navigator.pushNamed(context, '/');
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.brown),
      title: Text(title, style: TextStyle(fontSize: 16)),
      onTap: onTap,
    );
  }
}
