// lib/support_page.dart

import 'package:flutter/material.dart'; // This line was missing

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Support'),
      ),
      body: const Center(
        child: Text('Help and support information will be here.'),
      ),
    );
  }
}
