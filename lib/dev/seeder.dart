import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> seedDormitories() async {
  final dorms = [
    {
      'name': 'Blue Sky Hostel',
      'location': 'Downtown',
      'image_url': 'https://images.pexels.com/photos/1722183/pexels-photo-1722183.jpeg?auto=compress&cs=tinysrgb&w=600',
      'available': true,
      'price': 1200,
      'host_name': 'Joel',
      'host_duration': 'Hosting for 6 years',
      'rating': 4.86,
      'available_dates': 'Jun 23 - 28',
      'price_for_days': 405,
      'category_id': 'rooms',

      // Dynamic Detail Fields:
      'about': 'A relaxing modern dorm with great Wi-Fi, perfect for remote workers.',
      'sleep_info': [
        { 'area': 'Bedroom area', 'bed': '1 queen bed' },
        { 'area': 'Living area', 'bed': '1 sofa bed' },
      ],
      'amenities': ['WiFi', 'TV', 'Kitchen', 'Air Conditioning', 'Washer'],
      'house_rules': [
        'Check-in: 2:00 PM - 11:00 PM',
        'Checkout before: 11:00 AM',
        'No smoking, No pets'
      ],
      'safety': [
        'Carbon monoxide alarm not reported',
        'Smoke alarm not reported'
      ],
      'location_map_url': 'https://maps.google.com/?q=23.8103,90.4125'
    },
    {
      'name': 'Sunrise Residency',
      'location': 'Uttara',
      'image_url': 'https://images.pexels.com/photos/1722183/pexels-photo-1722183.jpeg?auto=compress&cs=tinysrgb&w=600',
      'available': true,
      'price': 1600,
      'host_name': 'Joel',
      'host_duration': 'Hosting for 6 years',
      'rating': 4.86,
      'available_dates': 'Jun 23 - 28',
      'price_for_days': 405,
      'category_id': 'countryside',

      'about': 'Quiet place with scenic views. Ideal for peaceful stays.',
      'sleep_info': [
        { 'area': 'Bedroom', 'bed': '1 king bed' }
      ],
      'amenities': ['WiFi', 'Kitchen', 'Balcony'],
      'house_rules': [
        'Check-in: 1:00 PM - 10:00 PM',
        'Checkout before: 10:30 AM',
        'No parties allowed'
      ],
      'safety': [
        'Smoke detector installed',
        'First aid kit available'
      ],
      'location_map_url': 'https://maps.google.com/?q=23.7772,90.3995'
    },
  ];

  final dormRef = FirebaseFirestore.instance.collection('dormitories');
  for (var dorm in dorms) {
    await dormRef.add(dorm);
  }

  print('✅ Dormitories with full dynamic detail fields seeded successfully!');
}
