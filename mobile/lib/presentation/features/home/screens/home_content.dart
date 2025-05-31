import 'package:flutter/material.dart';
import 'package:frontend/presentation/features/home/widgets/welcome_section.dart';
import 'package:frontend/presentation/features/home/widgets/recent_trip_section.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const WelcomeSection(),
            const SizedBox(height: 24),
            const RecentTripSection(crossAxisCount: 1),
          ],
        ),
      ),
    );
  }
}
