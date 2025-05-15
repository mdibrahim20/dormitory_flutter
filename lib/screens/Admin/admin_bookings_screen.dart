import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/booking.dart';
import '../../Services/booking_service.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({Key? key}) : super(key: key);

  @override
  _BookingsScreenState createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  final BookingService _bookingService = BookingService();
  final _formKey = GlobalKey<FormState>();

  String? _selectedDormitoryId;
  String _userName = 'admin';
  String _contactInfo = '';
  DateTime? _startDate;
  DateTime? _endDate;
  String? _editingBookingId;

  bool _dateConflict = false;
  String _conflictDates = '';

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final initialDate = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: initialDate,
      lastDate: DateTime(initialDate.year + 5),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _showBookingDialog({Booking? booking}) async {
    if (booking != null) {
      _editingBookingId = booking.id;
      _selectedDormitoryId = booking.dormitoryId;
      _userName = booking.userName;
      _contactInfo = booking.contactInfo ?? '';
      _startDate = booking.startDate;
      _endDate = booking.endDate;
    } else {
      _editingBookingId = null;
      _selectedDormitoryId = null;
      _userName = 'admin';
      _contactInfo = '';
      _startDate = null;
      _endDate = null;
    }

    _dateConflict = false;
    _conflictDates = '';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text(booking != null ? 'Edit Booking' : 'Add Booking'),
            content: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    FutureBuilder<QuerySnapshot>(
                      future: FirebaseFirestore.instance.collection('dormitories').get(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const CircularProgressIndicator();
                        final dorms = snapshot.data!.docs;
                        return DropdownButtonFormField<String>(
                          value: _selectedDormitoryId,
                          decoration: const InputDecoration(labelText: 'Dormitory'),
                          items: dorms.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            return DropdownMenuItem<String>(
                              value: doc.id,
                              child: Text(data['name'] ?? 'No Name'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => _selectedDormitoryId = value);
                          },
                          validator: (value) => value == null ? 'Please select a dormitory' : null,
                        );
                      },
                    ),
                    TextFormField(
                      initialValue: _userName,
                      decoration: const InputDecoration(labelText: 'User Name'),
                      onChanged: (value) => _userName = value,
                      validator: (value) => value == null || value.isEmpty ? 'Enter user name' : null,
                    ),
                    TextFormField(
                      initialValue: _contactInfo,
                      decoration: const InputDecoration(labelText: 'Contact Info'),
                      onChanged: (value) => _contactInfo = value,
                      validator: (value) => value == null || value.isEmpty ? 'Enter contact info' : null,
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _dateConflict ? Colors.red : Colors.grey,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _startDate == null
                                      ? 'Start Date: Not selected'
                                      : 'Start Date: ${_startDate!.toLocal()}'.split(' ')[0],
                                ),
                              ),
                              TextButton(
                                onPressed: () => _selectDate(context, true),
                                child: const Text('Select Start Date'),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _endDate == null
                                      ? 'End Date: Not selected'
                                      : 'End Date: ${_endDate!.toLocal()}'.split(' ')[0],
                                ),
                              ),
                              TextButton(
                                onPressed: () => _selectDate(context, false),
                                child: const Text('Select End Date'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (_dateConflict)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          '⚠️ Conflict with existing bookings: $_conflictDates',
                          style: const TextStyle(color: Colors.red, fontSize: 13),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final paymentStatus = booking?.paymentStatus ?? 'unpaid';

                  if (_formKey.currentState!.validate() &&
                      _startDate != null &&
                      _endDate != null) {
                    if (_startDate!.isAfter(_endDate!)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Start date must be before end date')),
                      );
                      return;
                    }

                    final conflictBookings = await _bookingService.getConflictingBookings(
                      dormitoryId: _selectedDormitoryId!,
                      startDate: _startDate!,
                      endDate: _endDate!,
                      excludeBookingId: _editingBookingId,
                    );

                    if (conflictBookings.isNotEmpty) {
                      setStateDialog(() {
                        _dateConflict = true;
                        _conflictDates = conflictBookings
                            .map((b) =>
                        '${b.startDate.toLocal().toString().split(' ')[0]} - ${b.endDate.toLocal().toString().split(' ')[0]}')
                            .join(', ');
                      });
                      return;
                    }
                    final booking = Booking(
                      id: _editingBookingId ?? '',
                      dormitoryId: _selectedDormitoryId!,
                      paymentStatus:paymentStatus,
                      userName: _userName,
                      contactInfo: _contactInfo,
                      startDate: _startDate!,
                      endDate: _endDate!,
                    );

                    if (_editingBookingId == null) {
                      await _bookingService.addBooking(booking);
                    } else {
                      await _bookingService.updateBooking(booking);
                    }

                    Navigator.pop(context);
                  }
                },
                child: Text(booking != null ? 'Update' : 'Add'),
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bookings')),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection('dormitories').get(),
        builder: (context, dormSnapshot) {
          if (!dormSnapshot.hasData) return const Center(child: CircularProgressIndicator());
          final dormMap = {
            for (var doc in dormSnapshot.data!.docs)
              doc.id: (doc.data() as Map<String, dynamic>)['name'] ?? 'Unknown'
          };

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('bookings').snapshots(),
            builder: (context, bookingSnapshot) {
              if (!bookingSnapshot.hasData) return const Center(child: CircularProgressIndicator());
              final docs = bookingSnapshot.data!.docs;
              if (docs.isEmpty) return const Center(child: Text('No bookings found.'));

              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  final dormitoryId = data['dormitory_id'] ?? '';
                  final dormitoryName = dormMap[dormitoryId] ?? 'Unknown Dormitory';
                  final userName = data['user_name'] ?? 'Unknown';
                  final contactInfo = data['contact_info'] ?? 'Unknown';
                  final startDate = data['start_date'] != null
                      ? (data['start_date'] as Timestamp).toDate()
                      : null;
                  final endDate = data['end_date'] != null
                      ? (data['end_date'] as Timestamp).toDate()
                      : null;

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text(dormitoryName),
                      subtitle: Text(
                        'User: $userName\n'
                            'Contact: $contactInfo\n'
                            'From: ${startDate != null ? startDate.toLocal().toString().split(' ')[0] : 'N/A'} '
                            'To: ${endDate != null ? endDate.toLocal().toString().split(' ')[0] : 'N/A'}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              final paymentStatus = data['payment_status'] ?? 'unpaid';
                              final booking = Booking(
                                id: docs[index].id,
                                dormitoryId: dormitoryId,
                                userName: userName,
                                contactInfo: contactInfo,
                                startDate: startDate ?? DateTime.now(),
                                endDate: endDate ?? DateTime.now(), paymentStatus: paymentStatus,
                              );
                              _showBookingDialog(booking: booking);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              await docs[index].reference.delete();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Booking deleted')),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showBookingDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
