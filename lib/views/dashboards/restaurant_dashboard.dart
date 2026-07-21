import 'package:flutter/material.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/restaurant_viewmodel.dart';
import '../../models/food_item_model.dart';
import '../auth/login_screen.dart';
import 'restaurant_orders_screen.dart';
import 'order_history_screen.dart'; // <--- Added Order History import
import 'profile_screen.dart';        // <--- Added Profile Management import

class RestaurantDashboard extends StatefulWidget {
  const RestaurantDashboard({super.key});

  @override
  State<RestaurantDashboard> createState() => _RestaurantDashboardState();
}

class _RestaurantDashboardState extends State<RestaurantDashboard> {
  final RestaurantViewModel _restaurantViewModel = RestaurantViewModel();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

  bool _isAdding = false;

  void _addItem() async {
    if (_nameController.text.isEmpty || _descriptionController.text.isEmpty || _priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all food details!")),
      );
      return;
    }

    setState(() {
      _isAdding = true;
    });

    double? parsedPrice = double.tryParse(_priceController.text.trim());
    if (parsedPrice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid price number!")),
      );
      setState(() {
        _isAdding = false;
      });
      return;
    }

    String? error = await _restaurantViewModel.addFoodItem(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      price: parsedPrice,
    );

    setState(() {
      _isAdding = false;
    });

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Food Item Added to Menu! 🍔")),
      );
      _nameController.clear();
      _descriptionController.clear();
      _priceController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $error")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Restaurant Panel 🍳"),
        backgroundColor: const Color(0xFF800000),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            tooltip: "Order History",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OrderHistoryScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            tooltip: "My Profile",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.list_alt, color: Colors.white),
            tooltip: "Incoming Orders",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RestaurantOrdersScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await AuthViewModel().signOutUser();
              if (!context.mounted) return;
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Add New Dish to Menu 🍕",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF800000)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Dish Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description / Ingredients', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Price (Rs.)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isAdding ? null : _addItem,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF800000),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: _isAdding
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Add Item to Menu", style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
            const Divider(height: 32, thickness: 2),
            const Text(
              "Your Current Menu 📋",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<List<FoodItemModel>>(
                stream: _restaurantViewModel.getRestaurantMenu(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("No items added yet. Add your first dish!"));
                  }

                  final menuItems = snapshot.data!;
                  return ListView.builder(
                    itemCount: menuItems.length,
                    itemBuilder: (context, index) {
                      final item = menuItems[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(item.description),
                          trailing: Text("Rs. ${item.price}", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}