import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CouponAdminPage extends StatefulWidget {
  const CouponAdminPage({Key? key}) : super(key: key);

  @override
  State<CouponAdminPage> createState() => _CouponAdminPageState();
}

class _CouponAdminPageState extends State<CouponAdminPage> {
  final CollectionReference coupons = FirebaseFirestore.instance.collection('coupons');

  void _showCouponDialog({DocumentSnapshot? doc}) {
    final TextEditingController codeController = TextEditingController(text: doc?['code'] ?? '');
    final TextEditingController discountController = TextEditingController(text: doc?['discount']?.toString() ?? '');
    bool isActive = doc?['is_active'] ?? true;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(doc == null ? 'Add Coupon' : 'Edit Coupon'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: codeController,
                decoration: const InputDecoration(labelText: 'Coupon Code'),
              ),
              TextField(
                controller: discountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Discount %'),
              ),
              Row(
                children: [
                  Checkbox(
                    value: isActive,
                    onChanged: (value) {
                      setState(() {
                        isActive = value ?? true;
                      });
                      Navigator.of(context).pop();
                      _showCouponDialog(doc: doc); // Refresh dialog
                    },
                  ),
                  const Text('Active'),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          ElevatedButton(
            child: const Text('Save'),
            onPressed: () async {
              String code = codeController.text.trim();
              int discount = int.tryParse(discountController.text.trim()) ?? 0;

              if (code.isEmpty || discount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Code and discount must be valid')),
                );
                return;
              }

              if (doc == null) {
                await coupons.add({
                  'code': code,
                  'discount': discount,
                  'is_active': isActive,
                  'created_at': Timestamp.now(),
                });
              } else {
                await coupons.doc(doc.id).update({
                  'code': code,
                  'discount': discount,
                  'is_active': isActive,
                });
              }

              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void _deleteCoupon(DocumentSnapshot doc) async {
    await coupons.doc(doc.id).delete();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Coupon deleted')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Coupon Management')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCouponDialog(),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: coupons.orderBy('created_at', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('No coupons found'));

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              return Card(
                child: ListTile(
                  title: Text('${doc['code']} (${doc['discount']}% off)'),
                  subtitle: Text(doc['is_active'] ? 'Active' : 'Inactive'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit), onPressed: () => _showCouponDialog(doc: doc)),
                      IconButton(icon: const Icon(Icons.delete), onPressed: () => _deleteCoupon(doc)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
