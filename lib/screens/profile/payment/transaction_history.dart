import 'package:flutter/material.dart';

class TransactionHistoryPage extends StatelessWidget {
  final List<Map<String, String>> transactions = [
    {'date': '2025-05-01', 'description': 'Booking payout', 'amount': '\$120.00'},
    {'date': '2025-04-20', 'description': 'Refund', 'amount': '-\$50.00'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transaction History', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: ListView.separated(
        itemCount: transactions.length,
        separatorBuilder: (context, index) => Divider(),
        itemBuilder: (context, index) {
          final transaction = transactions[index];
          return ListTile(
            title: Text(transaction['description']!),
            subtitle: Text(transaction['date']!),
            trailing: Text(transaction['amount']!),
            onTap: () {
              // Navigate to transaction details
            },
          );
        },
      ),
    );
  }
}
