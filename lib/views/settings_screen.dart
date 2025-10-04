import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/theme_viewmodel.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Consumer<ThemeViewModel>(
        builder: (context, themeViewModel, child) {
          return ListView(
            children: [
              SwitchListTile(
                title: const Text('Dark Mode'),
                value: themeViewModel.isDarkMode,
                onChanged: (value) {
                  themeViewModel.toggleTheme();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Dark Mode ${value ? 'Enabled' : 'Disabled'}',
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
                    applicationName: 'TypeX: Type Effectiveness Companion',
                    applicationVersion: '1.0.0',
                    applicationLegalese: '© 2025 Dani',
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
