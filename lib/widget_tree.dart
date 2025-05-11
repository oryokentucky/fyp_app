import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fyp_app/pages/login_register_page.dart';
import 'package:fyp_app/pages/basepage.dart';

class WidgetTree extends StatelessWidget {
  const WidgetTree({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show loading indicator while waiting for authentication state
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          // User is logged in
          return BasePage();
        } else {
          // User is logged out
          return const LoginPage();
        }
      },
    );
  }
}
