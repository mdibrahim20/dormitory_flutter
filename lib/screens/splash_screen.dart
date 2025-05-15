import 'package:flutter/material.dart';
import 'dart:async';
import 'home_screen.dart';
import 'package:dorm_booking_app/Widget/auth_wrapper.dart';
import 'auth/login_screen.dart'; // or redirect to check login state

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
          MaterialPageRoute(builder: (_) => AuthWrapper())
        // MaterialPageRoute(builder: (_) => HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade800,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.hotel, color: Colors.white, size: 100),
            SizedBox(height: 20),
            Text(
              'Dorm Booking',
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
