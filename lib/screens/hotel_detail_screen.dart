import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'reservation_screen.dart';

class HotelDetailScreen extends StatefulWidget {
  final DocumentSnapshot data;

  const HotelDetailScreen({super.key, required this.data});

  @override
  State<HotelDetailScreen> createState() => _HotelDetailScreenState();
}

class _HotelDetailScreenState extends State<HotelDetailScreen> {
  bool hasPayment = false;
  Map<String, String> categoryNames = {};
  Map<String, String> branchNames = {};
  Map<String, String> apartmentNames = {};
  String? selectedRoomNumber;

  @override
  void initState() {
    super.initState();
    checkPaymentStatus();
    fetchAdditionalDetails();
  }

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

  Future<void> fetchAdditionalDetails() async {
    final dormData = widget.data.data() as Map<String, dynamic>;

    final catSnap = await FirebaseFirestore.instance
        .collection('categories')
        .doc(dormData['category_id'])
        .get();
    final branchSnap = await FirebaseFirestore.instance
        .collection('branches')
        .doc(dormData['branch_id'])
        .get();
    final aptSnap = await FirebaseFirestore.instance
        .collection('apartments')
        .doc(dormData['apartment_id'])
        .get();

    setState(() {
      categoryNames[dormData['category_id']] = catSnap.data()?['name'] ?? 'N/A';
      branchNames[dormData['branch_id']] = branchSnap.data()?['name'] ?? 'N/A';
      apartmentNames[dormData['apartment_id']] = aptSnap.data()?['apartment_name'] ?? 'N/A';
    });
  }

  LatLng extractLatLng(String url) {
    final uri = Uri.parse(url);
    final query = uri.queryParameters['q'];
    if (query != null) {
      final parts = query.split(',');
      if (parts.length == 2) {
        return LatLng(double.parse(parts[0]), double.parse(parts[1]));
      }
    }
    return LatLng(23.8103, 90.4125);
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final dormData = data.data() as Map<String, dynamic>;
    final List<dynamic> images = [dormData['image_url'], ...?dormData['additional_images']];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          dormData['name'],
          style: GoogleFonts.poppins(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CarouselSlider(
              options: CarouselOptions(height: 250, autoPlay: true),
              items: images.map((i) => Image.network(i, fit: BoxFit.cover, width: double.infinity)).toList(),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(dormData['name'], style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Room in ${dormData['location']}', style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[700])),
                  const SizedBox(height: 10),
                  Text('Category: ${categoryNames[dormData['category_id']] ?? '...'}'),
                  Text('Branch: ${branchNames[dormData['branch_id']] ?? '...'}'),
                  Text('Apartment: ${apartmentNames[dormData['apartment_id']] ?? '...'}'),
                  Text('Room Number: ${dormData['room_number']}'),
                  const Divider(height: 32),

                  _sectionTitle(Icons.info_outline, "About this place"),
                  Text(dormData['about'] ?? "No description available"),

                  if (dormData['sleep_info'] != null && dormData['sleep_info'] is List) ...[
                    const SizedBox(height: 24),
                    _sectionTitle(Icons.bed, "Where you’ll sleep"),
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: (dormData['sleep_info'] as List).length,
                        itemBuilder: (context, index) {
                          final item = (dormData['sleep_info'] as List)[index];
                          return _sleepCard(item);
                        },
                      ),
                    ),
                  ],

                  if (dormData['amenities'] != null && dormData['amenities'] is List) ...[
                    const SizedBox(height: 24),
                    _sectionTitle(Icons.room_service, "What this place offers"),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List<Widget>.from(
                        (dormData['amenities'] as List).map(
                              (item) => Chip(label: Text(item.toString())),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),
                  if (dormData['location_map_url'] != null && dormData['location_map_url'].toString().isNotEmpty)
                    SizedBox(
                      height: 200,
                      child: FlutterMap(
                        options: MapOptions(
                          center: extractLatLng(dormData['location_map_url']),
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
                                point: extractLatLng(dormData['location_map_url']),
                                child: const Icon(Icons.location_pin, size: 40, color: Colors.red),
                              )
                            ],
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      height: 200,
                      color: Colors.grey[300],
                      alignment: Alignment.center,
                      child: const Text("Map Not Available"),
                    ),

                  if (dormData['house_rules'] != null && dormData['house_rules'] is List) ...[
                    const SizedBox(height: 24),
                    _sectionTitle(Icons.rule, "House Rules"),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List<Widget>.from(
                        (dormData['house_rules'] as List).map((rule) => Text('- $rule')),
                      ),
                    ),
                  ],

                  if (dormData['safety'] != null && dormData['safety'] is List) ...[
                    const SizedBox(height: 24),
                    _sectionTitle(Icons.security, "Safety & Property"),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List<Widget>.from(
                        (dormData['safety'] as List).map((safety) => Text('- $safety')),
                      ),
                    ),
                  ],
                  const SizedBox(height: 100),
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
                  "\৳${dormData['price']}",
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text("per night.", style: GoogleFonts.poppins(fontSize: 14, color: Colors.black)),
              ],
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => _checkIfAlreadyBookedAndNavigate(context),
              child: Text("Reserve", style: GoogleFonts.poppins(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _sleepCard(dynamic item) {
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
          Text(item.toString(), textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  static Widget _sectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.black54),
        const SizedBox(width: 8),
        Text(title, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  void _checkIfAlreadyBookedAndNavigate(BuildContext context) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please login first.')));
      return;
    }

    final today = DateTime.now();
    final query = await FirebaseFirestore.instance
        .collection('bookings')
        .where('user_id', isEqualTo: userId)
        .where('dormitory_id', isEqualTo: widget.data.id)
        .where('end_date', isGreaterThanOrEqualTo: Timestamp.fromDate(today))
        .get();

    if (query.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You already have an active booking.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReservationScreen(data: widget.data),
      ),
    );
  }
}
