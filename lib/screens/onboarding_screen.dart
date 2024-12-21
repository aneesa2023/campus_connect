import 'package:flutter/material.dart';

class OnboardingScreen extends StatelessWidget {
  final List<Map<String, String>> onboardData = [
    {
      'title': 'Campus Connect',
      'subtitle': 'Reduce Cost\nJoin the carpooling community and save time and money on your daily commute.'
    },
    {
      'title': 'Campus Connect',
      'subtitle': 'Save Environment\nReduce your carbon footprint and help to reduce traffic congestion.'
    },
    {
      'title': 'Campus Connect',
      'subtitle': 'Stress Free Commute\nEnjoy a stress-free commute with real-time carpool tracking and notifications.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        itemCount: onboardData.length,
        itemBuilder: (context, index) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              Text(
                onboardData[index]['title']!,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
              SizedBox(height: 20),
              Text(
                onboardData[index]['subtitle']!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              SizedBox(height: 30),
              if (index == onboardData.length - 1)
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, '/login'),
                      child: Text('Login'),
                      style: ElevatedButton.styleFrom(minimumSize: Size(200, 50)),
                    ),
                    SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: () => Navigator.pushNamed(context, '/signup'),
                      child: Text('Sign up'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: Size(200, 50),
                        side: BorderSide(color: Colors.black),
                      ),
                    ),
                  ],
                )
            ],
          );
        },
      ),
    );
  }
}
