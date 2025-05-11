import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({Key? key}) : super(key: key);

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _profileImageController = TextEditingController();

  bool _isLoading = true;
  bool _isEditing = false;

  Future<void> _fetchAdminData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot docSnap = await _firestore
          .collection('admin')
          .doc('iXc19yb5PDJhgF96xqpk')
          .get();
      if (docSnap.exists) {
        var data = docSnap.data() as Map<String, dynamic>;
        _emailController.text = data['email'];
        _phoneController.text = data['phone'] ?? '';
        _nameController.text = data['name'] ?? '';
        _profileImageController.text = data['imageUrl'] ?? '';
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _updateAdminData() async {
    setState(() {
      _isLoading = true;
    });

    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore
            .collection('admin')
            .doc('iXc19yb5PDJhgF96xqpk')
            .update({
          'email': _emailController.text,
          'phone': _phoneController.text,
          'name': _nameController.text,
          'imageUrl': _profileImageController.text,
        });

        setState(() {
          _isEditing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchAdminData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Profile Picture
                    CircleAvatar(
                      radius: 100,
                      backgroundImage: _profileImageController.text.isNotEmpty
                          ? NetworkImage(_profileImageController.text)
                          : const NetworkImage(
                              'https://via.placeholder.com/150'),
                    ),
                    const SizedBox(height: 16),

                    _buildInfoCard('Email', _emailController),
                    const SizedBox(
                      height: 10,
                      width: 200,
                    ),
                    _buildInfoCard('Phone Number', _phoneController),
                    const SizedBox(height: 10),
                    _buildInfoCard('Name', _nameController),
                    const SizedBox(height: 10),
                    _buildInfoCard(
                        'Profile Image URL', _profileImageController),

                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _isEditing
                          ? _updateAdminData
                          : () {
                              setState(() {
                                _isEditing = true;
                              });
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 246, 248, 255),
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 24),
                      ),
                      child: Text(_isEditing ? 'Save Changes' : 'Edit Info'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInfoCard(String label, TextEditingController controller) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isEditing
            ? TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: 'Enter $label',
                  border: const OutlineInputBorder(),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(controller.text, style: const TextStyle(fontSize: 16)),
                ],
              ),
      ),
    );
  }
}
