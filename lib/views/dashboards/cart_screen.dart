import 'package:flutter/material.dart';
import '../../models/food_item_model.dart';

class CartScreen extends StatelessWidget {
  final List<FoodItemModel> cartItems;
  final Function(String) onPlaceOrder; // String (address) accept karega
  final TextEditingController addressController = TextEditingController();

  CartScreen({super.key, required this.cartItems, required this.onPlaceOrder});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Your Cart"), backgroundColor: Colors.deepOrange),
      body: cartItems.isEmpty
          ? const Center(child: Text("Cart is empty"))
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(cartItems[index].name),
                  trailing: Text("Rs. ${cartItems[index].price}"),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: addressController,
              decoration: const InputDecoration(
                labelText: "Enter Delivery Address",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange, minimumSize: const Size(double.infinity, 50)),
              onPressed: () {
                if (addressController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter address!")));
                  return;
                }
                onPlaceOrder(addressController.text); // Address pass kiya
                Navigator.pop(context);
              },
              child: const Text("Place Order Now", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}