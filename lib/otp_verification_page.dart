// lib/otp_verification_page.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OtpVerificationPage extends StatefulWidget {
  final String verificationId;
  // User data is optional. If it's null, we're in a login flow.
  final Map<String, String>? userData;

  const OtpVerificationPage({
    super.key,
    required this.verificationId,
    this.userData,
  });

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final _otpController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

  Future<void> _verifyOtpAndProceed() async {
    if (_otpController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 6-digit OTP.')),
      );
      return;
    }

    setState(() { _isLoading = true; });

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: _otpController.text.trim(),
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);

      // If this is a signup flow (userData is not null), save the data
      if (widget.userData != null && userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'name': widget.userData!['name'],
          'email': widget.userData!['email'],
          'phone': widget.userData!['phone'],
          'address': widget.userData!['address'],
          'createdAt': Timestamp.now(),
        });

        // For signup, we sign the user out so they can log in fresh
        await _auth.signOut();

        // Return 'true' to the signup page to signal success
        if (mounted) Navigator.of(context).pop(true);
      }
      // If it's a login flow, the StreamBuilder in main.dart will automatically handle navigation.
      // The OTP page will just close itself.

    } on FirebaseAuthException catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to verify OTP: ${e.message}')),
        );
      }
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Your Number')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Enter the 6-digit code sent to your number.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 6,
                decoration: const InputDecoration(
                  labelText: 'OTP Code',
                  border: OutlineInputBorder(),
                  counterText: "", // Hide the counter
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _verifyOtpAndProceed,
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 18)
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(widget.userData != null ? 'Verify & Create Account' : 'Verify & Log In'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
