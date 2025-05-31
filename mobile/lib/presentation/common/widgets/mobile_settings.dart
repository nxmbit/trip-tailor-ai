import 'package:flutter/material.dart';
import 'package:frontend/core/utils/translation_helper.dart';
import 'package:frontend/presentation/state/providers/language_provider.dart';
import 'package:frontend/presentation/state/providers/theme_provider.dart';
import 'package:frontend/presentation/state/layout_state.dart';
import 'package:provider/provider.dart';

class MobileSettings extends StatelessWidget {
  const MobileSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final layoutState = LayoutState();

    return Scaffold(
      appBar: AppBar(
        title: Text(tr(context, 'settings.title')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Theme toggle
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, _) => SwitchListTile(
                title: Text(tr(context, 'settings.mobileDarkMode')),
                value: themeProvider.isDarkMode,
                onChanged: (value) => themeProvider.toggleTheme(value),
              ),
            ),
            Consumer<LanguageProvider>(
              builder: (context, languageProvider, _) {
                final currentLanguage =
                languageProvider.locale.languageCode == 'pl'
                    ? 'Polski'
                    : (languageProvider.locale.languageCode == 'de'
                    ? 'Deutsch'
                    : 'English');
                return ListTile(
                  title: Text(tr(context, 'settings.language')),
                  subtitle: Text(currentLanguage),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    layoutState.showLanguageSelectionDialog(context);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}