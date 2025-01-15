// base_page.dart
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:fyp_app/pages/AccountPage.dart';
import 'package:fyp_app/pages/cart_page.dart';
import 'package:fyp_app/pages/order_page.dart';
import 'package:fyp_app/pages/Home_Page.dart';

class BasePage extends StatefulWidget {
  const BasePage({Key? key}) : super(key: key);

  @override
  _BasePageState createState() => _BasePageState();
}

class _BasePageState extends State<BasePage> {
  int _selectedIndex = 0;

  // Navigation logic to update the selected index
  void _navigateTo(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Map each index to its respective page
  final List<Widget> _pages = [
    HomePage(),
    AccountPage(),
    CartPage(),
    OrderPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // Display the selected page
      bottomNavigationBar: Container(
        height: 60,
        color: const Color.fromARGB(255, 156, 230, 255),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5),
          child: GNav(
            backgroundColor: const Color.fromARGB(255, 156, 230, 255),
            color: Colors.white,
            activeColor: const Color.fromARGB(255, 111, 110, 110),
            tabBackgroundColor: const Color.fromARGB(255, 156, 230, 255),
            gap: 8,
            padding: const EdgeInsets.all(16),
            selectedIndex: _selectedIndex, // Set the selected index
            onTabChange: _navigateTo, // Handle tab changes
            tabs: const [
              GButton(
                icon: Icons.home,
                text: 'Home',
              ),
              GButton(
                icon: Icons.person,
                text: 'Profile',
              ),
              GButton(
                icon: Icons.shopping_cart,
                text: 'Cart',
              ),
              GButton(
                icon: Icons.list_alt,
                text: 'Orders',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
