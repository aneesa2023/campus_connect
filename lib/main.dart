import 'package:campus_connect/screens/home_page.dart';
import 'package:flutter/material.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Disable the debug banner
      title: 'Campus Connect',
      theme: ThemeData(
        primarySwatch: Colors.blue, // Set a primary color
        scaffoldBackgroundColor: Colors.white, // Set background color
      ),
      initialRoute: '/', // Define the initial route
      routes: {
        '/': (context) => OnboardingScreen(),
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignUpScreen(),
        '/home': (context) => HomePage(),
        // '/signup': (context) => SignUpScreen(),
      },
    );
  }
}
