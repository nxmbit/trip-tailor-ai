import 'package:flutter/material.dart';
import 'package:frontend/presentation/common/widgets/tablet_desktop/tablet_navigation.dart';
import '../../../core/utils/translation_helper.dart';
import '../../state/layout_state.dart';
import '../widgets/user_section.dart';

class TabletScaffold extends StatefulWidget {
  final Widget child;

  const TabletScaffold({Key? key, required this.child}) : super(key: key);

  @override
  State<TabletScaffold> createState() => _TabletScaffoldState();
}

class _TabletScaffoldState extends State<TabletScaffold> {
  final _scaffoldState = LayoutState();

  @override
  void initState() {
    super.initState();
    // Set the selected index based on the current route
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scaffoldState.updateSelectedIndexFromRoute(context);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Update when dependencies change (including navigation)
    _scaffoldState.updateSelectedIndexFromRoute(context);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: colorScheme.surfaceContainerLowest,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Text(
              tr(context, 'app.title'),
              style: textTheme.displayLarge?.copyWith(
                color: colorScheme.primary,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          UserSection(
            onTap: () => _scaffoldState.showActionsDialog(context),
            displayMode: UserSectionDisplayMode.tablet,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        children: [
          TabletNavigation(
            selectedIndex: _scaffoldState.currentIndex,
            onDestinationSelected:
                (index) => _scaffoldState.navigateToIndex(index, context),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          // Main content
          Expanded(child: SafeArea(child: widget.child)),
        ],
      ),
    );
  }
}
