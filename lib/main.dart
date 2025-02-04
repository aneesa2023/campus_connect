import 'package:campus_connect/screens/about.dart';
import 'package:campus_connect/screens/auth/confirm_account.dart';
import 'package:campus_connect/screens/auth/login_screen.dart';
import 'package:campus_connect/screens/auth/signup_screen.dart';
import 'package:campus_connect/screens/delete_account.dart';
import 'package:campus_connect/screens/driver_registration.dart';
import 'package:campus_connect/screens/edit_profile.dart';
import 'package:campus_connect/screens/help_support.dart';
import 'package:campus_connect/screens/home_page.dart';
import 'package:campus_connect/screens/my_trips.dart';
import 'package:campus_connect/screens/notifications.dart';
import 'package:campus_connect/screens/onboarding_screen.dart';
import 'package:campus_connect/screens/post_ride_details.dart';
import 'package:campus_connect/screens/post_ride_search.dart';
import 'package:campus_connect/screens/posted_rides_list.dart';
import 'package:campus_connect/screens/privacy_policy.dart';
import 'package:campus_connect/screens/ride_search.dart';
import 'package:campus_connect/screens/view_profile.dart';
import 'package:campus_connect/screens/settings.dart';
import 'package:campus_connect/services/auth_service.dart';
import 'package:flutter/material.dart';

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
      home: const AuthChecker(),
      // initialRoute: '/',
      routes: {
        '/onboarding': (context) => OnboardingScreen(),
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignUpScreen(),
        '/confirm_account': (context) => ConfirmAccountScreen(),
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
        '/searchRide': (context) => RideSearchScreen(),
        '/postRide': (context) => PostRideLocationScreen(),
        '/postRideDetails': (context) => PostRideDetails(
              fromLocation: '',
              fromLat: 0,
              fromLong: 0,
              toLocation: '',
              toLat: 0,
              toLong: 0,
              departureTime: '',
            ),
        '/registerDriver': (context) => RegisterDriverScreen(),
        '/postedRides': (context) => PostedRidesList(),
      },
    );
  }
}

class AuthChecker extends StatelessWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AuthService.isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // If logged in, go to HomePage; otherwise, go to OnboardingScreen
        return snapshot.data == true
            ? const HomePage()
            : const OnboardingScreen();
      },
    );
  }
}
