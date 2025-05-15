import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> seedBookings() async {
  final dormsSnapshot = await FirebaseFirestore.instance
      .collection('dormitories')
      .get();

  if (dormsSnapshot.docs.isEmpty) {
    print('❌ No dormitories found! Run seedDormitories() first.');
    return;
  }

  final bookingsRef = FirebaseFirestore.instance.collection('bookings');

  for (var dorm in dormsSnapshot.docs) {
    final dormitoryId = dorm.id;

    // Add some fake bookings for this dorm
    await bookingsRef.add({
      'dormitory_id': dormitoryId,
      'start_date': Timestamp.fromDate(DateTime.now().add(Duration(days: 5))),
      'end_date': Timestamp.fromDate(DateTime.now().add(Duration(days: 8))),
    });

    await bookingsRef.add({
      'dormitory_id': dormitoryId,
      'start_date': Timestamp.fromDate(DateTime.now().add(Duration(days: 15))),
      'end_date': Timestamp.fromDate(DateTime.now().add(Duration(days: 18))),
    });
  }

  print('✅ Bookings seeded for all dormitories!');
}
