import 'package:firebase_auth/firebase_auth.dart';
import 'package:fyp_app/auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp_app/Admin/adminDashboard.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({Key? key}) : super(key: key);

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  String? errorMessage = '';
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  Future<void> adminSignIn() async {
    try {
      await Auth().signInAsAdmin(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminDashboardPage()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Widget _title() {
    return const Text(
      'Admin Login',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.lightBlue,
      ),
    );
  }

  Widget _message() {
    return const Text(
      'Welcome Back, Boss!',
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: Colors.lightBlue,
      ),
    );
  }

  Widget _entryField(String title, TextEditingController controller,
      {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: title,
        labelStyle: const TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _errorMessage() {
    return errorMessage == ''
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Error: $errorMessage',
              style: const TextStyle(color: Colors.red),
            ),
          );
  }

  Widget _submitButton() {
    return ElevatedButton(
      onPressed: adminSignIn,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        backgroundColor: Colors.lightBlue[200],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: const Text(
        'Login as Admin',
        style: TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          title: _title(),
          backgroundColor: Colors.grey[200],
          centerTitle: true,
          elevation: 0,
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                color: Colors.grey[200],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    height: MediaQuery.of(context).size.height *
                        0.5, // Set height to 70% of the screen height
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        _message(),
                        const SizedBox(height: 24),
                        _entryField('Email', _controllerEmail),
                        const SizedBox(height: 24),
                        _entryField('Password', _controllerPassword,
                            isPassword: true),
                        const SizedBox(height: 24),
                        _errorMessage(),
                        _submitButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: Container(
          height: 100, // Height of the curved bar
          decoration: BoxDecoration(
            color: Colors.lightBlue[200], // Light blue color
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(100),
              topRight: Radius.circular(100),
            ),
          ),
          child: Center(
            child: Text('Rest if Needed, Work when Motivated',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ),
        ));
  }
}
