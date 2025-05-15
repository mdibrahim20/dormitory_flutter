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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: Colors.blue.shade800,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.pushNamed(context, '/admin_notifications');
            },
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Quick Actions", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
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
                _adminButton(context, Icons.announcement, "Announcements", '/admin_announcements'),
                _adminButton(context, Icons.announcement, "Payments", '/admin_payments'),
                _adminButton(context, Icons.announcement, "Coupons", '/admin_coupons'),
                _adminButton(context, Icons.announcement, "Apartment", '/admin_apartments'),
              ],
            ),
            const SizedBox(height: 24),
            const Text("Statistics", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: [
                _statsCard(context, Icons.announcement, "Announcements", "announcements"),
                _statsCard(context, Icons.hotel, "Dormitories", "dormitories"),
                _statsCard(context, Icons.people, "Users", "users"),
                _statsCard(context, Icons.book_online, "Bookings", "bookings"),
                _statsCard(context, Icons.book_online, "Branches", "branches"),
                _statsCard(context, Icons.book_online, "Category", "categories"),
                _statsCard(context, Icons.book_online, "Banner", "banners"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _adminButton(BuildContext context, IconData icon, String label, String routeName) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, routeName);
      },
      child: Container(
        width: MediaQuery.of(context).size.width / 2 - 24,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Colors.blue.shade800),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(fontSize: 16, color: Colors.blue.shade800, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _statsCard(BuildContext context, IconData icon, String title, String collectionName) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<int>(
          future: _getCollectionCount(collectionName),
          builder: (context, snapshot) {
            String count = snapshot.connectionState == ConnectionState.waiting
                ? '...'
                : snapshot.hasData
                ? snapshot.data.toString()
                : '0';
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 36, color: Colors.blue.shade800),
                const SizedBox(height: 12),
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(count, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ],
            );
          },
        ),
      ),
    );
  }
}
