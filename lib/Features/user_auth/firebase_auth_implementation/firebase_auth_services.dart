import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../global/common/toast.dart';


class FirebaseAuthService {

  FirebaseAuth _auth = FirebaseAuth.instance;
  //FirebaseAuth auth = FirebaseAuth.instance;
  // _auth.setPersistence(Persistence.LOCAL);
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> getUserRole(String uid) async {
    try {
      // Get the user document from Firestore
      DocumentSnapshot userDoc =
      await _firestore.collection('users').doc(uid).get();

      // Check if the user document exists and contains the 'role' field
      if (userDoc.exists && userDoc.data() != null) {
        return userDoc['role'];
      } else {
        return 'unknown';
      }
    } catch (e) {
      print('Error getting user role: $e');
      return 'unknown';
    }
  }
  Future<User?> signUpWithEmailAndPassword(String email,
      String password) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return credential.user;
    }
    on FirebaseAuthException catch (e) {

      if (e.code == 'email-already-in-use') {
        showToast(message: 'The email address is already in use.');
      } else {
        showToast(message: 'An error occurred: ${e.code}');
      }
    }
    return null;
  }

  Future<User?> signInWithEmailAndPassword(String email, String password) async {

    try {
      UserCredential credential =await _auth.signInWithEmailAndPassword(email: email, password: password);
      return credential.user;
    }on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        showToast(message: 'Invalid email or password.');
      } else {
        showToast(message: 'An error occurred: ${e.code}');
      }

    }
    return null;

  }

  String getCurrentUserId() {
    User? user = _auth.currentUser;
    return user?.uid ?? '';
  }
}
