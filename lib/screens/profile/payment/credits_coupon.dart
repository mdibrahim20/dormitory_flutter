import 'package:flutter/material.dart';

class CreditsCouponsPage extends StatelessWidget {
  final List<Map<String, String>> coupons = [
    {'code': 'WELCOME50', 'description': '\$50 off your first booking'},
    {'code': 'SUMMER20', 'description': '20% off summer stays'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Credits & Coupons', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: ListView(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Text('Available Coupons',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          ...coupons.map((coupon) => ListTile(
            title: Text(coupon['code']!),
            subtitle: Text(coupon['description']!),
            trailing: TextButton(
              onPressed: () {
                // Redeem coupon
              },
              child: Text('Redeem'),
            ),
          )),
          ListTile(
            leading: Icon(Icons.add),
            title: Text('Add a coupon'),
            onTap: () {
              // Navigate to add coupon
            },
          ),
        ],
      ),
    );
  }
}
