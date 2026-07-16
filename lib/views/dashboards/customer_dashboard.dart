import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../models/food_item_model.dart';
import '../auth/login_screen.dart';
import 'cart_screen.dart';

class CustomerDashboard extends StatefulWidget {
  const CustomerDashboard({super.key});

  @override
  State<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard> {
  List<FoodItemModel> cartItems = [];

  void placeOrder(String address) async {
    await FirebaseFirestore.instance.collection('orders').add({
      'items': cartItems.map((item) => item.name).toList(),
      'total': cartItems.fold(0.0, (sum, item) => sum + item.price),
      'address': address, // Address yahan save ho raha hai
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    });

    setState(() => cartItems.clear());

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Order placed successfully!")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Delicious Food 🍕"),
        backgroundColor: Colors.deepOrange,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => CartScreen(cartItems: cartItems, onPlaceOrder: placeOrder)));
            },
          ),
          IconButton(icon: const Icon(Icons.logout), onPressed: () async {
            await AuthViewModel().signOutUser();
            if (!mounted) return;
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
          })
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('items').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final foodDocs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: foodDocs.length,
            itemBuilder: (context, index) {
              final foodItem = FoodItemModel.fromMap(foodDocs[index].data() as Map<String, dynamic>);
              return Card(
                child: ListTile(
                  title: Text(foodItem.name),
                  subtitle: Text("Rs. ${foodItem.price}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.add_shopping_cart, color: Colors.deepOrange),
                    onPressed: () {
                      setState(() => cartItems.add(foodItem));
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${foodItem.name} added!")));
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