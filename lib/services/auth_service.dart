import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Register with email and password
  Future<String> registerWithEmail(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return 'success';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return 'email_already_in_use';
      } else {
        return 'failure';
      }
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Login with email and password
  Future<String> loginUser(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      return 'success';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        return 'wrong_password';
      } else if (e.code == 'user-not-found') {
        return 'user_not_found';
      } else {
        return 'failure';
      }
    }
  }
}
