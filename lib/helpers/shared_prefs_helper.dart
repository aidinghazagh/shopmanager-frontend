// lib/shared_prefs_helper.dart
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsHelper {
  // Save the user token
  static Future<void> saveUserToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_token', token);
  }

  // Retrieve the user token
  static Future<String?> getUserToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_token');
  }

  // Remove the user token (e.g., on logout)
  static Future<void> removeUserToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_token');
  }

  static Future<void> saveUserLanguage(String language) async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_language', language);
  }

  // Retrieve the user token
  static Future<String> getUserLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    String? lagnuage = prefs.getString('user_language');
    return lagnuage ?? 'en';
  }

}
