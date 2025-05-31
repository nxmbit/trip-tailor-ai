import 'package:flutter/material.dart';
import 'package:frontend/core/utils/translation_helper.dart';
import 'package:frontend/presentation/state/providers/language_provider.dart';

class LanguageSelectionDialog extends StatelessWidget {
  final LanguageProvider languageProvider;

  const LanguageSelectionDialog({
    super.key,
    required this.languageProvider,
  });

  @override
  Widget build(BuildContext context) {
    final languages = [
      {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
      {'code': 'pl', 'name': 'Polski', 'flag': '🇵🇱'},
      {'code': 'de', 'name': 'Deutsch', 'flag': '🇩🇪'},
    ];

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
                },
              );
            },
          ),
        ],
      ),
    );
  }
}