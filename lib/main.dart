import 'package:campus_connect/screens/about.dart';
import 'package:campus_connect/screens/delete_account.dart';
import 'package:campus_connect/screens/edit_profile.dart';
import 'package:campus_connect/screens/help_support.dart';
import 'package:campus_connect/screens/home_page.dart';
import 'package:campus_connect/screens/my_trips.dart';
import 'package:campus_connect/screens/notifications.dart';
import 'package:campus_connect/screens/privacy_policy.dart';
import 'package:campus_connect/screens/view_profile.dart';
import 'package:campus_connect/screens/settings.dart';
import 'package:flutter/material.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Campus Connect',
      theme: ThemeData(
          appBarTheme: AppBarTheme(
            foregroundColor: Colors.white,
            backgroundColor: Colors.brown,
            iconTheme: IconThemeData(color: Colors.white),
          ),
          primarySwatch: Colors.brown,
          scaffoldBackgroundColor: Colors.white,
          primaryColor: Colors.brown),
      initialRoute: '/', // Define the initial route
      routes: {
        '/': (context) => OnboardingScreen(),
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignUpScreen(),
        '/home': (context) => HomePage(),
        '/view_profile': (context) => ViewProfileScreen(),
        '/edit_profile': (context) => EditProfileScreen(),
        '/settings': (context) => Settings(),
        '/privacy_policy': (context) => PrivacyPolicyScreen(),
        '/delete_account': (context) => DeleteAccountScreen(),
        '/help_support': (context) => HelpAndSupportScreen(),
        '/about': (context) => AboutScreen(),
        '/notifications': (context) => NotificationsScreen(),
        '/my_trips': (context) => MyTripsScreen(),
      },
    );
  }
}
