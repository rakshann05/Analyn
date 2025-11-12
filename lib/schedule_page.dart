import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.accent, 
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) setState(() => _selectedDate = picked);
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.accent,
            ),
          ),
          child: child!,
        );
      },
    );
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
                              Text(widget.service.name, style: AppTheme.textTheme.titleMedium),
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
                Text('Select Date & Time', style: AppTheme.textTheme.headlineMedium?.copyWith(fontSize: 20)),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.calendar_today_outlined, color: AppTheme.accent),
                  title: const Text('Select Date'),
                  subtitle: Text(_selectedDate == null ? 'No date chosen' : '${_selectedDate!.toLocal()}'.split(' ')[0]),
                  onTap: () => _selectDate(context),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.access_time_outlined, color: AppTheme.accent),
                  title: const Text('Select Time'),
                  subtitle: Text(_selectedTime == null ? 'No time chosen' : _selectedTime!.format(context)),
                  onTap: () => _selectTime(context),
                ),
                const SizedBox(height: 24),             
                Text('Select Address', style: AppTheme.textTheme.headlineMedium?.copyWith(fontSize: 20)),
                const SizedBox(height: 12),
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
                          return RadioListTile<String>(
                            title: Text(addressData['type'] ?? 'Address', style: AppTheme.textTheme.titleMedium?.copyWith(fontSize: 16)),
                            subtitle: Text(fullAddress, style: AppTheme.textTheme.bodyMedium),
                            value: addressDoc.id,
                            groupValue: _selectedAddressId,
                            onChanged: (value) => setState(() => _selectedAddressId = value),
                            activeColor: AppTheme.accent,
                          );
                        }).toList(),
                        ListTile(
                          leading: Icon(Icons.add_location_alt_outlined, color: AppTheme.accent),
                          title: Text('Add a New Address', style: AppTheme.textTheme.bodyLarge?.copyWith(color: AppTheme.accent)),
                          onTap: () async {
                             // Wait for the page to pop, then check for new addresses
                            await Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AddAddressPage()));
                            setState(() {
                            });
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
              onPressed: canContinue ? () async {
                final addressSnapshot = await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
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
              child: const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }
}