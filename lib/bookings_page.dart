// lib/bookings_page.dart

import 'package:flutter/material.dart';

class BookingsPage extends StatelessWidget {
  const BookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // This is just another name for the "My Orders" page
    // We will reuse the OrdersPage widget here later.
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
      ),
      body: const Center(
        child: Text('Your upcoming and past bookings will appear here.'),
      ),
    );
  }
}
