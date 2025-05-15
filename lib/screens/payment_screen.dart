// lib/screens/payment_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'success_screen.dart';
import '../Widget/paymentMethod.dart';

class PaymentScreen extends StatelessWidget {
  final String bookingId;
  final double finalPrice;

  const PaymentScreen({super.key, required this.bookingId, required this.finalPrice});

  void _handlePayment(BuildContext context, String method, Map<String, String> details) async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => const AlertDialog(
        title: Text("Processing Payment..."),
        content: SizedBox(height: 80, child: Center(child: CircularProgressIndicator())),
      ),
    );

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("No user logged in!");

      final userId = user.uid;

      final paymentRef = await FirebaseFirestore.instance.collection('payments').add({
        'booking_id': bookingId,
        'user_id': userId,
        'method': method,
        'details': details,
        'amount': finalPrice,
        'currency': 'USD',
        'payment': 'paid',
        'status': 'success',
        'created_at': FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance.collection('bookings').doc(bookingId).update({
        'payment_status': 'paid',
        'payment_method': method,
      });

      Navigator.pop(context); // Close loading dialog
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SuccessScreen(paymentId: paymentRef.id)),
      );
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Payment")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Total Amount: \$${finalPrice.toStringAsFixed(2)}", style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => PaymentMethodModal(
                    onPaymentConfirmed: (method, details) => _handlePayment(context, method, details),
                  ),
                );
              },
              child: const Text("Select Payment Method"),
            ),
          ],
        ),
      ),
    );
  }
}
