import 'package:flutter/material.dart';
import '../../../../core/utils/translation_helper.dart';

class WelcomeFAQSection extends StatelessWidget {
  const WelcomeFAQSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        children: [
          Text(
            tr(context, 'welcome.faqsTitle'),
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          // Simple FAQ preview list
          _buildFaqItem(context, 'welcome.faq1Question', 'welcome.faq1Answer'),
          _buildFaqItem(context, 'welcome.faq2Question', 'welcome.faq2Answer'),
        ],
      ),
    );
  }

  Widget _buildFaqItem(
    BuildContext context,
    String questionKey,
    String answerKey,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ExpansionTile(
        title: Text(
          tr(context, questionKey),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              tr(context, answerKey),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
