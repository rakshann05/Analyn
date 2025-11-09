// lib/schedule_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main.dart'; // To get the Service class
import 'payment_page.dart';
import 'add_address_page.dart';

class SchedulePage extends StatefulWidget {
  final Service service;

  const SchedulePage({super.key, required this.service});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedAddressId; // --- CHANGED: Now stores the document ID as a String ---

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 30)));
    if (picked != null && picked != _selectedDate) setState(() => _selectedDate = picked);
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null && picked != _selectedTime) setState(() => _selectedTime = picked);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final bool canContinue = _selectedDate != null && _selectedTime != null && _selectedAddressId != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Schedule Appointment')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Select Date'),
                  subtitle: Text(_selectedDate == null ? 'No date chosen' : '${_selectedDate!.toLocal()}'.split(' ')[0]),
                  onTap: () => _selectDate(context),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.access_time),
                  title: const Text('Select Time'),
                  subtitle: Text(_selectedTime == null ? 'No time chosen' : _selectedTime!.format(context)),
                  onTap: () => _selectTime(context),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text('Select Address', style: Theme.of(context).textTheme.titleLarge),
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('users').doc(user!.uid).collection('addresses').snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                    final addresses = snapshot.data!.docs;

                    return Column(
                      children: [
                        ...addresses.map((addressDoc) {
                          final addressData = addressDoc.data() as Map<String, dynamic>;
                          final fullAddress = '${addressData['fullAddress']}, ${addressData['city']}';
                          return RadioListTile<String>( // --- CHANGED: The type is now String ---
                            title: Text(addressData['type'] ?? 'Address'),
                            subtitle: Text(fullAddress),
                            value: addressDoc.id, // --- CHANGED: Use the document ID as the value ---
                            groupValue: _selectedAddressId, // --- CHANGED: Compare against the stored ID ---
                            onChanged: (value) => setState(() => _selectedAddressId = value),
                          );
                        }).toList(),
                        ListTile(
                          leading: const Icon(Icons.add_location_alt_outlined),
                          title: const Text('Add a New Address'),
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AddAddressPage()));
                          },
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: canContinue ? () async { // --- CHANGED: Made this async ---
                // --- NEW: Find the full address data before navigating ---
                final addressSnapshot = await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user!.uid)
                    .collection('addresses')
                    .doc(_selectedAddressId)
                    .get();

                final addressData = addressSnapshot.data() as Map<String, dynamic>;
                final fullAddress = '${addressData['fullAddress']}, ${addressData['city']}, ${addressData['postalCode']}';

                if(mounted) {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => PaymentPage(
                      service: widget.service,
                      scheduledDate: _selectedDate!,
                      scheduledTime: _selectedTime!,
                      deliveryAddress: fullAddress,
                    ),
                    ),
                  );
                }
              } : null,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), minimumSize: const Size(double.infinity, 50)),
              child: const Text('Continue', style: TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }
}
