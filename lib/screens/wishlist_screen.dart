import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Widget/app_bottom_nav_bar.dart';
import 'hotel_detail_screen.dart';

class WishlistScreen extends StatefulWidget {
  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final user = FirebaseAuth.instance.currentUser;
  final _noteController = TextEditingController();

  void _showAddNoteSheet(BuildContext context, DocumentSnapshot dorm) {
    final data = dorm.data() as Map<String, dynamic>;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  data['image_url'],
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 10),
              Text('Hotel room in ${data['location']}',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text('${data['name']}', style: TextStyle(color: Colors.grey[700])),
              Text('Saved for May 8 - 13', style: TextStyle(color: Colors.grey)),
              Text('\৳${data['price_for_days']} for 5 nights',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              TextField(
                controller: _noteController,
                decoration: InputDecoration(
                  hintText: 'Write a note...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Note saved! (not really, just mocked 🤷‍♂️)")),
                    );
                  },
                  child: Text("Save Note"),
                ),
              ),
              Divider(),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Wishlist')),
        body: Center(child: Text('Please log in to view your wishlist.')),
      );
    }

    int _selectedIndex = 1;

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


    return Scaffold(
      appBar: AppBar(title: Text('Wishlist')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('wishlists')
            .where('user_id', isEqualTo: user!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final wishlistDocs = snapshot.data!.docs;
          if (wishlistDocs.isEmpty) return Center(child: Text('Your wishlist is empty.'));

          return ListView.builder(
            itemCount: wishlistDocs.length,
            itemBuilder: (context, index) {
              final wishlistItem = wishlistDocs[index];
              final dormId = wishlistItem['dormitory_id'];

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('dormitories').doc(dormId).get(),
                builder: (context, dormSnapshot) {
                  if (!dormSnapshot.hasData || !dormSnapshot.data!.exists)
                    return SizedBox();

                  final dorm = dormSnapshot.data!;
                  final data = dorm.data() as Map<String, dynamic>;

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HotelDetailScreen(data: dorm),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              data['image_url'],
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text('Hotel room in ${data['location']}',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('${data['name']}', style: TextStyle(color: Colors.grey[700])),
                          Text('Saved for May 8 - 13', style: TextStyle(color: Colors.grey)),
                          Text('\৳${data['price_for_days']} for 5 nights',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: OutlinedButton(
                              onPressed: () => _showAddNoteSheet(context, dorm),
                              child: Text('Add note'),
                            ),
                          ),
                          Divider(),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
