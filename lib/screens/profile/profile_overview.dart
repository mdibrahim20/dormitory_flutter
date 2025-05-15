import 'package:flutter/material.dart';
import 'personal_info_screen.dart';
import 'payments_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/identity_verification_screen.dart';
class ProfileOverview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Anna", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: Colors.black),
        actions: [
          TextButton(onPressed: () {}, child: Text("Edit", style: TextStyle(color: Colors.black)))
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(radius: 32, backgroundColor: Colors.black, child: Text("A", style: TextStyle(color: Colors.white))),
                SizedBox(height: 8),
                Text("Anna", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text("Guest", style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          SizedBox(height: 24),
          Text("Anna's confirmed information", style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.check),
              SizedBox(width: 8),
              Text(_maskEmail(FirebaseAuth.instance.currentUser?.email ?? '')),
            ],
          ),

          Divider(height: 32),
          Text("Identity verification", style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text("Show others you’re really you with the identity verification badge."),
          SizedBox(height: 8),
    Align(
    alignment: Alignment.centerLeft,
    child: OutlinedButton.icon(
    onPressed: () {
    Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => IdentityVerificationScreen()),
    );
    },
    icon: Icon(Icons.verified_user_outlined),
    label: Text("Get the badge"),
    ),
    ),
          Divider(height: 32),
          Text("It's time to create your profile", style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text("Your Airbnb profile is an important part of every reservation."),
          SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {},
            child: Text("Create profile"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              shape: StadiumBorder(),
              padding: EdgeInsets.symmetric(vertical: 14),
            ),
          ),
          SizedBox(height: 20),
          ListTile(
            title: Text("Personal info"),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PersonalInfoScreen())),
          ),
          ListTile(
            title: Text("Payments & payouts"),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PaymentsScreen())),
          ),
        ],
      ),
    );

  }
}
String _maskEmail(String email) {
  final parts = email.split('@');
  if (parts[0].length <= 2) return '***@${parts[1]}';
  return '${parts[0].substring(0, 2)}***@${parts[1]}';
}

