import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class LanguageSettingsScreen extends StatefulWidget {
  final String currentLocale;
  final Function(Locale) onLocaleChanged;
  
  const LanguageSettingsScreen({
    Key? key, 
    required this.currentLocale,
    required this.onLocaleChanged,
  }) : super(key: key);

  @override
  State<LanguageSettingsScreen> createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends State<LanguageSettingsScreen> {
  late String _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = widget.currentLocale;
  }

  void _setLanguage(String languageCode) {
    setState(() {
      _selectedLanguage = languageCode;
    });
    
    // Update app locale
    widget.onLocaleChanged(Locale(languageCode, ''));
    
    // Go back to previous screen
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.language),
      ),
      body: ListView(
        children: [
          RadioListTile<String>(
            title: const Text('English'),
            value: 'en',
            groupValue: _selectedLanguage,
            onChanged: (value) {
              if (value != null) {
                _setLanguage(value);
              }
            },
          ),
          RadioListTile<String>(
            title: const Text('العربية'),
            value: 'ar',
            groupValue: _selectedLanguage,
            onChanged: (value) {
              if (value != null) {
                _setLanguage(value);
              }
            },
          ),
        ],
      ),
    );
  }
} 