import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/translation_helper.dart';

class WelcomeCTABanner extends StatelessWidget {
  const WelcomeCTABanner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20.0 : 40.0,
        vertical: 24.0,
      ),
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 16.0 : 32.0,
        vertical: 24.0,
      ),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment:
            isMobile ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Text(
            tr(context, 'welcome.ctaBanner'),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.white, height: 1.4),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          if (isMobile)
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => context.go('/trip-planner'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(tr(context, 'welcome.tryNow')),
              ),
            )
          else
            FilledButton(
              onPressed: () => context.go('/trip-planner'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: Text(tr(context, 'welcome.tryNow')),
            ),
        ],
      ),
    );
  }
}
