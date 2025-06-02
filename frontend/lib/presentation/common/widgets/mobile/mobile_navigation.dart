import 'package:flutter/material.dart';

import '../../../../core/utils/translation_helper.dart';

class MobileNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const MobileNavigation({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: tr(context, 'navigation.home'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map),
          label: tr(context, 'navigation.tripPlanner'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history),
          label: tr(context, 'navigation.yourTrips'),
        ),
      ],
    );
  }
}
