import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../models/food_item_model.dart';
import '../auth/login_screen.dart';
import 'cart_screen.dart';
import 'order_tracking_screen.dart';
import 'order_history_screen.dart';
import 'profile_screen.dart';
import 'rating_screen.dart';

class CustomerDashboard extends StatefulWidget {
  const CustomerDashboard({super.key});

  @override
  State<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard> {
  List<FoodItemModel> cartItems = [];

  void placeOrder(String address) async {
    // --- City Validation (Only Lahore allowed, Burewala restricted) ---
    String lowerAddress = address.toLowerCase();
    if (!lowerAddress.contains('lahore')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Delivery available in Lahore only! (Burewala not supported) ❌"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    // ----------------------------------------------------------------

    DocumentReference docRef = await FirebaseFirestore.instance.collection('orders').add({
      'items': cartItems.map((item) => item.name).toList(),
      'total': cartItems.fold(0.0, (sum, item) => sum + item.price),
      'address': address,
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    });

    setState(() => cartItems.clear());

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderTrackingScreen(orderId: docRef.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Delicious Food 🍕 (Lahore)"),
        backgroundColor: const Color(0xFF800000),
        actions: [
          // Yahan orderId pass kar di hai taake error khatam ho jaye
          IconButton(
            icon: const Icon(Icons.star_rate),
            tooltip: "Rate Us",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RatingScreen(orderId: "general_rating"),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: "Order History",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OrderHistoryScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: "My Profile",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CartScreen(cartItems: cartItems, onPlaceOrder: placeOrder),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthViewModel().signOutUser();
              if (!mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          )
        ],
      ),
      // --- Menu Sorted by Price (Lowest to Highest) ---
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('items')
            .orderBy('price', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final foodDocs = snapshot.data!.docs;

          if (foodDocs.isEmpty) {
            return const Center(child: Text("No food items available."));
          }

          return ListView.builder(
            itemCount: foodDocs.length,
            itemBuilder: (context, index) {
              final foodItem = FoodItemModel.fromMap(foodDocs[index].data() as Map<String, dynamic>);
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Text(foodItem.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Rs. ${foodItem.price}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.add_shopping_cart, color: Color(0xFF800000)),
                    onPressed: () {
                      setState(() => cartItems.add(foodItem));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("${foodItem.name} added!")),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}