import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_address_page.dart';
import 'app_theme.dart'; 

class AddressPage extends StatelessWidget {
  const AddressPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(appBar: AppBar(title: const Text('Saved Addresses')), body: const Center(child: Text('Please log in.')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Addresses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AddAddressPage()));
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('addresses')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
             return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No saved addresses found.'));
          }

          final addresses = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: addresses.length,
            itemBuilder: (context, index) {
              final addressData = addresses[index].data() as Map<String, dynamic>;
              final addressId = addresses[index].id;
              
              IconData icon = Icons.location_on_outlined;
              if (addressData['type'] == 'Home') {
                icon = Icons.home_outlined;
              } else if (addressData['type'] == 'Work') {
                icon = Icons.work_outline;
              }
              
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Icon(icon, color: AppTheme.accent),
                  title: Text(addressData['fullAddress'] ?? 'No Address', style: AppTheme.textTheme.titleMedium),
                  subtitle: Text('${addressData['city'] ?? ''}, ${addressData['postalCode'] ?? ''}', style: AppTheme.textTheme.bodyMedium),
                  trailing: IconButton(
                    icon: Icon(Icons.delete_outline, color: AppTheme.lightText.withOpacity(0.7)),
                    onPressed: () {
                     
                    },
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