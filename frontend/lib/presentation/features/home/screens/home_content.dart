import 'package:flutter/material.dart';
import 'package:frontend/presentation/features/home/widgets/welcome_section.dart';
import 'package:frontend/presentation/features/home/widgets/recent_trip_section.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (MediaQuery.of(context).size.width < 600) {
          return _buildMobileLayout(context);
        } else if (MediaQuery.of(context).size.width < 1200) {
          return _buildTabletLayout(context);
        } else {
          return _buildDesktopLayout(context);
        }
      },
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const WelcomeSection(isMobile: true),
            const SizedBox(height: 24),
            const RecentTripSection(crossAxisCount: 1),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const WelcomeSection(isMobile: false),
            const SizedBox(height: 32),
            const RecentTripSection(crossAxisCount: 2),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const WelcomeSection(isMobile: false),
            const SizedBox(height: 40),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  flex: 2,
                  child: RecentTripSection(crossAxisCount: 2),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
