// lib/screens/success_screen.dart
import 'package:flutter/material.dart';

class SuccessScreen extends StatelessWidget {
  final String paymentId;
  const SuccessScreen({Key? key, required this.paymentId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Payment Success")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 100),
            const SizedBox(height: 20),
            const Text("Payment Complete!", style: TextStyle(fontSize: 24)),
            const SizedBox(height: 10),
            Text("Payment ID: $paymentId"),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst); // go back to home
              },
              child: const Text("Go to Home"),
            )
          ],
        ),
      ),
    );
  }
}
