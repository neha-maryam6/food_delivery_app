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
b
  // Sahi Dashboard par bhejne ka function
  void redirectUser(String role, BuildContext context) {
    if (role == 'Customer') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const CustomerDashboard()));
    } else if (role == 'Restaurant') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const RestaurantDashboard()));
    } else if (role == 'Rider') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const RiderDashboard()));
    }
  }

  // 1. Sign Up Logic
  Future<String?> signUpUser({
    required String name,
    required String email,
    required String password,
    required String role,
    required BuildContext context, // Context add kiya redirection ke liye
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;

      UserModel newUser = UserModel(
        uid: uid,
        name: name,
        email: email,
        role: role,
      );

      await _firestore.collection('users').doc(uid).set(newUser.toMap());

      // Kamyabi ke baad direct screen badal do
      if (context.mounted) {
        redirectUser(role, context);
      }
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // 2. Login Logic
  Future<String?> loginUser({
    required String email,
    required String password,
    required BuildContext context, // Context add kiya redirection ke liye
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Database se user ka role check karna
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
    } catch (e) {
      return e.toString();
    }
  }

  // 3. Sign Out Logic
  Future<void> signOutUser() async {
    await _auth.signOut();
  }
}