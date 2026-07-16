import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/food_item_model.dart';

class RestaurantViewModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. Naya Food Item Add Karne Ka Function
  Future<String?> addFoodItem({
    required String name,
    required String description,
    required double price,
  }) async {
    try {
      String currentUserId = _auth.currentUser!.uid;

      // Auto-generated ID nikalna Firestore se
      DocumentReference docRef = _firestore.collection('food_items').doc();

      FoodItemModel newItem = FoodItemModel(
        id: docRef.id,
        name: name,
        description: description,
        price: price,
        restaurantId: currentUserId,
      );

      // Firestore mein save karna
      await docRef.set(newItem.toMap());
      return null; // Success!
    } catch (e) {
      return e.toString();
    }
  }

  // 2. Sirf Is Particular Restaurant Ke Food Items Stream Se Read Karna (Real-time updates)
  Stream<List<FoodItemModel>> getRestaurantMenu() {
    String currentUserId = _auth.currentUser?.uid ?? '';
    return _firestore
        .collection('food_items')
        .where('restaurantId', isEqualTo: currentUserId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => FoodItemModel.fromMap(doc.data())).toList();
    });
  }
}