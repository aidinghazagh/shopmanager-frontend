// lib/main.dart
import 'package:flutter/material.dart';
import 'helpers/app_language.dart'; // Import the localization class
import 'helpers/shared_prefs_helper.dart';
import 'screens/auth_wrapper.dart'; // Import the AuthWrapper

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter is initialized

  // Fetch the saved language from SharedPreferences
  final savedLanguage = await SharedPrefsHelper.getUserLanguage();

  // Initialize the AppLanguage singleton with the saved language
  AppLanguage().setLanguage(savedLanguage);

  runApp(const ShopManagerApp());
}


// Helper method to update the app's locale
class ShopManagerApp extends StatefulWidget {
  const ShopManagerApp({super.key});

  @override
  State<ShopManagerApp> createState() => _ShopManagerAppState();
}

class _ShopManagerAppState extends State<ShopManagerApp> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shop Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      supportedLocales: const [
        Locale('en', 'US'), // English
        Locale('fa', 'IR'), // Farsi
      ],
      home: AuthWrapper(),
    );
  }
}
