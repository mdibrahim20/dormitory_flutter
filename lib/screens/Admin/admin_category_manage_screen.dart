import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminCategoriesScreen extends StatefulWidget {
  const AdminCategoriesScreen({Key? key}) : super(key: key);

  @override
  _AdminCategoriesScreenState createState() => _AdminCategoriesScreenState();
}

class _AdminCategoriesScreenState extends State<AdminCategoriesScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _iconController = TextEditingController();
  DocumentReference? _editingDoc;

  void _clearForm() {
    _editingDoc = null;
    _nameController.clear();
    _iconController.clear();
  }
  Future<void> _saveCategory() async {
    if (_formKey.currentState!.validate()) {
      final category = {
        'name': _nameController.text.trim(),
        'icon': _iconController.text.trim(),
      };

      final ref = FirebaseFirestore.instance.collection('categories');

      if (_editingDoc != null) {
        await _editingDoc!.update(category);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category updated')),
        );
      } else {
        await ref.doc(category['id']).set(category);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category added')),
        );
      }

      _clearForm();
      if (mounted) Navigator.pop(context);
    }
  }

  void _showCategoryForm({DocumentSnapshot? doc}) {
    if (doc != null) {
      final data = doc.data() as Map<String, dynamic>;
      _editingDoc = doc.reference;
      _nameController.text = data['name'] ?? '';
      _iconController.text = data['icon'] ?? '';
    } else {
      _clearForm();
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
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _editingDoc != null ? 'Edit Category' : 'Add New Category',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) => value == null || value.isEmpty ? 'Enter name' : null,
                ),
                TextFormField(
                  controller: _iconController,
                  decoration: const InputDecoration(labelText: 'Icon name'),
                  validator: (value) => value == null || value.isEmpty ? 'Enter icon name' : null,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveCategory,
                  child: Text(_editingDoc != null ? 'Update' : 'Save'),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _deleteCategory(String docId) async {
    await FirebaseFirestore.instance.collection('categories').doc(docId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Category deleted')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Categories')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('categories').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final categories = snapshot.data!.docs;

          if (categories.isEmpty) {
            return const Center(child: Text('No categories yet'));
          }

          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final doc = categories[index];
              final data = doc.data() as Map<String, dynamic>;

              return ListTile(
                leading: const Icon(Icons.category),
                title: Text('${data['name']} (${data['id']})'),
                subtitle: Text('Icon: ${data['icon']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showCategoryForm(doc: doc),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteCategory(doc.id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
