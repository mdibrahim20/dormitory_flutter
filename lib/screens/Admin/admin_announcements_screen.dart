import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAnnouncementsScreen extends StatefulWidget {
  const AdminAnnouncementsScreen({Key? key}) : super(key: key);

  @override
  _AdminAnnouncementsScreenState createState() => _AdminAnnouncementsScreenState();
}

class _AdminAnnouncementsScreenState extends State<AdminAnnouncementsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _textController = TextEditingController();
  DocumentReference? _editingDoc;

  void _showAnnouncementDialog({DocumentSnapshot? doc}) {
    if (doc != null) {
      final data = doc.data() as Map<String, dynamic>;
      _editingDoc = doc.reference;
      _textController.text = data['text'] ?? '';
    } else {
      _editingDoc = null;
      _textController.clear();
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
                  doc != null ? 'Edit Announcement' : 'Add New Announcement',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _textController,
                  decoration: const InputDecoration(labelText: 'Announcement Text'),
                  validator: (value) => value == null || value.isEmpty ? 'Please enter announcement text' : null,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveAnnouncement,
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

  Future<void> _saveAnnouncement() async {
    if (_formKey.currentState!.validate()) {
      final data = {
        'text': _textController.text.trim(),
        'created_at': FieldValue.serverTimestamp(),
        'status': 'active',
      };

      if (_editingDoc != null) {
        await _editingDoc!.update(data);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Announcement updated')),
        );
      } else {
        await FirebaseFirestore.instance.collection('announcements').add(data);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Announcement added')),
        );
      }

      _textController.clear();
      _editingDoc = null;
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _deleteAnnouncement(String docId) async {
    await FirebaseFirestore.instance.collection('announcements').doc(docId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Announcement deleted')),
    );
  }

  Future<void> _toggleStatus(DocumentReference docRef, String currentStatus) async {
    final newStatus = currentStatus == 'active' ? 'inactive' : 'active';
    await docRef.update({'status': newStatus});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Status changed to $newStatus')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Announcements'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('announcements').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No announcements found.'));
          }

          final announcements = snapshot.data!.docs;

          return ListView.builder(
            itemCount: announcements.length,
            itemBuilder: (context, index) {
              final announcement = announcements[index];
              final data = announcement.data() as Map<String, dynamic>;
              final status = data['status'] ?? 'active';
              final createdAt = (data['created_at'] as Timestamp?)?.toDate();

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(data['text'] ?? ''),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Status: $status'),
                      Text('Created at: ${createdAt != null ? createdAt.toString() : 'Not set'}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          status == 'active' ? Icons.toggle_on : Icons.toggle_off,
                          color: status == 'active' ? Colors.green : Colors.grey,
                          size: 32,
                        ),
                        onPressed: () => _toggleStatus(announcement.reference, status),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showAnnouncementDialog(doc: announcement),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteAnnouncement(announcement.id),
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
        onPressed: () => _showAnnouncementDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
