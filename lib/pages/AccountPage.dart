import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fyp_app/auth.dart';
import 'package:fyp_app/pages/login_register_page.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Controllers for text fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  bool _isLoading = true; // Show loading initially
  bool _isEditing = false; // Track if the user is editing
  bool _showLoyaltyPoints = true; // Track if loyalty points should be shown

  final int _loyaltyPoints = 120; // Example random number
  final String _expiryDate = "2025-02-15"; // Example expiration date

  // Fetch user data from Firestore
  Future<void> _fetchUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot docSnap =
          await _firestore.collection('customers').doc(user.uid).get();
      if (docSnap.exists) {
        var data = docSnap.data() as Map<String, dynamic>;
        _emailController.text = data['email'];
        _phoneController.text = data['phone'] ?? '';
        _usernameController.text = data['username'] ?? '';
        _addressController.text = data['address'] ?? '';
      }
    }

    // After data is fetched, set loading to false to display the UI
    setState(() {
      _isLoading = false;
    });
  }

  // Update user data in Firestore
  Future<void> _updateUserData() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email cannot be empty.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Start loading
    });

    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('customers').doc(user.uid).update({
          'email': _emailController.text,
          'phone': _phoneController.text,
          'username': _usernameController.text,
          'address': _addressController.text,
        });

        await user.updateEmail(_emailController.text);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );

        setState(() {
          _isEditing = false;
          _showLoyaltyPoints = true; // Show loyalty points after saving
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User  not logged in')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Account',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.lightBlue[300],
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await Auth().signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Account Information',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.lightBlue,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Display Account Info
                    _buildInfoCard('Email', _emailController.text),
                    const SizedBox(height: 10),
                    _buildInfoCard('Phone Number', _phoneController.text),
                    const SizedBox(height: 10),
                    _buildInfoCard('Username', _usernameController.text),
                    const SizedBox(height: 10),
                    _buildInfoCard('Address', _addressController.text),
                    const SizedBox(height: 20),

                    // Show Edit/Save Button
                    Center(
                      child: _isEditing
                          ? ElevatedButton(
                              onPressed: _updateUserData,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.lightBlue[200],
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 24,
                                ),
                              ),
                              child: const Text('Save Changes',
                                  style: TextStyle(color: Colors.white)),
                            )
                          : ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _isEditing = true;
                                  _showLoyaltyPoints =
                                      false; // Hide loyalty points when editing
                                });
                              },
                              child: const Text('Edit Info',
                                  style: TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.lightBlue[200],
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 24,
                                ),
                              ),
                            ),
                    ),
                    // Loyalty Points Section
                    if (_showLoyaltyPoints) ...[
                      const SizedBox(height: 40),
                      const Text(
                        'Loyalty Points',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.lightBlue,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.monetization_on,
                                      color: Colors.amber),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Points: $_loyaltyPoints',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                'Expiry: $_expiryDate',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInfoCard(String title, String content) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!_isEditing) ...[
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
            ],
            _isEditing
                ? TextField(
                    controller: title == 'Email'
                        ? _emailController
                        : title == 'Phone Number'
                            ? _phoneController
                            : title == 'Username'
                                ? _usernameController
                                : _addressController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Enter your $title',
                    ),
                  )
                : Text(
                    content,
                    style: const TextStyle(
                        fontSize: 16), // Optional: Adjust text size
                  ),
          ],
        ),
      ),
    );
  }
}
