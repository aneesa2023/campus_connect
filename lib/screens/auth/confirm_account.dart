import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ConfirmAccountScreen extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController confirmationCodeController = TextEditingController();

  ConfirmAccountScreen({super.key});

  Future<void> confirmAccount(BuildContext context) async {
    final String backendUrl = "http://127.0.0.1:8000/confirm"; // Update this to your actual backend URL
    final Map<String, String> headers = {"Content-Type": "application/json"};
    final Map<String, dynamic> body = {
      "username": usernameController.text,
      "confirmation_code": confirmationCodeController.text,
    };

    try {
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account confirmed successfully! Please sign in.")),
        );
        Navigator.pushNamed(context, '/login'); // Navigate to the login screen
      } else {
        final error = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${error['detail'] ?? 'Failed to confirm account'}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Account'),
        backgroundColor: Colors.brown,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Confirm Your Account',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: confirmationCodeController,
              decoration: const InputDecoration(
                labelText: 'Confirmation Code',
                prefixIcon: Icon(Icons.code),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => confirmAccount(context),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Confirm Account'),
            ),
          ],
        ),
      ),
    );
  }
}
