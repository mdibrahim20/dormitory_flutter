import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminPaymentsScreen extends StatefulWidget {
  const AdminPaymentsScreen({Key? key}) : super(key: key);

  @override
  State<AdminPaymentsScreen> createState() => _AdminPaymentsScreenState();
}

class _AdminPaymentsScreenState extends State<AdminPaymentsScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedBookingId;
  String _transactionId = '';
  String _paymentMethod = '';
  String _currency = 'USD';
  String _status = 'success';
  double? _amount;
  DocumentReference? _editingDoc;

  // 👇 New filter state
  String _filter = 'all'; // all, paid, unpaid

  Future<void> _fetchBookingDetails(String bookingId) async {
    final bookingDoc = await FirebaseFirestore.instance.collection('bookings').doc(bookingId).get();
    if (!bookingDoc.exists) return;

    final bookingData = bookingDoc.data()!;
    final dormitoryId = bookingData['dormitory_id'];
    final dormDoc = await FirebaseFirestore.instance.collection('dormitories').doc(dormitoryId).get();
    final dormData = dormDoc.data() ?? {};

    final pricePerDay = (dormData['price_per_day'] ?? 0).toDouble();
    final startDate = (bookingData['start_date'] as Timestamp).toDate();
    final endDate = (bookingData['end_date'] as Timestamp).toDate();
    final days = endDate.difference(startDate).inDays + 1;
    final calculatedAmount = days * pricePerDay;

    if (!mounted) return;
    setState(() {
      _transactionId = 'TXN${DateTime.now().millisecondsSinceEpoch}';
      _paymentMethod = 'Credit Card';
      _currency = 'USD';
      _status = 'success';
      _amount = calculatedAmount as double?;
    });
  }

  void _showPaymentDialog({DocumentSnapshot? doc}) {
    if (doc != null) {
      final data = doc.data() as Map<String, dynamic>;
      _editingDoc = doc.reference;
      _selectedBookingId = data['booking_id'];
      _transactionId = data['transaction_id'] ?? '';
      _paymentMethod = data['payment_method'] ?? '';
      _currency = data['currency'] ?? 'USD';
      _status = data['status'] ?? 'success';
      _amount = (data['amount'] ?? 0).toDouble();
    } else {
      _editingDoc = null;
      _selectedBookingId = null;
      _transactionId = '';
      _paymentMethod = '';
      _currency = 'USD';
      _status = 'success';
      _amount = null;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 24,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Text(doc != null ? 'Edit Payment' : 'Add Payment',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('bookings')
                      .where('payment_status', isEqualTo: 'unpaid')
                      .get(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const CircularProgressIndicator();
                    final bookings = snapshot.data!.docs;
                    return DropdownButtonFormField<String>(
                      value: _selectedBookingId,
                      decoration: const InputDecoration(labelText: 'Booking'),
                      items: bookings.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return DropdownMenuItem<String>(
                          value: doc.id,
                          child: Text('${data['user_name'] ?? 'User'}'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedBookingId = value;
                        });
                        if (value != null) {
                          _fetchBookingDetails(value);
                        }
                      },
                      validator: (value) => value == null ? 'Please select a booking' : null,
                    );
                  },
                ),
                TextFormField(
                  initialValue: _transactionId,
                  decoration: const InputDecoration(labelText: 'Transaction ID'),
                  onChanged: (value) => _transactionId = value,
                  validator: (value) => value == null || value.isEmpty ? 'Enter transaction ID' : null,
                ),
                TextFormField(
                  initialValue: _paymentMethod,
                  decoration: const InputDecoration(labelText: 'Payment Method'),
                  onChanged: (value) => _paymentMethod = value,
                  validator: (value) => value == null || value.isEmpty ? 'Enter payment method' : null,
                ),
                TextFormField(
                  initialValue: _currency,
                  decoration: const InputDecoration(labelText: 'Currency'),
                  onChanged: (value) => _currency = value,
                  validator: (value) => value == null || value.isEmpty ? 'Enter currency' : null,
                ),
                DropdownButtonFormField<String>(
                  value: _status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: ['success', 'failed', 'pending']
                      .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                      .toList(),
                  onChanged: (value) => _status = value!,
                ),
                TextFormField(
                  initialValue: _amount?.toString(),
                  decoration: const InputDecoration(labelText: 'Amount'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => _amount = double.tryParse(value),
                  validator: (value) => value == null || value.isEmpty ? 'Enter amount' : null,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _savePayment,
                  child: Text(doc != null ? 'Update' : 'Add'),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _savePayment() async {
    if (_formKey.currentState!.validate()) {
      final data = {
        'booking_id': _selectedBookingId,
        'transaction_id': _transactionId,
        'payment_method': _paymentMethod,
        'currency': _currency,
        'status': _status,
        'amount': _amount,
        'created_at': FieldValue.serverTimestamp(),
      };

      if (_editingDoc != null) {
        await _editingDoc!.update(data);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment updated')));
      } else {
        await FirebaseFirestore.instance.collection('payments').add(data);
        if (_selectedBookingId != null) {
          await FirebaseFirestore.instance.collection('bookings').doc(_selectedBookingId).update({
            'payment_status': 'paid',
          });
        }
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment added')));
      }

      _editingDoc = null;
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _deletePayment(String docId) async {
    await FirebaseFirestore.instance.collection('payments').doc(docId).delete();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment deleted')));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payments'),
        actions: [
          TextButton(
            onPressed: () => setState(() => _filter = 'all'),
            child: const Text('All', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () => setState(() => _filter = 'paid'),
            child: const Text('Payment Done', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () => setState(() => _filter = 'unpaid'),
            child: const Text('Pending', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('payments')
            .orderBy('created_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final allPayments = snapshot.data!.docs;

          // 👇 Filter logic
          final payments = _filter == 'all'
              ? allPayments
              : allPayments.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final status = data['status'] ?? '';
            if (_filter == 'paid') {
              return status == 'success';
            } else if (_filter == 'unpaid') {
              return status == 'pending' || status == 'failed';
            }
            return true;
          }).toList();
          return ListView.builder(
            itemCount: payments.length,
            itemBuilder: (context, index) {
              final doc = payments[index];
              final data = doc.data() as Map<String, dynamic>;
              final createdAt = (data['created_at'] as Timestamp?)?.toDate();

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(
                    'Booking: ${data['booking_id']} | \$${data['amount']} ${data['currency']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Transaction ID: ${data['transaction_id']}'),
                      Text('Payment Method: ${data['payment_method']}'),
                      Text('Status: ${data['status']}'),
                      Text(
                        'Date: ${createdAt != null ? createdAt.toLocal().toString().split('.')[0] : 'N/A'}',
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showPaymentDialog(doc: doc),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deletePayment(doc.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPaymentDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
