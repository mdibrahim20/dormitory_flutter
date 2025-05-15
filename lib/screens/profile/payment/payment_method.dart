import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentMethodsPage extends StatelessWidget {
  final user = FirebaseAuth.instance.currentUser;

  void _showAddCardModal(BuildContext context) {
    final _cardTypeController = TextEditingController();
    final _cardNumberController = TextEditingController();
    final _expiryController = TextEditingController();
    final _cvvController = TextEditingController();

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Add New Card",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _cardTypeController,
                decoration: InputDecoration(
                  labelText: 'Card Type (Visa, MasterCard)',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _cardNumberController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Card Number',
                  hintText: 'Enter 16 digit number',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _expiryController,
                keyboardType: TextInputType.datetime,
                decoration: InputDecoration(
                  labelText: 'Expiry Date (MM/YY)',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _cvvController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'CVV',
                  hintText: '3 digit CVV',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: StadiumBorder(),
                ),
                onPressed: () async {
                  final type = _cardTypeController.text.trim();
                  final number = _cardNumberController.text.trim();
                  final expiry = _expiryController.text.trim();
                  final cvv = _cvvController.text.trim();

                  if (type.isNotEmpty &&
                      number.isNotEmpty &&
                      expiry.isNotEmpty &&
                      cvv.isNotEmpty &&
                      number.length >= 4 &&
                      user != null) {
                    final last4 = number.substring(number.length - 4);

                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user!.uid)
                        .collection('payment_methods')
                        .add({
                      'type': type,
                      'last4': last4,
                      'expiry': expiry,
                      'cvv': cvv,
                      'created_at': FieldValue.serverTimestamp()
                    });

                    Navigator.pop(context);
                  }
                },
                child: Text("Save Card"),
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text("Payment Methods")),
        body: Center(child: Text("Please login to view your payment methods.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Methods', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .collection('payment_methods')
            .orderBy('created_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final paymentMethods = snapshot.data!.docs;

          return ListView(
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Text('Your saved payment methods',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              if (paymentMethods.isEmpty)
                Center(child: Text("No payment methods saved yet.")),
              ...paymentMethods.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return ListTile(
                  leading: Icon(Icons.credit_card),
                  title: Text('${data['type']} **** ${data['last4']}'),
                  subtitle: Text('Expiry: ${data['expiry']}   CVV: ${data['cvv']}'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await doc.reference.delete();
                    },
                  ),
                );
              }).toList(),
              Divider(),
              ListTile(
                leading: Icon(Icons.add, color: Colors.pink),
                title: Text('Add payment method'),
                onTap: () => _showAddCardModal(context),
              ),
            ],
          );
        },
      ),
    );
  }
}
