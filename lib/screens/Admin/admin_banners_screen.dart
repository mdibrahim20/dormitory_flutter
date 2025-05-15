import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminBannersScreen extends StatefulWidget {
  const AdminBannersScreen({Key? key}) : super(key: key);

  @override
  _AdminBannersScreenState createState() => _AdminBannersScreenState();
}

class _AdminBannersScreenState extends State<AdminBannersScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _captionController = TextEditingController();
  DocumentReference? _editingDoc;

  void _showBannerDialog({DocumentSnapshot? doc}) {
    if (doc != null) {
      final data = doc.data() as Map<String, dynamic>;
      _editingDoc = doc.reference;
      _imageUrlController.text = data['image_url'] ?? '';
      _captionController.text = data['caption'] ?? '';
    } else {
      _editingDoc = null;
      _imageUrlController.clear();
      _captionController.clear();
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
                  doc != null ? 'Edit Banner' : 'Add New Banner',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _imageUrlController,
                  decoration: const InputDecoration(labelText: 'Image URL'),
                  validator: (value) => value == null || value.isEmpty ? 'Please enter image URL' : null,
                ),
                TextFormField(
                  controller: _captionController,
                  decoration: const InputDecoration(labelText: 'Caption'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveBanner,
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

  Future<void> _saveBanner() async {
    if (_formKey.currentState!.validate()) {
      final data = {
        'image_url': _imageUrlController.text.trim(),
        'caption': _captionController.text.trim(),
      };

      if (_editingDoc != null) {
        await _editingDoc!.update(data);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Banner updated')),
        );
      } else {
        await FirebaseFirestore.instance.collection('banners').add(data);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Banner added')),
        );
      }

      _imageUrlController.clear();
      _captionController.clear();
      _editingDoc = null;
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _deleteBanner(String docId) async {
    await FirebaseFirestore.instance.collection('banners').doc(docId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Banner deleted successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Banners'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('banners').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final banners = snapshot.data!.docs;

          return ListView.builder(
            itemCount: banners.length,
            itemBuilder: (context, index) {
              final banner = banners[index];
              final data = banner.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: data['image_url'] != null
                      ? Image.network(
                    data['image_url'],
                    width: 60,
                    fit: BoxFit.cover,
                  )
                      : const Icon(Icons.image, size: 60),
                  title: Text(data['caption'] ?? ''),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showBannerDialog(doc: banner),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteBanner(banner.id),
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
        onPressed: () => _showBannerDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
