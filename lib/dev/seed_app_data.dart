// lib/utils/seed_app_data.dart
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> seedAppData() async {
  final firestore = FirebaseFirestore.instance;

  await firestore.collection('announcements').doc('main').set({
    'text': '🔥 Get 10% off on all bookings this weekend!',
    'created_at': FieldValue.serverTimestamp(),
  });

  final banners = [
    {
      'image_url': 'https://images.unsplash.com/photo-1582719478181-c4f99b451bfa?auto=compress&cs=tinysrgb&w=600',
      'caption': 'Live by the Beach 🌊',
    },
    {
      'image_url': 'https://images.unsplash.com/photo-1589395937772-b26f7a07685e?auto=compress&cs=tinysrgb&w=600',
      'caption': 'Mountain Getaways ⛰️',
    },
    {
      'image_url': 'https://images.unsplash.com/photo-1565182999561-18d7dc61c393?auto=compress&cs=tinysrgb&w=600',
      'caption': 'Cozy City Stays 🏙️',
    },
  ];

  for (var banner in banners) {
    await firestore.collection('banners').add(banner);
  }

  final branches = [
    {
      'name': 'Dhaka Central',
      'image_url': 'https://images.unsplash.com/photo-1582719478181-c4f99b451bfa?auto=compress&cs=tinysrgb&w=600',
    },
    {
      'name': 'Uttara Elite',
      'image_url': 'https://images.unsplash.com/photo-1589395937772-b26f7a07685e?auto=compress&cs=tinysrgb&w=600',
    },
    {
      'name': 'Gulshan View',
      'image_url': 'https://images.unsplash.com/photo-1565182999561-18d7dc61c393?auto=compress&cs=tinysrgb&w=600',
    },
  ];

  for (var branch in branches) {
    await firestore.collection('branches').add(branch);
  }

  print('✅ Firestore seeded successfully!');
}
