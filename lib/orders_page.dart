// lib/orders_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // A package for formatting dates

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Orders')),
        body: const Center(child: Text('Please log in to see your orders.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
      ),
      // Use a StreamBuilder to listen for real-time updates from Firestore
      body: StreamBuilder<QuerySnapshot>(
        // Create a query to get documents from the 'orders' collection
        // where the 'userId' field matches the current user's ID.
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('userId', isEqualTo: user.uid)
            .orderBy('createdAt', descending: true) // Show newest orders first
            .snapshots(),
        builder: (context, snapshot) {
          // --- Handle Loading State ---
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // --- Handle Error State ---
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong.'));
          }

          // --- Handle Empty State ---
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'You have no past orders.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          // --- Handle Success State ---
          final orders = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final orderData = orders[index].data() as Map<String, dynamic>;

              // Safely get the timestamp and format it
              final Timestamp scheduledTimestamp = orderData['scheduledAt'];
              final String formattedDate = DateFormat('EEE, MMM d, yyyy').format(scheduledTimestamp.toDate());
              final String formattedTime = DateFormat('h:mm a').format(scheduledTimestamp.toDate());

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  leading: const Icon(Icons.receipt_long, color: Colors.blueAccent),
                  title: Text(
                    orderData['serviceName'] ?? 'Unnamed Service',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('$formattedDate at $formattedTime'),
                  trailing: Text(
                    '₹${(orderData['price'] as num).toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
