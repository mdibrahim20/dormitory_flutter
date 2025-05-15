import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> seedCategories() async {
  final categories = [
    {"id": "rooms", "name": "Rooms", "icon": "king_bed"},
    {"id": "icons", "name": "Icons", "icon": "star_border"},
    {"id": "countryside", "name": "Countryside", "icon": "park"},
    {"id": "omg", "name": "OMG!", "icon": "bolt"},
    {"id": "top_cities", "name": "Top Cities", "icon": "location_city"},
  ];

  final ref = FirebaseFirestore.instance.collection('categories');
  for (var cat in categories) {
    await ref.doc(cat['id']).set(cat);
  }

  print('✅ Categories seeded successfully!');
}
