import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import dotenv
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'login_page.dart';
import 'startup_page.dart';
import 'app_theme.dart';
import 'main_scaffold.dart';
import 'firebase_options.dart'; // Import your new options file

class Service {
  final int id;
  final String name;
  final String description;
  final String duration;
  final double price;
  final String imageUrl;

  Service({
    required this.id,
    required this.name,
    required this.description,
    required this.duration,
    required this.price,
    required this.imageUrl,
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load .env file FIRST
  await dotenv.load(fileName: ".env");

  // Initialize Firebase SECOND, using the options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Analyn',
      theme: AppTheme.theme,
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _showStartup = true;
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() { _showStartup = false; });
    });
    _initDynamicLinks();
  }

  Future<void> _initDynamicLinks() async {
    FirebaseDynamicLinks.instance..listen((dynamicLink) async {
      final Uri deepLink = dynamicLink.link;
      _handleLink(deepLink);
    }).onError((error) {
      
    });

    final PendingDynamicLinkData? data = await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri? deepLink = data?.link;
    if (deepLink != null) {
      _handleLink(deepLink);
    }
  }

  Future<void> _handleLink(Uri link) async {
    if (_auth.isSignInWithEmailLink(link.toString())) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final email = prefs.getString('emailForSignIn');
        if (email != null) {
          await _auth.signInWithEmailLink(
            email: email,
            emailLink: link.toString(),
          );
          await prefs.remove('emailForSignIn');
        }
      } catch (e) {
        
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showStartup) {
      return const StartupPage();
    }

    return StreamBuilder<User?>(
      stream: _auth.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasData && snapshot.data!.emailVerified) {
          return const MainScaffold();
        }
        
        return const LoginPage();
      },
    );
  }
}