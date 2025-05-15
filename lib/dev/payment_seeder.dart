import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> seedDummyPayment() async {
  final paymentData = {
    'dormitory_id': 'hotel123',
    'user_id': 'test_user_123',
    'payment_method': 'stripe',
    'transaction_id': 'txn_1234567890',
    'amount': 405,
    'currency': 'USD',
    'status': 'success',
    'created_at': Timestamp.now(),
  };

  await FirebaseFirestore.instance.collection('payments').add(paymentData);
  print("✅ Dummy payment seeded.");
}
