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
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text('Coupon Management'),
        backgroundColor: Colors.blue.shade800,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCouponDialog(),
        icon: const Icon(Icons.add),
        label: const Text("Add Coupon"),
        backgroundColor: Colors.blue.shade800,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<QuerySnapshot>(
          stream: coupons.orderBy('created_at', descending: true).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

            final docs = snapshot.data!.docs;
            if (docs.isEmpty) {
              return const Center(
                child: Text(
                  'No coupons found.',
                  style: TextStyle(color: Colors.grey),
                ),
              );
            }

            return ListView.separated(
              itemCount: docs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final doc = docs[index];
                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    title: Text(
                      doc['code'],
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${doc['discount']}% discount"),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: doc['is_active'] ? Colors.green[100] : Colors.red[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            doc['is_active'] ? "Active" : "Inactive",
                            style: TextStyle(
                              color: doc['is_active'] ? Colors.green[800] : Colors.red[800],
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blueAccent),
                          onPressed: () => _showCouponDialog(doc: doc),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => _deleteCoupon(doc),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

}
