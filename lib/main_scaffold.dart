// lib/main_scaffold.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services_page.dart';
import 'orders_page.dart';
import 'profile_page.dart';
import 'support_page.dart';
import 'app_theme.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  // --- NEW: List of page titles for the AppBar ---
  static const List<String> _pageTitles = [
    'Our Services',
    'My Bookings',
    'My Profile',
    'Support',
  ];

  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    // Pass the logout function to the ProfilePage
    _widgetOptions = <Widget>[
      ServicesPage(),
      const OrdersPage(),
      ProfilePage(onLogout: _handleLogout), // Pass the function here
      const SupportPage(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // --- NEW: Logout logic is now handled here ---
  Future<void> _handleLogout() async {
    await FirebaseAuth.instance.signOut();
    // The StreamBuilder in main.dart will automatically navigate to the login page.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- NEW: A single, consistent AppBar ---
      appBar: AppBar(
        title: Text(_pageTitles[_selectedIndex]),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), activeIcon: Icon(Icons.calendar_today), label: 'Bookings'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.support_agent_outlined), activeIcon: Icon(Icons.support_agent), label: 'Support'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppTheme.accent,
        unselectedItemColor: AppTheme.lightText,
        onTap: _onItemTapped,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
