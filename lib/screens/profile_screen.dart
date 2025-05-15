import 'package:dorm_booking_app/screens/profile/payments_screen.dart';
import 'package:dorm_booking_app/screens/profile/personal_info_screen.dart';
import 'package:dorm_booking_app/screens/profile/profile_overview.dart';
import 'package:dorm_booking_app/screens/splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../Widget/app_bottom_nav_bar.dart'; // Your custom bottom nav

class ProfileScreen extends StatelessWidget {
  final int _selectedIndex = 4;

  void _onItemTapped(BuildContext context, int index) {
    if (index != _selectedIndex) {
      // Navigate to different screens accordingly
      // Example: Navigator.pushReplacementNamed(context, '/explore');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text('Profile', style: TextStyle(color: Colors.black)),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        children: [
          ListTile(
            leading: CircleAvatar(
              radius: 28,
              backgroundColor: Colors.black,
              child: Text("A", style: TextStyle(color: Colors.white, fontSize: 20)),
            ),title: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProfileOverview()),
              );
            },
            child: Text(
              "Anna",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

            subtitle: Text("Show profile"),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Airbnb your home", style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text("It's easy to start hosting and earn extra income."),
                      ],
                    ),
                  ),
                  SizedBox(width: 10),
                  Icon(Icons.home_work_outlined, size: 50), // replace with image if needed
                ],
              ),
            ),
          ),
          _sectionTitle("Settings"),
          _tile("Personal information", Icons.person_outline, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => PersonalInfoScreen()),
            );
          }),


          _tile("Payments and payouts", Icons.account_balance_wallet_outlined, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => PaymentsScreen()),
            );
          }),
          _tile("Taxes", Icons.description_outlined),
          _tile("Login & security", Icons.security_outlined),
          _tile("Accessibility", Icons.settings_accessibility_outlined),
          _tile("Translation", Icons.translate_outlined),
          _sectionTitle("Support"),
          _tile("Visit the Help Center", Icons.help_outline),
          _tile("Get help with a safety issue", Icons.shield_outlined),
          _tile("Report a neighborhood concern", Icons.report_problem_outlined),
          _tile("How Airbnb works", Icons.info_outline),
          _tile("Give us feedback", Icons.feedback_outlined),
          _sectionTitle("Legal"),
          _tile("Terms of Service", Icons.article_outlined),
          _tile("Privacy Policy", Icons.privacy_tip_outlined),
          _tile("Open source licenses", Icons.code_outlined),
          ListTile(
            title: Text("Log out", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => SplashScreen()),  // 👈 or LoginScreen() if you prefer
                    (route) => false,
              );
            },

          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, bottom: 40),
            child: Text("VERSION 25.18 (204236)", style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => _onItemTapped(context, index),
      ),
    );
  }

  Widget _tile(String title, IconData icon, [VoidCallback? onTap]) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(title),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }


  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 0, 8),
      child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
    );
  }
}
