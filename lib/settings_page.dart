import 'package:bps_bintan/providers/setting_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Settings'),
      // ),
      backgroundColor: Colors.transparent,

      body: Consumer<SettingsProvider>(
        builder: (context, value, child) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title:
                  Text(value.language == 'Indonesian' ? "Bahasa" : "Language"),
              trailing: DropdownButton<String>(
                underline: const SizedBox.shrink(),
                value: settings.language,
                items: ['Indonesian', 'English'].map((String language) {
                  return DropdownMenuItem<String>(
                    value: language,
                    child: Text(language),
                  );
                }).toList(),
                onChanged: (String? newLanguage) {
                  if (newLanguage != null) {
                    settings.updateLanguage(newLanguage);
                  }
                },
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              title: Text(
                  value.language == 'Indonesian' ? 'Mode Gelap' : 'Dark Mode'),
              trailing: Switch(
                value: settings.isDarkMode,
                onChanged: (bool value) {
                  settings.toggleDarkMode(value);
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
