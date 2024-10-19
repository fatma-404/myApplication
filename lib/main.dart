import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/HomePage.dart';
import 'screens/LoginPage.dart';
import 'services/auth_service.dart';
import 'screens/book_reader_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
      MultiProvider(
        providers: [
          Provider<AuthService>(
            create: (_) => AuthService(),
          ),
        ],
        child: const MyApp(),)
  );
  
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,  // Support light/dark mode
      home: AuthWrapper(),
      initialRoute: '?',
      routes: {
        "?": (context) => LoginScreen(),
        "?home": (context) => HomePage(), // Ensure HomePage is your home screen
      },
    );
  }
}
// Widget to handle authentication state and navigate to the appropriate screen
class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = context.watch<User?>();

    // If user is logged in, show the HomePage, otherwise show the LoginPage
    if (user != null) {
      return HomePage(); // Your main screen for the app
    } else {
      return LoginScreen(); // Login screen
    }
  }
}

