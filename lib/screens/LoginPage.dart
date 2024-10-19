import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'package:flutter/material.dart';


class LoginScreen extends StatelessWidget {
  final AuthService authService = AuthService(); // Create an instance of AuthService
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginScreen({super.key});

  @override

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center vertically
          crossAxisAlignment: CrossAxisAlignment.center, // Center horizontally
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String email = emailController.text.trim();
                String password = passwordController.text.trim();

                // Call the login method and get the result
                String result = await authService.loginUser(email, password);

                if (result == 'success') {
                  Navigator.pushReplacementNamed(context, '?home');
                } else if (result == 'wrong_password') {
                  showAuthErrorDialog(context, 'Wrong password. Please try again.');
                } else if (result == 'user_not_found') {
                  showAuthErrorDialog(context, 'No user found with this email.');
                } else {
                  showAuthErrorDialog(context, 'Login failed. Please try again.');
                }
              },
              child: Text('Login'),
            ),
          ],
        ),
      ),
    ),);
  }

  // Function to show the dialog based on the result
  void showAuthErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Login Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
