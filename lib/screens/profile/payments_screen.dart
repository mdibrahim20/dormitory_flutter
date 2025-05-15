import 'package:flutter/material.dart';
import 'payment/credits_coupon.dart';
import 'payment/payment_history.dart';
import 'payment/payment_method.dart';
import 'payment/transaction_history.dart';
import 'payment/payout_method.dart';
class PaymentsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Payments & payouts", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: Colors.black),
        actions: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text("\$ - USD", style: TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Text("Traveling", style: TextStyle(fontWeight: FontWeight.bold)),
          ListTile(
            leading: Icon(Icons.account_balance_wallet_outlined),
            title: Text("Payment methods"),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PaymentMethodsPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.list),
            title: Text("Your payments"),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => YourPaymentsPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.card_giftcard),
            title: Text("Credits & coupons"),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CreditsCouponsPage()),
              );
            },
          ),
          SizedBox(height: 20),
          Text("Hosting", style: TextStyle(fontWeight: FontWeight.bold)),
          ListTile(
            leading: Icon(Icons.payments_outlined),
            title: Text("Payout methods"),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PayoutMethodsPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.receipt_long_outlined),
            title: Text("Transaction history"),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TransactionHistoryPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}

