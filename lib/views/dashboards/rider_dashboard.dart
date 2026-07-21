import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../auth/login_screen.dart';
import 'rider_earnings_screen.dart';
import 'profile_screen.dart';

class RiderDashboard extends StatelessWidget {
  const RiderDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rider Dashboard 🛵"),
        backgroundColor: const Color(0xFF800000),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_balance_wallet, color: Colors.white),
            tooltip: "Earnings & History",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RiderEarningsScreen()),
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
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await AuthViewModel().signOutUser();
              if (!context.mounted) return;
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
            },
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('status', whereIn: ['pending', 'accepted'])
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No new orders right now."));
          }

          final orderDocs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: orderDocs.length,
            itemBuilder: (context, index) {
              final orderData = orderDocs[index].data() as Map<String, dynamic>;
              final currentStatus = orderData['status'] ?? 'pending';

              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(
                    "Items: ${List<String>.from(orderData['items'] ?? []).join(', ')}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 5),
                      Text("Address: ${orderData['address']}"),
                      Text("Total: Rs. ${orderData['total']}"),
                      const SizedBox(height: 4),
                      Text(
                        "Status: ${currentStatus.toUpperCase()}",
                        style: TextStyle(
                          color: currentStatus == 'accepted' ? Colors.blue : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: currentStatus == 'accepted' ? Colors.blue : Colors.green,
                    ),
                    onPressed: () {
                      String newStatus = currentStatus == 'pending' ? 'accepted' : 'delivered';

                      FirebaseFirestore.instance
                          .collection('orders')
                          .doc(orderDocs[index].id)
                          .update({'status': newStatus});

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            newStatus == 'accepted' ? "Order Accepted!" : "Delivery Completed! ✅",
                          ),
                        ),
                      );
                    },
                    child: Text(
                      currentStatus == 'pending' ? "Accept" : "Mark Delivered",
                      style: const TextStyle(color: Colors.white),
                    ),
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