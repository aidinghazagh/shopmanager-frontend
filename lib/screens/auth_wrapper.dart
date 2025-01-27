// lib/screens/auth_wrapper.dart
import 'package:flutter/material.dart';
import '../helpers/shared_prefs_helper.dart'; // Import the helper
import 'login_screen.dart'; // Import the LoginScreen
import 'home_screen.dart'; // Import the HomeScreen

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: SharedPrefsHelper.getUserToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData && snapshot.data != null) {
          // Token is available, go to Home Page
          return const HomeScreen();
        } else {
          // Token is missing, go to Login Page
          return LoginScreen();
        }
      },
    );
  }
}
