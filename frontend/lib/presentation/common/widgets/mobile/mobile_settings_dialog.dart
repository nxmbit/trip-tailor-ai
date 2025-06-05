import 'package:flutter/material.dart';
import 'package:frontend/core/utils/translation_helper.dart';
import 'package:frontend/presentation/state/providers/language_provider.dart';
import 'package:frontend/presentation/state/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class MobileSettings extends StatefulWidget {
  const MobileSettings({super.key});

  @override
  State<MobileSettings> createState() => _MobileSettingsState();
}

class _MobileSettingsState extends State<MobileSettings> {
  void _showLanguageSelectionDialog(
    BuildContext context,
    LanguageProvider languageProvider,
  ) {
    final languages = [
      {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
      {'code': 'pl', 'name': 'Polski', 'flag': '🇵🇱'},
      {'code': 'de', 'name': 'Deutsch', 'flag': '🇩🇪'},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Text(
                      tr(context, 'settings.language'),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(),
              ListView.builder(
                shrinkWrap: true,
                itemCount: languages.length,
                itemBuilder: (context, index) {
                  final language = languages[index];
                  final bool isSelected =
                      language['code'] == languageProvider.locale.languageCode;

                  return ListTile(
                    leading: Text(
                      language['flag']!,
                      style: const TextStyle(fontSize: 24),
                    ),
                    title: Text(language['name']!),
                    trailing:
                        isSelected
                            ? Icon(
                              Icons.check_circle,
                              color: Theme.of(context).colorScheme.primary,
                            )
                            : null,
                    onTap: () {
                      languageProvider.setLanguage(language['code']!);
                      Navigator.pop(context);
                      // Refresh the dialog after language change
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder:
          (context, languageProvider, _) => Scaffold(
            appBar: AppBar(
              title: Text(tr(context, 'settings.title')),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Consumer<ThemeProvider>(
                    builder:
                        (context, themeProvider, _) => SwitchListTile(
                          title: Text(tr(context, 'settings.mobileDarkMode')),
                          value: themeProvider.isDarkMode,
                          onChanged:
                              (value) => themeProvider.toggleTheme(value),
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
                          _showLanguageSelectionDialog(
                            context,
                            languageProvider,
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
