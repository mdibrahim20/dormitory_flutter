import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../screens/Admin/admin_home_screen.dart';
import '../screens/home_screen.dart';
import '../screens/auth/login_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // 1️⃣ No user = go to login
        if (!snapshot.hasData || snapshot.data == null) {
          return LoginScreen();
        }

        // 2️⃣ User exists, check role
        final User user = snapshot.data!;
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Scaffold(body: Center(child: Text("User not found.")));
            }

            final data = snapshot.data!.data() as Map<String, dynamic>;
            final role = data['role'] ?? 'user';

            // 3️⃣ Route based on role
            if (role == 'admin') {
              return AdminDashboardScreen();   // 👈 your admin dashboard
            } else {
              return HomeScreen();        // 👈 normal user home page
            }
          },
        );
      },
    );
  }
}
