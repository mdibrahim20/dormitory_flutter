import 'package:flutter/material.dart';

class YourPaymentsPage extends StatelessWidget {
  final List<Map<String, String>> payments = [
    {'date': '2025-05-01', 'amount': '\$120.00', 'status': 'Completed'},
    {'date': '2025-04-15', 'amount': '\$85.00', 'status': 'Completed'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Payments', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: ListView.separated(
        itemCount: payments.length,
        separatorBuilder: (context, index) => Divider(),
        itemBuilder: (context, index) {
          final payment = payments[index];
          return ListTile(
            title: Text(payment['date']!),
            subtitle: Text(payment['status']!),
            trailing: Text(payment['amount']!),
            onTap: () {
              // Navigate to payment details
            },
          );
        },
      ),
    );
  }
}
