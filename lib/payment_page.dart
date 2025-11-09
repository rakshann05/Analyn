// lib/payment_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main.dart'; // To get the Service class

class PaymentPage extends StatefulWidget {
  final Service service;
  final DateTime scheduledDate;
  final TimeOfDay scheduledTime;
  final String deliveryAddress;

  const PaymentPage({
    super.key,
    required this.service,
    required this.scheduledDate,
    required this.scheduledTime,
    required this.deliveryAddress,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _confirmAndSaveBooking() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      final scheduledDateTime = DateTime(
        widget.scheduledDate.year,
        widget.scheduledDate.month,
        widget.scheduledDate.day,
        widget.scheduledTime.hour,
        widget.scheduledTime.minute,
      );

      await FirebaseFirestore.instance.collection('orders').add({
        'userId': user.uid,
        'serviceId': widget.service.id,
        'serviceName': widget.service.name,
        'price': widget.service.price,
        'scheduledAt': Timestamp.fromDate(scheduledDateTime),
        'address': widget.deliveryAddress,
        'status': 'Booked',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment successful! Your appointment is booked.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to book appointment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String formattedDate = '${widget.scheduledDate.toLocal()}'.split(' ')[0];
    final String formattedTime = widget.scheduledTime.format(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Booking Summary'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: Text(formattedDate),
                      subtitle: Text(formattedTime),
                    ),
                    ListTile(
                      leading: const Icon(Icons.location_on),
                      title: Text(widget.deliveryAddress),
                    ),
                    const Divider(),
                    ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        // --- THIS IS THE CORRECTED PART ---
                        // It now uses Image.asset to load your local image
                        child: Image.asset(widget.service.imageUrl, width: 50, height: 50, fit: BoxFit.cover),
                      ),
                      title: Text(widget.service.name),
                      trailing: Text('₹${widget.service.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('Enter Card Details'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Card Number', border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                        validator: (value) => value!.length < 16 ? 'Enter a valid card number' : null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              decoration: const InputDecoration(labelText: 'MM/YY', border: OutlineInputBorder()),
                              keyboardType: TextInputType.datetime,
                              validator: (value) => value!.isEmpty ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              decoration: const InputDecoration(labelText: 'CVV', border: OutlineInputBorder()),
                              keyboardType: TextInputType.number,
                              validator: (value) => value!.length < 3 ? 'Invalid' : null,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _confirmAndSaveBooking,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text('Pay ₹${widget.service.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),
      ),
    );
  }
}
