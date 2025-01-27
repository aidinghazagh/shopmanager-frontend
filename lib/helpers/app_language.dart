import 'package:shop_manager/helpers/shared_prefs_helper.dart';

class AppLanguage {
  // Singleton instance
  static final AppLanguage _instance = AppLanguage._internal();

  // Factory constructor to return the singleton instance
  factory AppLanguage() {
    return _instance;
  }

  // Private constructor
  AppLanguage._internal();

  // Static translations map
  static final Map<String, Map<String, String>> _translations = {
    'en': {
      'language': 'Language',
      'welcome': 'Welcome',
      'login': 'Login',
      'phone': 'Phone',
      'password': 'Password',
      'home': 'Home',
      'logout': 'Logout',
      'products': 'Products',
      'orders': 'Orders',
      'customers': 'Customers',
      'payments': 'Payments',
      'enter_phone': 'Please enter your phone',
      'enter_password': 'Please enter your password'
    },
    'fa': {
      'language': 'زبان',
      'welcome': 'خوش آمدید',
      'login': 'ورود',
      'phone': 'شماره تلفن',
      'password': 'رمز عبور',
      'home': 'خانه',
      'logout': 'خروج',
      'products': 'محصولات',
      'orders': 'سفارشات',
      'customers': 'مشتری ها',
      'payments': 'پرداختی ها',
      'enter_phone': 'لطفا شماره تلفن خود را وارد کنید',
      'enter_password': 'لطفا رمز عبور خود را وارد کنید'
    },
  };

  // Current language code
  String _languageCode = 'en'; // Default language

  // Getter for the current language code
  String get languageCode => _languageCode;

  // Initialize the language from SharedPreferences
  Future<void> initialize() async {
    final savedLanguage = await SharedPrefsHelper.getUserLanguage();
    if (_translations.containsKey(savedLanguage)) {
      _languageCode = savedLanguage;
    } else {
      print('Saved language ($savedLanguage) is invalid. Falling back to "en".');
      _languageCode = 'en';
    }
  }

  // Setter for updating the language code
  void setLanguage(String newLanguageCode) {
    if (_translations.containsKey(newLanguageCode)) {
      _languageCode = newLanguageCode;
      SharedPrefsHelper.saveUserLanguage(newLanguageCode);
    } else {
      print('Invalid language code: $newLanguageCode');
      throw ArgumentError('Invalid language code: $newLanguageCode');
    }
  }

  // Translate method
  String translate(String key) {
    final translation = _translations[_languageCode]?[key];
    if (translation == null) {
      print('Translation not found for key: $key in language: $_languageCode');
      return 'Translation not found for key: $key';
    }
    return translation;
  }
}