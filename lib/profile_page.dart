// lib/profile_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'edit_profile_page.dart';
import 'address_page.dart';
import 'app_theme.dart';

class ProfilePage extends StatefulWidget {
  final VoidCallback onLogout; // Accepts the logout function
  const ProfilePage({super.key, required this.onLogout});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final String? uid = _auth.currentUser?.uid;

    if (uid == null) {
      // This page no longer has an AppBar, so we return an empty container
      return const Center(child: Text('User not found.'));
    }

    // The Scaffold is now in MainScaffold, we just return the body content
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: _firestore.collection('users').doc(uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data?.data() == null) {
          return const Center(child: Text('Could not load profile data.'));
        }
        final userData = snapshot.data!.data()!;

        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            ListTile(
              leading: const Icon(Icons.person_outline, size: 30),
              title: Text(userData['name'] ?? 'No Name'),
              subtitle: Text(userData['email'] ?? 'No Email'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => EditProfilePage(userData: userData))),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.location_on_outlined),
              title: const Text('Saved Addresses'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AddressPage())),
            ),
            const Divider(),
            // --- NEW: Logout Button ---fu
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text('Logout', style: TextStyle(color: Colors.redAccent)),
              onTap: widget.onLogout, // Calls the function from MainScaffold
            ),
          ],
        );
      },
    );
  }
}
