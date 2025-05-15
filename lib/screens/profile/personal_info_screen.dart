import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PersonalInfoScreen extends StatefulWidget {
  @override
  _PersonalInfoScreenState createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final user = FirebaseAuth.instance.currentUser;

  Future<void> _editField(String field, String currentValue) async {
    final controller = TextEditingController(text: currentValue);

    final newValue = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit $field"),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: field),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),

          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text("Save"),
          ),

        ],
      ),
    );

    if (newValue != null && newValue != currentValue) {
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({field: newValue});
      setState(() {}); // refresh the UI
    }
  }

  Widget _infoRow(String label, String field, String value) {
    final isProvided = value.trim().isNotEmpty;
    return ListTile(
      title: Text(label),
      subtitle: Text(isProvided ? value : 'Not provided'),
      trailing: TextButton(
        onPressed: () => _editField(field, value),
        child: Text(isProvided ? 'Edit' : 'Add', style: TextStyle(color: Colors.blue)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Center(child: Text("User not logged in"));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Personal info", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: Colors.black),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(user!.uid).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};

          return ListView(
            children: [
              _infoRow("Legal name", "name", data["name"] ?? ''),
              _infoRow("Preferred first name", "preferred_name", data["preferred_name"] ?? ''),
              _infoRow("Phone number", "phone", data["phone"] ?? ''),
              _infoRow("Email", "email", data["email"] ?? user!.email ?? ''),
              _infoRow("Address", "address", data["address"] ?? ''),
              _infoRow("Emergency contact", "emergency_contact", data["emergency_contact"] ?? ''),
              _infoRow("Identity verification", "identity_verification", data["identity_verification"] ?? 'Not started'),
            ],
          );
        },
      ),
    );
  }
}
