import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'reservation_screen.dart';
class HotelDetailScreen extends StatefulWidget {
  final DocumentSnapshot data;

  const HotelDetailScreen({super.key, required this.data});

  @override
  State<HotelDetailScreen> createState() => _HotelDetailScreenState();
}

class _HotelDetailScreenState extends State<HotelDetailScreen> {
  @override
  void initState() {
    super.initState();
    checkPaymentStatus();
  }

  bool hasPayment = false;


  Future<void> checkPaymentStatus() async {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? "guest_user";
    final paymentSnapshot = await FirebaseFirestore.instance
        .collection('payments')
        .where('dormitory_id', isEqualTo: widget.data.id)
        .where('user_id', isEqualTo: userId)
        .where('status', isEqualTo: 'success')
        .limit(1)
        .get();

    setState(() {
      hasPayment = paymentSnapshot.docs.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;

    LatLng extractLatLng(String url) {
      final uri = Uri.parse(url);
      final query = uri.queryParameters['q'];
      if (query != null) {
        final parts = query.split(',');
        if (parts.length == 2) {
          return LatLng(double.parse(parts[0]), double.parse(parts[1]));
        }
      }
      // fallback if parsing fails
      return LatLng(23.8103, 90.4125);
    }


    return Scaffold(
      appBar: AppBar(
        title: Text(data['name']),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 250,
              child: PageView.builder(
                itemCount: 5,
                itemBuilder: (context, index) {
                  return Image.network(
                    data['image_url'],
                    fit: BoxFit.cover,
                    width: double.infinity,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data['name'], style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)),
                  Text('Room in ${data['location']}',
                      style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                  const SizedBox(height: 8),
                  const Text('2 queen beds · Shared bathroom'),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.black, size: 18),
                      const SizedBox(width: 4),
                      Text('${data['rating']} · 478 reviews'),
                    ],
                  ),
                  const Divider(height: 32),
                  Row(
                    children: [
                      const CircleAvatar(backgroundImage: NetworkImage(
                          'https://i.pravatar.cc/300'), radius: 30),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Hosted by ${data['host_name']}",
                              style: const TextStyle(fontWeight: FontWeight
                                  .bold)),
                          Text("Superhost · ${data['host_duration']}"),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text("About this place", style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 8),
                  Text(data['about'] ?? "No description available"),
                  const SizedBox(height: 24),
                  const SizedBox(height: 8),
                  if (data['sleep_info'] != null && data['sleep_info'] is List)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Where you’ll sleep", style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 120,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: (data['sleep_info'] as List).length,
                            itemBuilder: (context, index) {
                              final item = (data['sleep_info'] as List)[index];
                              return _sleepCard(item);
                            },
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 24),
                  const SizedBox(height: 8),
                  if (data['amenities'] != null && data['amenities'] is List)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("What this place offers", style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: List<Widget>.from(
                            (data['amenities'] as List).map(
                                  (item) => Chip(label: Text(item.toString())),
                            ),
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 24),
                  const Text("Where you’ll be", style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 8),
                  if (data['location_map_url'] != null &&
                      data['location_map_url'].toString().isNotEmpty)
                    SizedBox(
                      height: 200,
                      child: FlutterMap(
                        options: MapOptions(
                          center: extractLatLng(data['location_map_url']),
                          zoom: 15,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                            subdomains: ['a', 'b', 'c'],
                            userAgentPackageName: 'com.yourcompany.yourapp',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                width: 80,
                                height: 80,
                                point: extractLatLng(data['location_map_url']),
                                child: Icon(
                                  Icons.location_pin,
                                  size: 40,
                                  color: Colors.red,
                                ),
                              )
                            ],
                          ),
                        ],
                      )
                    )
                  else
                    Container(
                      height: 200,
                      color: Colors.grey[300],
                      alignment: Alignment.center,
                      child: const Text("Map Not Available"),
                    ),

                  const SizedBox(height: 24),
                  if (data['house_rules'] != null &&
                      data['house_rules'] is List)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("House Rules", style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                        const SizedBox(height: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List<Widget>.from(
                            (data['house_rules'] as List).map(
                                  (rule) => Text('- $rule'),
                            ),
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 24),
                  if (data['safety'] != null && data['safety'] is List)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Safety & Property", style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                        const SizedBox(height: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List<Widget>.from(
                            (data['safety'] as List).map(
                                  (safety) => Text('- $safety'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 100),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "\$${data['price']}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  "per night.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () => _checkIfAlreadyBookedAndNavigate(context),
              child: const Text("Reserve"),
            ),

          ],
        ),
      ),


    );
  }

  static Widget _sleepCard(dynamic item) {
    String keyText = "";
    String valueText = "";

    if (item is String && item.contains("{") && item.contains("}")) {
      // Clean and split: "{bed: 1 queen bed}" → "bed: 1 queen bed"
      final cleaned = item.replaceAll("{", "").replaceAll("}", "");
      final parts = cleaned.split(":");
      if (parts.length >= 2) {
        keyText = parts[0].trim();
        valueText = parts.sublist(1).join(":").trim();  // just in case value has ":"
      } else {
        valueText = item;
      }
    } else if (item is Map && item.isNotEmpty) {
      keyText = item.keys.first.toString();
      valueText = item.values.first.toString();
    } else {
      valueText = item.toString();
    }

    return Container(
      width: 120,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.bed, size: 28),
          const SizedBox(height: 8),
          Text(
            keyText.isNotEmpty ? '$keyText: $valueText' : valueText,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _checkIfAlreadyBookedAndNavigate(BuildContext context) async {
  print('✅ Reserve button pressed');
  final userId = FirebaseAuth.instance.currentUser?.uid;
  print('✅ currentUser: $userId');

  if (userId == null) {
  ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(content: Text('Please login first.')),
  );
  return;
  }

  final today = DateTime.now();
  try {
  print("👉 Querying bookings...");
  final query = await FirebaseFirestore.instance
      .collection('bookings')
      .where('user_id', isEqualTo: userId)
      .where('dormitory_id', isEqualTo: widget.data.id)
      .where('end_date', isGreaterThanOrEqualTo: Timestamp.fromDate(today))
      .get();

  print('✅ existingBookings count: ${query.docs.length}');

  if (query.docs.isNotEmpty) {
  ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(content: Text('You already have an active booking.')),
  );
  return;
  }

  print('✅ No active bookings → Navigating to ReservationScreen');
  Navigator.push(
  context,
  MaterialPageRoute(
  builder: (context) => ReservationScreen(data: widget.data),
  ),
  );
  } catch (e) {
  print('❌ Error in booking check: $e');
  ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(content: Text('An error occurred. Please try again.')),
  );
  }
  }





  static Widget _iconText(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}
