import 'package:flutter/material.dart';
import 'profile_management.dart';
import 'furniture_management.dart';
import 'order_management.dart';
import 'dashboard.dart';
import 'package:fyp_app/auth.dart';
import 'package:fyp_app/AdminLoginPage.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  Widget _selectedPage = const AdminProfilePage(); // Default page

  void _navigateToPage(Widget page) {
    setState(() {
      _selectedPage = page;
    });
    Navigator.pop(context); // Close the drawer
  }

  Future<void> _logout() async {
    await Auth().signOut(); // Sign out using the Auth class
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AdminLoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
      ),
      body: _selectedPage,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.lightBlue,
              ),
              child: Text(
                'Admin Navigation',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile Management'),
              onTap: () => _navigateToPage(const AdminProfilePage()),
            ),
            ListTile(
              leading: const Icon(Icons.chair),
              title: const Text('Furniture Management'),
              onTap: () => _navigateToPage(const FurnitureManagementTab()),
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('Order Management'),
              onTap: () => _navigateToPage(const OrderManagementTab()),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () => _navigateToPage(const DashboardTab()),
            ),
            const Divider(), // Adds a visual separator
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: _logout, // Trigger logout
            ),
          ],
        ),
      ),
    );
  }
}
