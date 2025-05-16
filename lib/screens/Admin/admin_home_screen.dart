import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  Future<int> _getCollectionCount(String collectionName) async {
    final snapshot = await FirebaseFirestore.instance.collection(collectionName).get();
    return snapshot.size;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text("Admin Dashboard", style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => Navigator.pushNamed(context, '/admin_notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/splash', (route) => false);
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _dashboardHeader(user),
              const SizedBox(height: 24),
              const Text("Quick Actions", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _adminButton(context, Icons.hotel, "Dormitories", '/admin_dormitories'),
                  _adminButton(context, Icons.category, "Categories", '/admin_categories_manage'),
                  _adminButton(context, Icons.book_online, "Bookings", '/admin_bookings'),
                  _adminButton(context, Icons.image, "Banners", '/admin_banners'),
                  _adminButton(context, Icons.location_city, "Branches", '/admin_branches'),
                  _adminButton(context, Icons.campaign, "Announcements", '/admin_announcements'),
                  _adminButton(context, Icons.payment, "Payments", '/admin_payments'),
                  _adminButton(context, Icons.card_giftcard, "Coupons", '/admin_coupons'),
                  _adminButton(context, Icons.apartment, "Apartments", '/admin_apartments'),
                ],
              ),
              const SizedBox(height: 32),
              const Text("Statistics Overview", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1,
                children: [
                  _statsCard(context, Icons.campaign, "Announcements", "announcements", Colors.deepOrange),
                  _statsCard(context, Icons.hotel, "Dormitories", "dormitories", Colors.indigo),
                  _statsCard(context, Icons.people, "Users", "users", Colors.teal),
                  _statsCard(context, Icons.book_online, "Bookings", "bookings", Colors.purple),
                  _statsCard(context, Icons.location_city, "Branches", "branches", Colors.cyan),
                  _statsCard(context, Icons.category, "Categories", "categories", Colors.green),
                  _statsCard(context, Icons.image, "Banners", "banners", Colors.amber),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dashboardHeader(User? user) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: Colors.blue.shade800,
          child: const Icon(Icons.admin_panel_settings, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Welcome back, Admin!",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(user?.email ?? "Logged in",
                style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ],
    );
  }

  Widget _adminButton(BuildContext context, IconData icon, String label, String routeName) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, routeName),
      child: Container(
        width: MediaQuery.of(context).size.width / 2 - 24,
        height: 100,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: Colors.blue.shade800),
            const SizedBox(height: 6),
            Text(label,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Colors.blue.shade800)),
          ],
        ),
      ),
    );
  }

  Widget _statsCard(BuildContext context, IconData icon, String title, String collectionName, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<int>(
          future: _getCollectionCount(collectionName),
          builder: (context, snapshot) {
            final count = snapshot.connectionState == ConnectionState.waiting
                ? '...'
                : snapshot.hasData
                ? snapshot.data.toString()
                : '0';
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: color.withOpacity(0.1),
                  radius: 24,
                  child: Icon(icon, size: 28, color: color),
                ),
                const SizedBox(height: 10),
                Text(title,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(count,
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: color)),
              ],
            );
          },
        ),
      ),
    );
  }
}
