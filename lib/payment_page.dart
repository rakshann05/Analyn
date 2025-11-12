import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'app_theme.dart'; 
import 'main.dart'; 
import 'package:intl/intl.dart';

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

  Future<void> _confirmBooking() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() { _isLoading = true; });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not logged in.');

      final scheduledDateTime = DateTime(
        widget.scheduledDate.year,
        widget.scheduledDate.month,
        widget.scheduledDate.day,
        widget.scheduledTime.hour,
        widget.scheduledTime.minute,
      );
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('orders')
          .add({
        'userId': user.uid,
        'serviceId': widget.service.id,
        'serviceName': widget.service.name,
        'serviceImageUrl': widget.service.imageUrl,
        'duration': widget.service.duration,
        'price': widget.service.price,
        'address': widget.deliveryAddress,
        'scheduledAt': Timestamp.fromDate(scheduledDateTime),
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment booked successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        // Go all the way back to the root (the Services page)
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
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Confirm Booking'),
        backgroundColor: AppTheme.background,
        elevation: 0,
        foregroundColor: AppTheme.darkText,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionHeader(textTheme, 'Booking Summary'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.calendar_today, color: AppTheme.accent),
              title: Text(DateFormat('EEE, MMM d, yyyy').format(widget.scheduledDate)),
              subtitle: Text(widget.scheduledTime.format(context)),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.location_on, color: AppTheme.accent),
              title: Text(widget.deliveryAddress),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.asset(
                  widget.service.imageUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(widget.service.name),
              subtitle: Text(widget.service.duration),
              trailing: Text(
                '₹${widget.service.price.toStringAsFixed(0)}',
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(textTheme, 'Enter Card Details'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Card Number'),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(labelText: 'MM/YY'),
                            keyboardType: TextInputType.datetime,
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(labelText: 'CVV'),
                            keyboardType: TextInputType.number,
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _isLoading ? null : _confirmBooking,
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                    'Pay ₹${widget.service.price.toStringAsFixed(0)}',
                  ),
          )
        ],
      ),
    );
  }

  Widget _buildSectionHeader(TextTheme textTheme, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, left: 4.0),
      child: Text(
        title,
        style: textTheme.headlineMedium,
      ),
    );
  }
}