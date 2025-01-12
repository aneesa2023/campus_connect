import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';

class RegisterDriverScreen extends StatefulWidget {
  const RegisterDriverScreen({super.key});

  @override
  RegisterDriverScreenState createState() =>
      RegisterDriverScreenState(); // Made class public
}

class RegisterDriverScreenState extends State<RegisterDriverScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _licenseNumberController =
      TextEditingController();
  final TextEditingController _issuingAuthorityController =
      TextEditingController();
  final TextEditingController _expirationDateController =
      TextEditingController();
  bool _isDeclarationChecked = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _licenseNumberController.dispose();
    _issuingAuthorityController.dispose();
    _expirationDateController.dispose();
    super.dispose();
  }

  void _submitRegistration() {
    if (_licenseNumberController.text.isEmpty ||
        _issuingAuthorityController.text.isEmpty ||
        _expirationDateController.text.isEmpty ||
        !_isDeclarationChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text("Please fill all the fields and accept the declaration."),
        ),
      );
      return;
    }

    // Submit the driver registration details
    Navigator.pop(context, {
      'fullName': _fullNameController.text,
      'licenseNumber': _licenseNumberController.text,
      'issuingAuthority': _issuingAuthorityController.text,
      'expirationDate': _expirationDateController.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register as a Driver'),
        centerTitle: true,
        backgroundColor: Colors.brown,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _fullNameController,
              decoration: const InputDecoration(
                labelText: "Full Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _licenseNumberController,
              decoration: const InputDecoration(
                labelText: "License Number",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _issuingAuthorityController,
              decoration: const InputDecoration(
                labelText: "Issuing Authority",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _expirationDateController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: "Expiration Date",
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () {
                    DatePicker.showDatePicker(
                      context,
                      showTitleActions: true,
                      minTime: DateTime.now(),
                      maxTime: DateTime.now().add(
                        const Duration(days: 3650), // 10 years from now
                      ),
                      onConfirm: (date) {
                        setState(() {
                          _expirationDateController.text =
                              DateFormat('MM-dd-yyyy')
                                  .format(date); // Format date here
                        });
                      },
                      currentTime: DateTime.now(),
                    );
                  },
                ),
              ),
              onTap: () {
                DatePicker.showDatePicker(
                  context,
                  showTitleActions: true,
                  minTime: DateTime.now(),
                  maxTime: DateTime.now().add(
                    const Duration(days: 3650), // 10 years from now
                  ),
                  onConfirm: (date) {
                    setState(() {
                      _expirationDateController.text = DateFormat('MM-dd-yyyy')
                          .format(date); // Format date here
                    });
                  },
                  currentTime: DateTime.now(),
                );
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: _isDeclarationChecked,
                  onChanged: (value) {
                    setState(() {
                      _isDeclarationChecked = value ?? false;
                    });
                  },
                ),
                const Expanded(
                  child: Text(
                    "I confirm that the above information is accurate and I am legally authorized to drive.",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitRegistration,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  "Register",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
