import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/booking.dart';

class BookingService {
  final CollectionReference bookingsRef = FirebaseFirestore.instance.collection('bookings');

  // ✅ Stream live bookings
  Stream<List<Booking>> streamBookings() {
    return bookingsRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Booking(
          id: doc.id,
          dormitoryId: data['dormitory_id'],
          userName: data['user_name'] ?? '',
          paymentStatus: data['payment_status'] ?? 'unpaid',
          contactInfo: data['contact_info'] ?? '',
          startDate: (data['start_date'] as Timestamp).toDate(),
          endDate: (data['end_date'] as Timestamp).toDate(),
        );
      }).toList();
    });
  }

  // ✅ Check conflicts and return list of conflicts
  Future<List<Booking>> getConflictingBookings({
    required String dormitoryId,
    required DateTime startDate,
    required DateTime endDate,
    String? excludeBookingId,
  }) async {
    final query = await bookingsRef
        .where('dormitory_id', isEqualTo: dormitoryId)
        .get();

    final conflicts = query.docs.where((doc) {
      if (excludeBookingId != null && doc.id == excludeBookingId) return false;
      final data = doc.data() as Map<String, dynamic>;
      final docStart = (data['start_date'] as Timestamp).toDate();
      final docEnd = (data['end_date'] as Timestamp).toDate();
      // overlap check
      return !(endDate.isBefore(docStart) || startDate.isAfter(docEnd));
    }).map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Booking(
        id: doc.id,
        dormitoryId: data['dormitory_id'],
        userName: data['user_name'] ?? '',
        paymentStatus: data['payment_status'] ?? 'unpaid',
        contactInfo: data['contact_info'] ?? '',
        startDate: (data['start_date'] as Timestamp).toDate(),
        endDate: (data['end_date'] as Timestamp).toDate(),
      );
    }).toList();

    return conflicts;
  }

  // ✅ Add booking
  Future<void> addBooking(Booking booking) async {
    await bookingsRef.add({
      'dormitory_id': booking.dormitoryId,
      'user_name': booking.userName,
      'payment_status': booking.paymentStatus,
      'contact_info': booking.contactInfo ?? '',
      'start_date': Timestamp.fromDate(booking.startDate),
      'end_date': Timestamp.fromDate(booking.endDate),

    });
  }

  // ✅ Update booking
  Future<void> updateBooking(Booking booking) async {
    await bookingsRef.doc(booking.id).update({
      'dormitory_id': booking.dormitoryId,
      'user_name': booking.userName,
      'contact_info': booking.contactInfo ?? '',
      'start_date': Timestamp.fromDate(booking.startDate),
      'end_date': Timestamp.fromDate(booking.endDate),
      'payment_status': booking.paymentStatus,
    });
  }

  // ✅ Delete booking
  Future<void> deleteBooking(String bookingId) async {
    await bookingsRef.doc(bookingId).delete();
  }
}
