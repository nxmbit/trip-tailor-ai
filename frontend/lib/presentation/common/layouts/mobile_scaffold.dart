import 'package:flutter/material.dart';
import 'package:frontend/presentation/common/widgets/mobile/mobile_navigation.dart';
import 'package:frontend/presentation/common/widgets/user_section.dart';

import '../../../core/utils/translation_helper.dart';
import '../../state/layout_state.dart';

class MobileScaffold extends StatefulWidget {
  final Widget child;

  const MobileScaffold({Key? key, required this.child}) : super(key: key);

  @override
  State<MobileScaffold> createState() => _MobileScaffoldState();
}

class _MobileScaffoldState extends State<MobileScaffold> {
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
        title: Text(
          tr(context, 'app.title'),
          style: textTheme.displayLarge?.copyWith(
            color: colorScheme.primary,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: UserSection(
              onTap:
                  () =>
                      _scaffoldState.showActionsDialog(context, isMobile: true),
              displayMode: UserSectionDisplayMode.mobile,
            ),
          ),
        ],
      ),
      body: SafeArea(child: widget.child),
      bottomNavigationBar: MobileNavigation(
        currentIndex: _scaffoldState.currentIndex,
        onTap: (index) {
          _scaffoldState.navigateToIndex(index, context);
        },
      ),
    );
  }
}
