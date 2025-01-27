import 'package:flutter/material.dart';

import '../helpers/app_language.dart';

class LanguageSelector extends StatelessWidget {
  final String selectedLanguage;
  final Function(String) onLanguageChanged;

  const LanguageSelector({
    super.key,
    required this.selectedLanguage,
    required this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text("${AppLanguage().translate('language')}: "),
        Radio(
          value: 'en',
          groupValue: selectedLanguage,
          onChanged: (value) {
            onLanguageChanged(value as String);
          },
        ),
        const Text('English'),
        Radio(
          value: 'fa',
          groupValue: selectedLanguage,
          onChanged: (value) {
            onLanguageChanged(value as String);
          },
        ),
        const Text('فارسی'),
      ],
    );
  }
}