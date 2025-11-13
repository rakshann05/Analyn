import 'package:flutter/material.dart';
import 'app_theme.dart'; // Import your new theme

class StartupPage extends StatelessWidget {
  const StartupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use the Ivory White background from your theme
      backgroundColor: AppTheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // You can replace this with your actual logo
            Icon(
              Icons.spa_outlined, // A slightly more elegant icon
              size: 100,
              color: AppTheme.accent, // Use your Gold accent color
            ),
            const SizedBox(height: 20),
            Text(
              'Analyn',
              // Use the Poppins Bold font from your theme
              style: AppTheme.textTheme.displayLarge?.copyWith(
                color: AppTheme.darkText, // Use your Charcoal text color
              ),
            ),
          ],
        ),
      ),
    );
  }
}