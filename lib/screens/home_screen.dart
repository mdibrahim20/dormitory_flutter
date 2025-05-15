import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'hotel_detail_screen.dart';
import 'wishlist_screen.dart';
import '../Widget/app_bottom_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String searchQuery = '';
  String? selectedCategoryId;
  final user = FirebaseAuth.instance.currentUser;

  final dormRef = FirebaseFirestore.instance.collection('dormitories');
  final categoryRef = FirebaseFirestore.instance.collection('categories');
  final bannerRef = FirebaseFirestore.instance.collection('banners');
  final branchRef = FirebaseFirestore.instance.collection('branches');
  final announcementRef = FirebaseFirestore.instance.collection('announcements');
  final wishlistRef = FirebaseFirestore.instance.collection('wishlists');
  int _selectedIndex = 0;

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
        Navigator.pushReplacementNamed(context, '/trips');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/messages');
        break;
      case 4:
        if (user != null) {
          Navigator.pushReplacementNamed(context, '/profile');
        } else {
          Navigator.pushReplacementNamed(context, '/login');
        }
        break;
    }
  }
  Future<bool> isInWishlist(String dormId) async {
    if (user == null) return false;
    final snapshot = await wishlistRef
        .where('user_id', isEqualTo: user!.uid)
        .where('dormitory_id', isEqualTo: dormId)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  void toggleWishlist(String dormId, Map<String, dynamic> dormData) async {
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please login first.")),
      );
      return;
    }

    final snapshot = await wishlistRef
        .where('user_id', isEqualTo: user!.uid)
        .where('dormitory_id', isEqualTo: dormId)
        .get();

    if (snapshot.docs.isNotEmpty) {
      await wishlistRef.doc(snapshot.docs.first.id).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Removed from wishlist ❌")),
      );
    } else {
      await wishlistRef.add({
        'user_id': user!.uid,
        'dormitory_id': dormId,
        'added_at': FieldValue.serverTimestamp(),
      });

      showWishlistSavedSheet(context, dormData);
    }

    setState(() {}); // Refresh UI
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.white,
        elevation: 1,
        title: TextField(
          decoration: InputDecoration(
            hintText: 'Start your search',
            prefixIcon: Icon(Icons.search),
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: (value) {
            setState(() {
              searchQuery = value.toLowerCase();
            });
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            StreamBuilder<DocumentSnapshot>(
              stream: announcementRef.doc('main').snapshots(),
              builder: (_, snap) {
                if (!snap.hasData || !snap.data!.exists) return SizedBox();
                final data = snap.data!.data() as Map<String, dynamic>;
                return Container(
                  color: Colors.yellow.shade100,
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  child: Text(data['text'] ?? '', style: TextStyle(color: Colors.black87)),
                );
              },
            ),
            SizedBox(
              height: 240,
              child: StreamBuilder<QuerySnapshot>(
                stream: bannerRef.snapshots(),
                builder: (_, snap) {
                  if (!snap.hasData) return Center(child: CircularProgressIndicator());
                  final banners = snap.data!.docs;
                  return PageView.builder(
                    itemCount: banners.length,
                    itemBuilder: (_, index) {
                      final bannerData = banners[index].data() as Map<String, dynamic>;
                      final imageUrl = bannerData['image_url'];
                      final caption = bannerData['caption'] ?? '';

                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                  color: Colors.black.withOpacity(0.5),
                                  child: Text(
                                    caption,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: StreamBuilder<QuerySnapshot>(
                stream: branchRef.snapshots(),
                builder: (_, snap) {
                  if (!snap.hasData) return SizedBox();
                  final branches = snap.data!.docs;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: branches.take(3).map((branch) {
                      return Expanded(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 5),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(branch['image_url'], height: 80, fit: BoxFit.cover),
                              ),
                              SizedBox(height: 5),
                              Text(branch['name'], style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: categoryRef.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return SizedBox();
                final categories = snapshot.data!.docs;
                return SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    itemBuilder: (_, index) {
                      final category = categories[index];
                      final isSelected = selectedCategoryId == category.id;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedCategoryId = isSelected ? null : category.id;
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.only(right: 16),
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.redAccent : Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _getIconData(category['icon']),
                                size: 28,
                                color: isSelected ? Colors.white : Colors.black,
                              ),
                              SizedBox(height: 6),
                              Text(
                                category['name'],
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected ? Colors.white : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),

                      );
                    },
                  ),
                );
              },
            ),
            StreamBuilder<QuerySnapshot>(
              stream: dormRef.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();
                final dorms = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = data['name']?.toString().toLowerCase() ?? '';
                  final matchesSearch = name.contains(searchQuery);
                  final matchesCategory = selectedCategoryId == null || data['category_id'] == selectedCategoryId;
                  return matchesSearch && matchesCategory;
                }).toList();

                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: dorms.length,
                  padding: EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final dorm = dorms[index];
                    return FutureBuilder<bool>(
                      future: isInWishlist(dorm.id),
                      builder: (context, snapshot) {
                        final isWishlisted = snapshot.data ?? false;
                        return _buildDormCard(dorm, isWishlisted);
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),

    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'king_bed':
        return Icons.king_bed;
      case 'star_border':
        return Icons.star_border;
      case 'park':
        return Icons.park;
      case 'bolt':
        return Icons.bolt;
      case 'location_city':
        return Icons.location_city;
      default:
        return Icons.category;
    }
  }

  void showWishlistSavedSheet(BuildContext context, Map<String, dynamic> dorm) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      builder: (_) {
        // Auto dismiss after 3 seconds
        Future.delayed(Duration(seconds: 3), () => Navigator.of(context).pop());

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: SizedBox(
              width: double.infinity,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      dorm['image_url'],
                      height: 50,
                      width: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Saved to Bed & breakfasts",
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                        SizedBox(height: 2),
                        Text("2025", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      // handle 'Change' action here
                    },
                    child: Text("Change",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            decoration: TextDecoration.underline)),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }





  Widget _buildDormCard(QueryDocumentSnapshot dorm, bool isWishlisted) {
    final data = dorm.data() as Map<String, dynamic>;
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => HotelDetailScreen(data: dorm)));
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                  BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    data['image_url'],
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () => toggleWishlist(
                        dorm.id, dorm.data() as Map<String, dynamic>),
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(
                        isWishlisted
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: isWishlisted ? Colors.red : Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['name'],
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.grey),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          data['location'] ?? '',
                          style: TextStyle(
                              color: Colors.grey[600], fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "\$${data['price_for_days']} total",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      Row(
                        children: [
                          Icon(Icons.star,
                              size: 16, color: Colors.orangeAccent),
                          SizedBox(width: 4),
                          Text(
                            data['rating'].toString(),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}
