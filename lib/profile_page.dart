import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'edit_profile_page.dart';
import 'address_page.dart';
import 'app_theme.dart';

class ProfilePage extends StatefulWidget {
  final VoidCallback onLogout; 
  const ProfilePage({super.key, required this.onLogout});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<void> _sendPasswordResetEmail(BuildContext context) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: User not found.'), backgroundColor: Colors.red),
      );
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: user.email!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset link sent to your email.'),
          backgroundColor: Colors.green,
        ),
      );
    } on FirebaseAuthException catch (e) {
      String message = 'Failed to send email. Please try again later.';
      if (e.code == 'too-many-requests') {
        message = 'Too many requests. Please wait a few minutes.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? uid = _auth.currentUser?.uid;

    if (uid == null) {
      return const Center(child: Text('User not found.'));
    }

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

        return Container(
          color: AppTheme.background, 
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildProfileHeader(context, userData),
              const SizedBox(height: 24),
              Text(
                'My Account',
                style: AppTheme.textTheme.headlineMedium
                    ?.copyWith(color: AppTheme.lightText),
              ),
              const SizedBox(height: 12),
              _buildProfileCard(
                context: context,
                icon: Icons.location_on_outlined,
                title: 'Saved Addresses',
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const AddressPage())),
              ),
              const SizedBox(height: 12),
              _buildProfileCard(
                context: context,
                icon: Icons.lock_outline,
                title: 'Change Password',
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Change Password'),
                      content: Text(
                          'Send a password reset link to ${userData['email']}?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                            _sendPasswordResetEmail(context);
                          },
                          child: const Text('Send'),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              _buildLogoutButton(context),
            ],
          ),
        );
      },
    );
  }
  Widget _buildProfileHeader(
      BuildContext context, Map<String, dynamic> userData) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: AppTheme.accent.withOpacity(0.1),
              child: Icon(Icons.person, size: 30, color: AppTheme.accent),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userData['name'] ?? 'No Name',
                    style: AppTheme.textTheme.headlineMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userData['email'] ?? 'No Email',
                    style: AppTheme.textTheme.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.edit_outlined, color: AppTheme.lightText),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => EditProfilePage(userData: userData))),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildProfileCard(
      {required BuildContext context,
      required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.darkText.withOpacity(0.8)),
        title: Text(title, style: AppTheme.textTheme.titleMedium),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
  Widget _buildLogoutButton(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.red.withOpacity(0.05),
      child: ListTile(
        leading: const Icon(Icons.logout, color: Colors.red),
        title: const Text('Logout', style: TextStyle(color: Colors.red)),
        onTap: () {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Confirm Logout'),
              content: const Text('Are you sure you want to log out?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    widget.onLogout(); 
                  },
                  child: const Text('Logout',
                      style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}