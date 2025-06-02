import 'dart:math';
import 'package:flutter/material.dart';
import 'package:frontend/presentation/state/providers/language_provider.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/translation_helper.dart';
import '../../state/providers/theme_provider.dart';

class SettingsDialog extends StatefulWidget {
  final VoidCallback onBackPressed;

  const SettingsDialog({Key? key, required this.onBackPressed})
    : super(key: key);

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  String selectedLang = 'English';

  // Language data with flags
  final List<Map<String, dynamic>> languageOptions = [
    {'value': 'English', 'label': 'English', 'flag': '🇬🇧', 'code': 'en'},
    {'value': 'Polski', 'label': 'Polski', 'flag': '🇵🇱', 'code': 'pl'},
    {'value': 'Deutsch', 'label': 'Deutsch', 'flag': '🇩🇪', 'code': 'de'},
  ];

  @override
  void initState() {
    super.initState();
    // Initialize selected language from provider
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );

    // Update to handle German language
    final languageCode = languageProvider.locale.languageCode;
    selectedLang =
        languageCode == 'pl'
            ? 'Polski'
            : (languageCode == 'de' ? 'Deutsch' : 'English');
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final size = MediaQuery.of(context).size;
    final double maxWidth = size.width * 0.9;
    final double maxHeight = size.height * 0.8;
    final languageProvider = Provider.of<LanguageProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      elevation: 8,
      insetPadding: EdgeInsets.symmetric(
        horizontal: size.width * 0.05,
        vertical: size.height * 0.05,
      ),
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
        width: min(450, maxWidth),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16.0)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: 16.0,
                horizontal: 16.0,
              ),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16.0),
                  topRight: Radius.circular(16.0),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: widget.onBackPressed,
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        tr(context, 'settings.title'),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // LANGUAGE SECTION HEADER
                      Text(
                        tr(context, 'settings.language'),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // LANGUAGE SELECTION CARDS
                      Card(
                        elevation: 2,
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Theme.of(
                              context,
                            ).colorScheme.outline.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children:
                              languageOptions.map((language) {
                                bool isSelected =
                                    selectedLang == language['value'];
                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      selectedLang = language['value'];
                                      languageProvider.setLanguage(
                                        language['code'],
                                      );
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 2.0,
                                    ),
                                    child: ListTile(
                                      leading: Text(
                                        language['flag'],
                                        style: const TextStyle(fontSize: 24),
                                      ),
                                      title: Text(
                                        language['label'],
                                        style: TextStyle(
                                          fontWeight:
                                              isSelected
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                        ),
                                      ),
                                      trailing:
                                          isSelected
                                              ? Icon(
                                                Icons.check_circle,
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.primary,
                                              )
                                              : null,
                                      selected: isSelected,
                                      selectedColor:
                                          Theme.of(context).colorScheme.primary,
                                      selectedTileColor: Theme.of(context)
                                          .colorScheme
                                          .primaryContainer
                                          .withOpacity(0.2),
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // THEME SECTION
                      Text(
                        tr(context, 'settings.theme'),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(height: 12),

                      Card(
                        elevation: 2,
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Theme.of(
                              context,
                            ).colorScheme.outline.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Column(
                            children: [
                              ListTile(
                                leading: Icon(
                                  themeProvider.isDarkMode
                                      ? Icons.dark_mode
                                      : Icons.light_mode,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 28,
                                ),
                                title: Text(
                                  tr(context, 'settings.theme'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                subtitle: Text(
                                  themeProvider.isDarkMode
                                      ? tr(context, 'settings.darkTheme')
                                      : tr(context, 'settings.lightTheme'),
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.secondary.withOpacity(0.8),
                                  ),
                                ),
                                trailing: Switch(
                                  value: themeProvider.isDarkMode,
                                  onChanged: (bool value) {
                                    Provider.of<ThemeProvider>(
                                      context,
                                      listen: false,
                                    ).toggleTheme(value);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
