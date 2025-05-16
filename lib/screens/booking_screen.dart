import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'hotel_detail_screen.dart';
import '../Widget/app_bottom_nav_bar.dart';
class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Bookings')),
        body: const Center(child: Text('Please log in to view your bookings.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('user_id', isEqualTo: user!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final bookings = snapshot.data!.docs;

          if (bookings.isEmpty) {
            return const Center(child: Text('No bookings found.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              final data = booking.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.blueAccent.shade100,
                    child: const Icon(Icons.bed, color: Colors.white),
                  ),
                  title: Text(
                    data['user_name'] ?? 'Booking',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        "From ${_formatDate(data['start_date'])} to ${_formatDate(data['end_date'])}",
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: data['payment_status'] == 'paid'
                              ? Colors.green[100]
                              : Colors.orange[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          data['payment_status'].toString().toUpperCase(),
                          style: TextStyle(
                            color: data['payment_status'] == 'paid'
                                ? Colors.green[800]
                                : Colors.orange[800],
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showBookingDetails(context, booking.id, data),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: 2,
        onTap: _onItemTapped,
      ),

    );
  }
  void _onItemTapped(int index) {
    final user = FirebaseAuth.instance.currentUser;
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/wishlist');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/bookings');
        break;
      // case 3:
      //   Navigator.pushReplacementNamed(context, '/messages');
      //   break;
      case 3:
        if (user != null) {
          Navigator.pushReplacementNamed(context, '/profile');
        } else {
          Navigator.pushReplacementNamed(context, '/login');
        }
        break;
    }
  }
  Future<void> _showBookingDetails(BuildContext context, String bookingId, Map<String, dynamic> bookingData) async {
    final dormRef = FirebaseFirestore.instance.collection('dormitories').doc(bookingData['dormitory_id']);
    final dormSnapshot = await dormRef.get();
    final dormData = dormSnapshot.data();

    final paymentSnapshot = await FirebaseFirestore.instance
        .collection('payments')
        .where('booking_id', isEqualTo: bookingId)
        .where('user_id', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .limit(1)
        .get();
    final paymentData = paymentSnapshot.docs.isNotEmpty ? paymentSnapshot.docs.first.data() as Map<String, dynamic> : null;

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          top: 24,
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (dormData != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    dormData['image_url'],
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  dormData['name'] ?? 'Dormitory',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  dormData['location'] ?? '',
                  style: TextStyle(color: Colors.grey[600], fontSize: 15),
                ),
                const Divider(height: 30, thickness: 1),
              ],
              Text(
                "Booking Information",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _infoRow("Guest Name", bookingData['user_name']),
              _infoRow("Dates", "${_formatDate(bookingData['start_date'])} → ${_formatDate(bookingData['end_date'])}"),
              _infoRow("Status", bookingData['payment_status']),
              _infoRow("Payment Method", bookingData['payment_method']),
              if (paymentData != null)
                _infoRow("Amount Paid", "\৳${paymentData['amount']}"),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    backgroundColor: Colors.blueAccent,
                  ),
                  onPressed: () {
                    if (dormSnapshot.exists) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HotelDetailScreen(data: dormSnapshot),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.open_in_new),
                  label: const Text("View Main Post"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$title: ",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value ?? 'N/A'),
          ),
        ],
      ),
    );
  }

  String _formatDate(Timestamp ts) {
    final date = ts.toDate();
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }
}
