import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../views/dashboards/customer_dashboard.dart';
import '../views/dashboards/restaurant_dashboard.dart';
import '../views/dashboards/rider_dashboard.dart';

class AuthViewModel {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void redirectUser(String role, BuildContext context) {
    if (role == 'Customer') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const CustomerDashboard()));
    } else if (role == 'Restaurant') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const RestaurantDashboard()));
    } else if (role == 'Rider') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const RiderDashboard()));
    } else {
      print("Unknown role: $role");
    }
  }

  Future<String?> signUpUser({
    required String name,
    required String email,
    required String password,
    required String role,
    required BuildContext context,
  }) async {
    // --- Email & Password Validation ---
    if (name.trim().isEmpty) {
      return "Please enter your name.";
    }

    // Proper email format check using RegExp
    bool emailValid = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(email.trim());
    if (!emailValid) {
      return "Please enter a valid email address (e.g. user@gmail.com).";
    }

    if (password.length < 6) {
      return "Password must be at least 6 characters long.";
    }
    // ------------------------------------

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      String uid = userCredential.user!.uid;

      UserModel newUser = UserModel(
        uid: uid,
        name: name.trim(),
        email: email.trim(),
        role: role,
      );

      await _firestore.collection('users').doc(uid).set(newUser.toMap());

      if (context.mounted) {
        redirectUser(role, context);
      }
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> loginUser({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    // --- Login Validation ---
    bool emailValid = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(email.trim());
    if (!emailValid) {
      return "Please enter a valid email address.";
    }
    if (password.isEmpty) {
      return "Please enter your password.";
    }
    // ------------------------

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists) {
        String role = userDoc['role'];
        if (context.mounted) {
          redirectUser(role, context);
        }
        return null;
      } else {
        return "User data not found in database.";
      }
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> signOutUser() async {
    await _auth.signOut();
  }
}