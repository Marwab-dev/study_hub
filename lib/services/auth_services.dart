import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // =========================
  // REGISTER
  // =========================
  Future<User?> register(String text, String , {
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      if (user != null) {
        await _firestore.collection("users").doc(user.uid).set({
          "uid": user.uid,
          "name": name,
          "email": email,
          "points": 0,
          "createdAt": FieldValue.serverTimestamp(),
        });
      }

      return user;
    } catch (e) {
      print("REGISTER ERROR: $e");
      rethrow;
    }
  }

  // =========================
  // LOGIN
  // =========================
  Future<User?> login({required String email, required String password}) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return result.user;
    } catch (e) {
      print("LOGIN ERROR: $e");
      rethrow;
    }
  }

  // =========================
  // LOGOUT
  // =========================
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print("LOGOUT ERROR: $e");
      rethrow;
    }
  }

  // =========================
  // CURRENT USER
  // =========================
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // =========================
  // STREAM USER STATE
  // =========================
  Stream<User?> authState() {
    return _auth.authStateChanges();
  }
}
