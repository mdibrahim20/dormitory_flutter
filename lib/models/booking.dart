import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  final String id;
  final String dormitoryId;
  final String userName;
  final String? contactInfo;
  final String? paymentStatus;
  final DateTime startDate;
  final DateTime endDate;

  Booking({
    required this.id,
    required this.dormitoryId,
    required this.userName,
    this.contactInfo,
    required this.startDate,
    required this.endDate,
    required this.paymentStatus,
  });

  factory Booking.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Booking(
      id: doc.id,
      dormitoryId: data['dormitory_id'],
      userName: data['user_name'],
      contactInfo: data['contact_info'],
      paymentStatus: data['payment_status'],
      startDate: (data['start_date'] as Timestamp).toDate(),
      endDate: (data['end_date'] as Timestamp).toDate(),

    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dormitory_id': dormitoryId,
      'user_name': userName,
      'contact_info': contactInfo ?? '',
      'start_date': Timestamp.fromDate(startDate),
      'end_date': Timestamp.fromDate(endDate),
      'payment_status': paymentStatus
    };
  }

}
