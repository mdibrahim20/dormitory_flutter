import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminApartmentScreen extends StatefulWidget {
  const AdminApartmentScreen({Key? key}) : super(key: key);

  @override
  State<AdminApartmentScreen> createState() => _AdminApartmentScreenState();
}

class _AdminApartmentScreenState extends State<AdminApartmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _roomsController = TextEditingController();
  DocumentReference? _editingDoc;

  void _showApartmentDialog({DocumentSnapshot? doc}) {
    if (doc != null) {
      final data = doc.data() as Map<String, dynamic>;
      _editingDoc = doc.reference;
      _nameController.text = data['apartment_name'] ?? '';
      _roomsController.text = (data['room_numbers'] as List<dynamic>?)?.join(', ') ?? '';
    } else {
      _editingDoc = null;
      _nameController.clear();
      _roomsController.clear();
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
                Text(
                  doc != null ? 'Edit Apartment' : 'Add New Apartment',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Apartment Name'),
                  validator: (value) => value == null || value.isEmpty ? 'Enter apartment name' : null,
                ),
                TextFormField(
                  controller: _roomsController,
                  decoration: const InputDecoration(labelText: 'Room Numbers (comma separated)'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveApartment,
                  child: Text(doc != null ? 'Update' : 'Save'),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveApartment() async {
    if (_formKey.currentState!.validate()) {
      final roomList = _roomsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final data = {
        'apartment_name': _nameController.text.trim(),
        'room_numbers': roomList,
      };

      if (_editingDoc != null) {
        await _editingDoc!.update(data);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Apartment updated')),
        );
      } else {
        await FirebaseFirestore.instance.collection('apartments').add(data);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Apartment added')),
        );
      }

      _nameController.clear();
      _roomsController.clear();
      _editingDoc = null;
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _deleteApartment(String docId) async {
    await FirebaseFirestore.instance.collection('apartments').doc(docId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Apartment deleted')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Apartments')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('apartments').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final apartments = snapshot.data!.docs;

          return ListView.builder(
            itemCount: apartments.length,
            itemBuilder: (context, index) {
              final apt = apartments[index];
              final data = apt.data() as Map<String, dynamic>;
              final rooms = (data['room_numbers'] as List<dynamic>?)?.join(', ') ?? 'No rooms';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(data['apartment_name'] ?? ''),
                  subtitle: Text('Rooms: $rooms'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showApartmentDialog(doc: apt),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteApartment(apt.id),
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
        onPressed: () => _showApartmentDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}