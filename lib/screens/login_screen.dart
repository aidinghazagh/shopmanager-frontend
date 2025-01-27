// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:shop_manager/helpers/api_helper.dart';
import 'package:shop_manager/widgets/custom_snack_bar.dart';
import 'package:shop_manager/widgets/custom_text_field.dart';
import '../helpers/app_language.dart'; // Import the localization class
import '../helpers/shared_prefs_helper.dart'; // Import the helper
import '../widgets/language_selector.dart';
import 'home_screen.dart'; // Import the HomeScreen

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedLanguage = AppLanguage().languageCode;

  // Error messages for each field
  String? _phoneError;
  String? _passwordError;

  Future<void> _login(BuildContext context) async {
    try {
      if (_formKey.currentState!.validate()) {
        // Reset previous errors
        setState(() {
          _phoneError = null;
          _passwordError = null;
        });
        // Simulate a login API call
        String phone = _phoneController.text;
        String password = _passwordController.text;

        // Define the request body
        final loginBody = {
          'phone': phone,
          'password': password,
          'default_lang': _selectedLanguage,
        };

        // Send the POST request
        final response = await ApiHelper.post('login', body: loginBody);
        // Handle the response
        if (response.status) {

          // Save the user token
          final userToken = response.output['token'];
          await SharedPrefsHelper.saveUserToken(userToken);
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const HomeScreen())
          );
          return; // Exit the function to avoid further execution
        }

        if (response.errors.isNotEmpty) {
          customSnackBar(context, response.errors[0], null);
        } else if (response.validations.isNotEmpty) {
          setState(() {
            _phoneError = response.validations['phone']?.join(' ');
            _passwordError = response.validations['password']?.join(' ');
          });
        }

        customSnackBar(context, "Request failed: no error message found", null);
      }
    } catch (e) {
      customSnackBar(context, "Error during login", null);
    }
  }

  void _changeLanguage(String newLanguage) {
    setState(() {
      _selectedLanguage = newLanguage;
      AppLanguage().setLanguage(newLanguage);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLanguage().translate('login')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Expanded(
            child: SingleChildScrollView(
              child: Column(
                children:  [
                  LanguageSelector(
                    selectedLanguage: _selectedLanguage,
                    onLanguageChanged: _changeLanguage,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _phoneController,
                    labelText: AppLanguage().translate('phone'),
                    hintText: AppLanguage().translate('phone'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLanguage().translate('enter_phone');
                      }
                      return null;
                    },
                    errorText: _phoneError,
                  ),
                  const SizedBox(height: 16),
                  // Password Field
                  CustomTextField(
                    controller: _passwordController,
                    labelText: AppLanguage().translate('password'),
                    hintText: AppLanguage().translate('password'),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLanguage().translate('enter_password');
                      }
                      return null;
                    },
                    errorText: _passwordError
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => _login(context),
                    child: Text(AppLanguage().translate('login')),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
