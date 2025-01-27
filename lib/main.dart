import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'helpers/app_language.dart'; // Import the localization class
import 'helpers/shared_prefs_helper.dart';
import 'screens/auth_wrapper.dart'; // Import the AuthWrapper

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter is initialized

  // Fetch the saved language from SharedPreferences
  final savedLanguage = await SharedPrefsHelper.getUserLanguage();

  // Initialize the AppLanguage singleton with the saved language
  final appLanguage = AppLanguage();
  appLanguage.setLanguage(savedLanguage);

  runApp(
    ChangeNotifierProvider<AppLanguage>.value(
      value: appLanguage,
      child: const ShopManagerApp(),
    ),
  );
}

class ShopManagerApp extends StatelessWidget {
  const ShopManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppLanguage>(
      builder: (context, appLanguage, child) {
        return MaterialApp(
          locale: Locale(appLanguage.languageCode),
          builder: (context, child) {
            return Directionality(
              textDirection: appLanguage.isRtl() ? TextDirection.rtl : TextDirection.ltr,
              child: child!,
            );
          },
          home: AuthWrapper(),
        );
      },
    );
  }
}