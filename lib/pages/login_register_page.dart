import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fyp_app/auth.dart';
import 'package:fyp_app/AdminLoginPage.dart';
import 'package:fyp_app/pages/basepage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? errorMessage = '';
  bool isLogin = true;

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  Future<void> signInWithEmailAndPassword() async {
    try {
      await Auth().signInWithEmailAndPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      );

      // Use pushAndRemoveUntil to navigate to HomePage and clear back stack
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => BasePage()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Future<void> createUserWithEmailAndPassword() async {
    try {
      // Create the user in Firebase Authentication
      UserCredential userCredential =
          await Auth().createUserWithEmailAndPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      );
      await Auth().signOut();
      // Save the user's data to Firestore
      await FirebaseFirestore.instance
          .collection('customers') // Collection name
          .doc(userCredential.user?.uid) // Use the UID as document ID
          .set({
        'email': _controllerEmail.text,
        'createdAt': FieldValue.serverTimestamp(),
        'username': null,
        'phone': null,
        'address': null
      });

      setState(() {
        isLogin = true;
        errorMessage = 'Account created successfully!';
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'An unexpected error occurred.';
      });
    }
  }

  Widget _login() {
    return Row(
      mainAxisSize: MainAxisSize
          .min, // Ensures the row doesn't take up more space than necessary
      children: [
        Icon(
          isLogin
              ? Icons.login
              : Icons.person_add, // Change icon based on login or register
          color: Colors.lightBlue,
          size: 20, // Icon size
        ),
        const SizedBox(width: 8), // Space between the icon and the text
        Text(
          isLogin ? 'Welcome Back!' : 'New Here?',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.lightBlue,
          ),
        ),
      ],
    );
  }

  Widget _title() {
    return const Text(
      'Roomscape',
      style: TextStyle(
        fontSize: 20,
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
              errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          );
  }

  Widget _submitButton() {
    return ElevatedButton(
      onPressed:
          isLogin ? signInWithEmailAndPassword : createUserWithEmailAndPassword,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        backgroundColor: Colors.lightBlue[200],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        isLogin ? 'Login' : 'Register',
        style: const TextStyle(fontSize: 14, color: Colors.white),
      ),
    );
  }

  Widget _loginOrRegisterButton() {
    return TextButton(
      onPressed: () {
        setState(() {
          isLogin = !isLogin;
        });
      },
      child: Text(
        isLogin ? 'Create an Account' : 'Already have an Account? Login',
        style: const TextStyle(color: Colors.blue),
      ),
    );
  }

  Widget _adminLoginButton(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AdminLoginPage()),
        );
      },
      child: const Text(
        'Admin Login',
        style: TextStyle(color: Colors.blue),
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
          elevation: 0, // Remove elevation for a flatter look
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16), // Reduced vertical padding
              child: Card(
                elevation: 4, // Reduced elevation for a flatter look
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: Colors.grey[200], // Set the card color to grey[300]
                child: Container(
                  height: MediaQuery.of(context).size.height *
                      0.6, // Set height to 80% of the screen height
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize:
                        MainAxisSize.max, // Use max to fill available space
                    crossAxisAlignment: CrossAxisAlignment
                        .stretch, // Stretch children to fill the width
                    children: <Widget>[
                      _login(), // Assuming this is a widget that displays "Welcome Back"
                      const SizedBox(height: 24), // Increased spacing
                      _entryField('Email', _controllerEmail),
                      const SizedBox(height: 16), // Increased spacing
                      _entryField('Password', _controllerPassword,
                          isPassword: true),
                      const SizedBox(height: 24), // Increased spacing
                      _errorMessage(),
                      const SizedBox(height: 16), // Increased spacing
                      _submitButton(),
                      const SizedBox(height: 24), // Increased spacing
                      _loginOrRegisterButton(),
                      const SizedBox(height: 16), // Increased spacing
                      _adminLoginButton(context),
                    ],
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
              topLeft: Radius.circular(300),
              topRight: Radius.circular(300),
            ),
          ),
          child: Center(
            child: Text('Have a wonderful Day when Shopping with Us',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ),
        ));
  }
}
