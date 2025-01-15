import 'package:firebase_auth/firebase_auth.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // List of predefined admin emails
  final List<String> adminEmails = [
    "admin@example.com", // Add all admin emails here
    "manager@example.com"
  ];

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  // Function to check if the current user is an admin
  bool isAdmin(User? user) {
    if (user == null) {
      return false;
    }
    return adminEmails.contains(user.email);
  }

  // Function to sign in only if the user is an admin
  Future<void> signInAsAdmin({
    required String email,
    required String password,
  }) async {
    UserCredential userCredential = await signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (!isAdmin(userCredential.user)) {
      await signOut(); // Sign out if the user is not an admin
      throw FirebaseAuthException(
        code: "not-authorized",
        message: "This account is not authorized for admin access.",
      );
    }
  }
}
