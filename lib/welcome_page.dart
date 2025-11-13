import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'login_page.dart';
import 'signup_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset(
                'assets/images/welcome_image.png',
              ),
              const SizedBox(height: 48),
              Text(
                'Welcome',
                textAlign: TextAlign.center,
                style: AppTheme.textTheme.displayLarge,
              ),
              const SizedBox(height: 12),
              Text(
                'Create an account and access our exclusive services.',
                textAlign: TextAlign.center,
                style: AppTheme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 48),

              // "Getting Started" Button (goes to Signup)
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SignupPage(),
                    ),
                  );
                },
                child: const Text('Getting Started'),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account?',
                    style: AppTheme.textTheme.bodyMedium,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                    },
                    child: Text(
                      'Log In',
                      style: AppTheme.textTheme.bodyLarge
                          ?.copyWith(color: AppTheme.accent),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}