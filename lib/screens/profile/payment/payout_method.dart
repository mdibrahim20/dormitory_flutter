import 'package:flutter/material.dart';

class PayoutMethodsPage extends StatelessWidget {
  final List<Map<String, String>> payoutMethods = [
    {'type': 'Bank Account', 'details': '****1234'},
    {'type': 'PayPal', 'details': 'user@example.com'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payout Methods', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: ListView(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Text('Your payout methods',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          ...payoutMethods.map((method) => ListTile(
            leading: Icon(Icons.account_balance),
            title: Text('${method['type']}'),
            subtitle: Text(method['details']!),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Navigate to edit payout method
            },
          )),
          ListTile(
            leading: Icon(Icons.add),
            title: Text('Add payout method'),
            onTap: () {
              // Navigate to add payout method
            },
          ),
        ],
      ),
    );
  }
}
