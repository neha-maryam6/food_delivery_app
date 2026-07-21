import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Order History 📜"),
        backgroundColor: const Color(0xFF800000),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No past orders found."));
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final data = order.data() as Map<String, dynamic>;
              final orderId = order.id;
              final status = data['status'] ?? 'completed';
              final total = data['total'] ?? 0.0;
              final address = data['address'] ?? '';
              final items = List<String>.from(data['items'] ?? []);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Order ID: ${orderId.substring(0, 6)}...",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          Chip(
                            label: Text(
                              status.toUpperCase(),
                              style: const TextStyle(color: Colors.white, fontSize: 10),
                            ),
                            backgroundColor: status == 'delivered' || status == 'completed'
                                ? Colors.green
                                : Colors.orange,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text("Items: ${items.join(', ')}"),
                      const SizedBox(height: 4),
                      Text("Delivery Address: $address"),
                      const SizedBox(height: 6),
                      Text(
                        "Total Amount: Rs. $total",
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF800000)),
                      ),
                    ],
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