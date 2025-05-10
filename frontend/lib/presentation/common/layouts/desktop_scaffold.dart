import 'package:flutter/material.dart';
import 'package:frontend/presentation/common/widgets/desktop_navigation.dart';
import 'package:frontend/presentation/common/widgets/user_section.dart';
import 'package:frontend/presentation/state/layout_state.dart';

class DesktopScaffold extends StatefulWidget {
  final Widget child;

  const DesktopScaffold({Key? key, required this.child}) : super(key: key);

  @override
  State<DesktopScaffold> createState() => _DesktopScaffoldState();
}

class _DesktopScaffoldState extends State<DesktopScaffold> {
  final _scaffoldState = LayoutState();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: colorScheme.surfaceContainerLowest,
        automaticallyImplyLeading: false,
        title: DesktopNavigation(),
        actions: [
          // Replace simple icon button with user profile display
          UserSection(
            onTap: () => _scaffoldState.showActionsDialog(context),
            displayMode: UserSectionDisplayMode.desktop,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        children: [
          // Main content
          Expanded(child: SafeArea(child: widget.child)),
        ],
      ),
    );
  }
}
