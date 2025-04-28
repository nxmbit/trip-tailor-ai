import 'dart:math';
import 'package:flutter/material.dart';
import 'package:frontend/presentation/state/providers/language_provider.dart';
import 'package:frontend/presentation/state/providers/theme_provider.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/translation_helper.dart';

class SettingsDialog extends StatefulWidget {
  final VoidCallback onBackPressed;

  const SettingsDialog({Key? key, required this.onBackPressed})
    : super(key: key);

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  String selectedLang = 'English';
  final TextEditingController languageController = TextEditingController();
  final List<DropdownMenuEntry<String>> languages = [
    const DropdownMenuEntry(value: 'English', label: 'English'),
    const DropdownMenuEntry(value: 'Polski', label: 'Polski'),
  ];
  @override
  void initState() {
    super.initState();
    // Initialize selected language from provider
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    selectedLang =
        languageProvider.locale.languageCode == 'pl' ? 'Polski' : 'English';
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final size = MediaQuery.of(context).size;
    final double maxWidth = size.width * 0.9;
    final double maxHeight = size.height * 0.8;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: size.width * 0.05,
        vertical: size.height * 0.05,
      ),
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
        width: min(400, maxWidth), // Fixed width with max limit
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: widget.onBackPressed,
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        tr(context, 'settings.title'),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40), // Balance the row
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LayoutBuilder(
                        builder: (context, constraints) {
                          return DropdownMenu<String>(
                            initialSelection: selectedLang,
                            controller: languageController,
                            requestFocusOnTap: false,
                            label: Text(tr(context, 'settings.language')),
                            onSelected: (String? language) {
                              setState(() {
                                selectedLang = language ?? 'English';
                                // Update language when selection changes
                                if (language == 'Polski') {
                                  languageProvider.setLanguage('pl');
                                } else {
                                  languageProvider.setLanguage('en');
                                }
                              });
                            },
                            dropdownMenuEntries: languages,
                            width: constraints.maxWidth,
                          );
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: tr(context, 'settings.theme'),
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        themeProvider.isDarkMode
                                            ? tr(context, 'settings.darkTheme')
                                            : tr(
                                              context,
                                              'settings.lightTheme',
                                            ),
                                        style: TextStyle(
                                          fontSize: 20,
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.onSurface,
                                        ),
                                      ),
                                      Switch(
                                        value: themeProvider.isDarkMode,
                                        onChanged: (value) {
                                          themeProvider.toggleTheme(value);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
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
