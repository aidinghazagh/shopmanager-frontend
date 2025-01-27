import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_manager/helpers/api_helper.dart';
import 'package:shop_manager/widgets/custom_snack_bar.dart';
import 'package:shop_manager/widgets/custom_text_field.dart';
import '../helpers/app_language.dart';
import '../helpers/shared_prefs_helper.dart';
import '../widgets/language_selector.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  late String _selectedLanguage;

  String? _phoneError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = Provider.of<AppLanguage>(context, listen: false).languageCode;
  }

  Future<void> _login(BuildContext context) async {
    try {
      if(_isLoading){
        return;
      }
      setState(() {
        _phoneError = null;
        _passwordError = null;
        _isLoading = true;
      });

      String phone = _phoneController.text;
      String password = _passwordController.text;

      final loginBody = {
        'phone': phone,
        'password': password,
        'default_lang': _selectedLanguage,
      };

      final response = await ApiHelper.post('login', body: loginBody);
      setState(() {
        _isLoading = false;
      });
      if (response.status) {
        final userToken = response.output['token'];
        await SharedPrefsHelper.saveUserToken(userToken);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
        return;
      }

      if (response.errors.isNotEmpty) {
        customSnackBar(context, response.errors[0], null);
        return;
      } else if (response.validations.isNotEmpty) {
        setState(() {
          _phoneError = response.validations['phone']?.join(' ');
          _passwordError = response.validations['password']?.join(' ');
        });
        return;
      }
      customSnackBar(context, Provider.of<AppLanguage>(context, listen: false).translate('server_error'), null);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      customSnackBar(context, "${Provider.of<AppLanguage>(context, listen: false).translate('network_error')}: $e", null);
    }
  }

  void _changeLanguage(String newLanguage) {
    setState(() {
      _selectedLanguage = newLanguage;
      Provider.of<AppLanguage>(context, listen: false).setLanguage(newLanguage);
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appLanguage = Provider.of<AppLanguage>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(appLanguage.translate('login')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                LanguageSelector(
                  selectedLanguage: _selectedLanguage,
                  onLanguageChanged: _changeLanguage,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _phoneController,
                  labelText: appLanguage.translate('phone'),
                  hintText: appLanguage.translate('phone'),
                  validator: (value) {
                    if (_phoneError != null) {
                      return _phoneError;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _passwordController,
                  labelText: appLanguage.translate('password'),
                  hintText: appLanguage.translate('password'),
                  obscureText: true,
                  validator: (value) {
                    if (_passwordError != null) {
                      return _passwordError;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _login(context),
                    child: _isLoading ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    ) : Text(appLanguage.translate('login')),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
