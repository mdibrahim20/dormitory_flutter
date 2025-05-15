import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // Register user with email and password
  Future<User?> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    final userCred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    final user = userCred.user;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set({
        'user_id': user.uid,
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'preferred_name': '',
        'phone': '',
        'address': '',
        'emergency_contact': '',
        'identity_verification': 'Not started',
        'role': 'student',
        'created_at': Timestamp.now(),
      });
    }

    return user;
  }

  // Log in user
  Future<User?> loginUser({
    required String email,
    required String password,
  }) async {
    final userCred = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
    return userCred.user;
  }

  // Get current user profile
  Future<Map<String, dynamic>?> getUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;
    return doc.data();
  }

  // Update profile field
  Future<void> updateUserField(String field, dynamic value) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({field: value});
    }
  }

  // Optional: log out
  Future<void> logout() async {
    await _auth.signOut();
  }
}
