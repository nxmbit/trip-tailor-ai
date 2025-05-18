import 'package:flutter/material.dart';
import '../../../../core/utils/translation_helper.dart';

class WelcomeFooter extends StatelessWidget {
  const WelcomeFooter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: 24,
        horizontal: isMobile ? 20 : 40,
      ),
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      child: Text(
        '© 2025 TripTailor. ${tr(context, 'welcome.footerRights')}',
        style: Theme.of(context).textTheme.bodySmall,
        textAlign: TextAlign.center,
      ),
    );
  }
}
