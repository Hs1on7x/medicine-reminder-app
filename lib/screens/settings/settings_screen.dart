import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.settings),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(localizations.language),
            onTap: () {
              Navigator.pushNamed(context, '/language_settings');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: Text(localizations.notifications),
            onTap: () {
              // Navigate to notifications settings
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info),
            title: Text(localizations.about),
            onTap: () {
              // Navigate to about screen
            },
          ),
        ],
      ),
    );
  }
} 