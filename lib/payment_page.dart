import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart'; // Import for input formatters
import 'app_theme.dart';
import 'main.dart'; // Import for the Service class

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
  final _couponController = TextEditingController();
  bool _isLoading = false;
  bool _isCheckingCoupon = false;

  double _discount = 0.0;
  double _totalPrice = 0.0;
  String? _appliedCoupon;

  @override
  void initState() {
    super.initState();
    _totalPrice = widget.service.price;
  }

  // --- Function to check coupon in Firestore ---
  Future<void> _applyCoupon() async {
    String couponCode = _couponController.text.trim(); // Already uppercase
    if (couponCode.isEmpty) return;

    setState(() {
      _isCheckingCoupon = true;
    });

    try {
      // Search the 'coupons' collection for a matching code
      final query = await FirebaseFirestore.instance
          .collection('coupons')
          .where('code', isEqualTo: couponCode)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        // No coupon found
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid coupon code.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() {
          _discount = 0.0;
          _totalPrice = widget.service.price;
          _appliedCoupon = null;
        });
      } else {
        // Coupon was found!
        final couponData = query.docs.first.data();
        final double discountValue = (couponData['discount'] as num).toDouble();

        setState(() {
          _discount = discountValue;
          _totalPrice = widget.service.price - _discount;
          if (_totalPrice < 0) _totalPrice = 0; // Don't let price be negative
          _appliedCoupon = couponCode;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Coupon "$couponCode" applied! You saved ₹${discountValue.toStringAsFixed(0)}.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error applying coupon: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted)
        setState(() {
          _isCheckingCoupon = false;
        });
    }
  }

  Future<void> _confirmBooking() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

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

      // Save the order to the user's personal 'orders' subcollection
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
        'price': _totalPrice,
        'originalPrice': widget.service.price,
        'discountApplied': _discount,
        'couponCode': _appliedCoupon,
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
      if (mounted)
        setState(() {
          _isLoading = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('Checkout', style: AppTheme.textTheme.headlineMedium),
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
              leading: const Icon(Icons.calendar_today_outlined,
                  color: AppTheme.accent),
              title: Text(
                  DateFormat('EEE, MMM d, yyyy').format(widget.scheduledDate)),
              subtitle: Text(widget.scheduledTime.format(context)),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.location_on_outlined,
                  color: AppTheme.accent),
              title: Text(widget.deliveryAddress,
                  maxLines: 2, overflow: TextOverflow.ellipsis),
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
              title: Text(widget.service.name, style: textTheme.titleMedium),
              subtitle: Text(widget.service.duration),
              trailing: Text(
                '₹${widget.service.price.toStringAsFixed(0)}',
                style:
                    textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // --- COUPON CODE SECTION ---
          _buildSectionHeader(textTheme, 'Coupon Code'),
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _couponController,
                      // --- THIS FORCES THE TEXT TO BE UPPERCASE ---
                      inputFormatters: [
                        UpperCaseTextFormatter(),
                      ],
                      // This suggests the keyboard type
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        labelText: 'Enter coupon code',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isCheckingCoupon ? null : _applyCoupon,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accent, // Gold accent button
                      foregroundColor: AppTheme.background,
                    ),
                    child: _isCheckingCoupon
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('Apply'),
                  ),
                ],
              ),
            ),
          ),
          // --- END OF NEW SECTION ---

          const SizedBox(height: 24),
          _buildSectionHeader(textTheme, 'Card Details'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      decoration:
                          const InputDecoration(labelText: 'Card Number'),
                      keyboardType: TextInputType.number,
                      validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration:
                                const InputDecoration(labelText: 'MM/YY'),
                            keyboardType: TextInputType.datetime,
                            validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null,
                            // --- THIS ADDS THE "/" AUTOMATICALLY ---
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(4),
                              ExpiryDateInputFormatter(),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(labelText: 'CVV'),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(3),
                            ],
                            validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null,
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

          if (_discount > 0)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Subtotal:', style: textTheme.bodyLarge),
                      Text('₹${widget.service.price.toStringAsFixed(0)}',
                          style: textTheme.bodyLarge),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Discount:',
                          style: textTheme.bodyLarge
                              ?.copyWith(color: AppTheme.accent)),
                      Text('- ₹${_discount.toStringAsFixed(0)}',
                          style: textTheme.bodyLarge
                              ?.copyWith(color: AppTheme.accent)),
                    ],
                  ),
                  const Divider(height: 24),
                ],
              ),
            ),

          ElevatedButton(
            onPressed: _isLoading ? null : _confirmBooking,
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                    'Pay ₹${_totalPrice.toStringAsFixed(0)}',
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
        style: textTheme.headlineMedium?.copyWith(color: AppTheme.lightText),
      ),
    );
  }
}

// --- Helper class to format MM/YY input ---
class ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final String newText = newValue.text;
    String cleanText = newText.replaceAll(RegExp(r'[^0-9]'), '');

    if (cleanText.length > 4) {
      cleanText = cleanText.substring(0, 4);
    }

    String formattedText = '';
    for (int i = 0; i < cleanText.length; i++) {
      if (i == 2) {
        formattedText += '/';
      }
      formattedText += cleanText[i];
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

// --- Helper class to force uppercase input ---
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}