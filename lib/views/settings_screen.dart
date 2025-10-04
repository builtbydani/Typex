import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: _darkMode,
            onChanged: (value) {
              setState(() {
                _darkMode = value;
              });
              // Implement theme switching
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Dark Mode ${_darkMode ? 'Enabled' : 'Disabled'}',
                  ),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.refresh),
            title: const Text('Refresh Type Data'),
            subtitle: const Text('Download latest type effectiveness data'),
            onTap: () {
              // Implement data refresh logic, call your data service here
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Type data refreshed successfully!'),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            subtitle: const Text('Version 1.0.0'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Pokémon Type Chart',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2025 Dani',
              );
            },
          ),
        ],
      ),
    );
  }
}
