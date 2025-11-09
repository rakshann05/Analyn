// lib/startup_page.dart

import 'package:flutter/material.dart';

class StartupPage extends StatelessWidget {
  const StartupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.blueAccent, // Or your brand's primary color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // You can replace this with your actual logo
            Icon(
              Icons.spa, // Placeholder for a spa/wellness logo
              size: 100,
              color: Colors.white,
            ),
            SizedBox(height: 20),
            Text(
              'Analyn',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
