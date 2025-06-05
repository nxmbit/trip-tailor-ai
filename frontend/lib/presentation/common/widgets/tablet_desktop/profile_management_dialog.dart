import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/utils/translation_helper.dart';
import 'package:frontend/domain/services/user_service.dart';
import 'package:frontend/presentation/state/providers/user_provider.dart';
import 'package:provider/provider.dart';

import '../../../state/profile_management_state.dart';
import '../password_tab.dart';
import '../profile_image_tab.dart';
import '../username_tab.dart';

class ProfileDialog extends StatelessWidget {
  final VoidCallback onBackPressed;

  const ProfileDialog({Key? key, required this.onBackPressed})
    : super(key: key);

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
            child: Dialog(
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 24,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minWidth: 320,
                  maxWidth: 420,
                  minHeight: 0,
                  maxHeight: 600,
                ),
                child: Builder(
                  builder: (context) {
                    final tabController = DefaultTabController.of(context);
                    tabController.addListener(() {
                      if (tabController.indexIsChanging) {
                        state.setTab(tabController.index);
                      }
                    });
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: onBackPressed,
                              ),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    tr(context, 'profileSettings.title'),
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 40),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                        TabBar(
                          controller: tabController,
                          tabs: [
                            Tab(text: tr(context, 'profileSettings.photoTab')),
                            Tab(
                              text: tr(context, 'profileSettings.usernameTab'),
                            ),
                            Tab(
                              text: tr(context, 'profileSettings.passwordTab'),
                            ),
                          ],
                        ),
                        if (state.error != null || state.success != null)
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child:
                                state.error != null
                                    ? Text(
                                      tr(context, state.error!),
                                      style: TextStyle(
                                        color:
                                            Theme.of(context).colorScheme.error,
                                      ),
                                      textAlign: TextAlign.center,
                                    )
                                    : Text(
                                      tr(context, state.success!),
                                      style: TextStyle(
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                          ),
                        Expanded(
                          child: TabBarView(
                            controller: tabController,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              ProfileImageTab(state: state),
                              UsernameTab(state: state),
                              PasswordTab(state: state),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
