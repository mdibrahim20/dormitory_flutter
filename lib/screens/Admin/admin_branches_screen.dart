import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminBranchesScreen extends StatefulWidget {
  const AdminBranchesScreen({Key? key}) : super(key: key);

  @override
  _AdminBranchesScreenState createState() => _AdminBranchesScreenState();
}

class _AdminBranchesScreenState extends State<AdminBranchesScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  DocumentReference? _editingDoc;

  void _showBranchDialog({DocumentSnapshot? doc}) {
    if (doc != null) {
      final data = doc.data() as Map<String, dynamic>;
      _editingDoc = doc.reference;
      _nameController.text = data['name'] ?? '';
      _imageUrlController.text = data['image_url'] ?? '';
    } else {
      _editingDoc = null;
      _nameController.clear();
      _imageUrlController.clear();
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
                  doc != null ? 'Edit Branch' : 'Add New Branch',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Branch Name'),
                  validator: (value) => value == null || value.isEmpty ? 'Please enter branch name' : null,
                ),
                TextFormField(
                  controller: _imageUrlController,
                  decoration: const InputDecoration(labelText: 'Image URL'),
                  validator: (value) => value == null || value.isEmpty ? 'Please enter image URL' : null,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveBranch,
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

  Future<void> _saveBranch() async {
    if (_formKey.currentState!.validate()) {
      final data = {
        'name': _nameController.text.trim(),
        'image_url': _imageUrlController.text.trim(),
      };

      if (_editingDoc != null) {
        await _editingDoc!.update(data);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Branch updated')),
        );
      } else {
        await FirebaseFirestore.instance.collection('branches').add(data);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Branch added')),
        );
      }

      _nameController.clear();
      _imageUrlController.clear();
      _editingDoc = null;
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _deleteBranch(String docId) async {
    await FirebaseFirestore.instance.collection('branches').doc(docId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Branch deleted successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Branches'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('branches').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final branches = snapshot.data!.docs;

          return ListView.builder(
            itemCount: branches.length,
            itemBuilder: (context, index) {
              final branch = branches[index];
              final data = branch.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: data['image_url'] != null && data['image_url'].toString().isNotEmpty
                      ? Image.network(
                    data['image_url'],
                    width: 60,
                    fit: BoxFit.cover,
                  )
                      : const Icon(Icons.image, size: 60),
                  title: Text(data['name'] ?? ''),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showBranchDialog(doc: branch),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteBranch(branch.id),
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
        onPressed: () => _showBranchDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
