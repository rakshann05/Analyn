import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // <-- THIS LINE FIXES THE ERROR
import 'main.dart';
import 'payment_page.dart';
import 'add_address_page.dart';
import 'app_theme.dart';

class SchedulePage extends StatefulWidget {
  final Service service;

  const SchedulePage({super.key, required this.service});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedAddressId;
  String _selectedAddressText = ''; // To store the text of the selected address

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        // Style the date picker to match the theme
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.accent, // Gold accent
            ),
            dialogBackgroundColor: AppTheme.background,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        // Style the time picker to match the theme
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.accent, // Gold accent
            ),
            dialogBackgroundColor: AppTheme.background,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() => _selectedTime = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final bool canContinue = _selectedDate != null &&
        _selectedTime != null &&
        _selectedAddressId != null;

    return Scaffold(
      backgroundColor: AppTheme.background, // Apply theme background
      appBar: AppBar(
        title: Text('Schedule Appointment', style: AppTheme.textTheme.headlineMedium),
        backgroundColor: AppTheme.background,
        elevation: 0,
        foregroundColor: AppTheme.darkText,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // --- Service Summary Card ---
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            widget.service.imageUrl,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.service.name,
                                  style: AppTheme.textTheme.titleMedium),
                              const SizedBox(height: 4),
                              Text(
                                '${widget.service.duration}  •  ₹${widget.service.price.toStringAsFixed(0)}',
                                style: AppTheme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // --- Date & Time Section ---
                _buildSectionHeader('Select Date & Time'),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.calendar_today_outlined,
                            color: AppTheme.accent),
                        title: const Text('Select Date'),
                        subtitle: Text(
                          _selectedDate == null
                              ? 'No date chosen'
                              : DateFormat('EEE, MMM d, yyyy').format(_selectedDate!),
                          style: AppTheme.textTheme.bodyMedium?.copyWith(
                            color: _selectedDate == null ? AppTheme.lightText : AppTheme.darkText,
                          ),
                        ),
                        onTap: () => _selectDate(context),
                      ),
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      ListTile(
                        leading: const Icon(Icons.access_time_outlined,
                            color: AppTheme.accent),
                        title: const Text('Select Time'),
                        subtitle: Text(
                          _selectedTime == null
                              ? 'No time chosen'
                              : _selectedTime!.format(context),
                          style: AppTheme.textTheme.bodyMedium?.copyWith(
                            color: _selectedTime == null ? AppTheme.lightText : AppTheme.darkText,
                          ),
                        ),
                        onTap: () => _selectTime(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // --- Address Section ---
                _buildSectionHeader('Select Address'),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(user!.uid)
                      .collection('addresses')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final addresses = snapshot.data!.docs;

                    return Card(
                      child: Column(
                        children: [
                          ...addresses.map((addressDoc) {
                            final addressData =
                                addressDoc.data() as Map<String, dynamic>;
                            final fullAddress =
                                '${addressData['fullAddress']}, ${addressData['city']}';
                            return RadioListTile<String>(
                              title: Text(
                                  addressData['type'] ?? 'Address',
                                  style: AppTheme.textTheme.titleMedium
                                      ?.copyWith(fontSize: 16)),
                              subtitle: Text(fullAddress,
                                  style: AppTheme.textTheme.bodyMedium),
                              value: addressDoc.id,
                              groupValue: _selectedAddressId,
                              onChanged: (value) => setState(() {
                                _selectedAddressId = value;
                                _selectedAddressText = fullAddress; // Store the address text
                              }),
                              activeColor: AppTheme.accent,
                            );
                          }).toList(),
                          const Divider(height: 1, indent: 16, endIndent: 16),
                          ListTile(
                            leading: Icon(Icons.add_location_alt_outlined,
                                color: AppTheme.accent),
                            title: Text('Add a New Address',
                                style: AppTheme.textTheme.bodyLarge
                                    ?.copyWith(color: AppTheme.accent)),
                            onTap: () async {
                              // Wait for the page to pop, then check for new addresses
                              await Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => const AddAddressPage()));
                              // No need to call setState, StreamBuilder will update automatically
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          // --- Continue Button ---
          Container(
            padding: const EdgeInsets.all(16.0),
            color: AppTheme.background, // Ensure button bg matches
            child: ElevatedButton(
              onPressed: canContinue
                  ? () {
                      // We already saved the address text when the user tapped the radio button
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => PaymentPage(
                            service: widget.service,
                            scheduledDate: _selectedDate!,
                            scheduledTime: _selectedTime!,
                            deliveryAddress: _selectedAddressText,
                          ),
                        ),
                      );
                    }
                  : null, // Button is disabled if not all options are selected
              child: const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget for section headers
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: AppTheme.textTheme.headlineMedium
            ?.copyWith(color: AppTheme.lightText),
      ),
    );
  }
}