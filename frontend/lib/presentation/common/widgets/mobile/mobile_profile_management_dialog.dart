import 'package:flutter/material.dart';
import 'package:frontend/core/utils/translation_helper.dart';
import 'package:frontend/domain/services/user_service.dart';
import 'package:frontend/presentation/state/providers/user_provider.dart';
import 'package:provider/provider.dart';
import '../../../state/profile_management_state.dart';
import '../password_tab.dart';
import '../profile_image_tab.dart';
import '../username_tab.dart';

class MobileProfileImageScreen extends StatelessWidget {
  const MobileProfileImageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create:
          (_) => ProfileManagementState(
            userService: Provider.of<UserService>(context, listen: false),
            userProvider: Provider.of<UserProvider>(context, listen: false),
          ),
      child: Consumer<ProfileManagementState>(
        builder: (context, state, _) {
          return DefaultTabController(
            length: 3,
            initialIndex: state.selectedTabIndex,
            child: Builder(
              builder: (context) {
                final tabController = DefaultTabController.of(context);
                tabController.addListener(() {
                  if (tabController.indexIsChanging) {
                    state.setTab(tabController.index);
                  }
                });
                return Scaffold(
                  appBar: AppBar(
                    title: Text(tr(context, 'profileSettings.title')),
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                    bottom: TabBar(
                      controller: tabController,
                      tabs: [
                        Tab(text: tr(context, 'profileSettings.photoTab')),
                        Tab(text: tr(context, 'profileSettings.usernameTab')),
                        Tab(text: tr(context, 'profileSettings.passwordTab')),
                      ],
                    ),
                  ),
                  body: Column(
                    children: [
                      if (state.error != null || state.success != null)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            state.error != null
                                ? tr(context, state.error!)
                                : tr(context, state.success!),
                            style: TextStyle(
                              color:
                                  state.error != null
                                      ? Theme.of(context).colorScheme.error
                                      : Theme.of(context).colorScheme.primary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      Expanded(
                        child: TabBarView(
                          controller: tabController,
                          children: [
                            ProfileImageTab(state: state),
                            UsernameTab(state: state),
                            PasswordTab(state: state),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
