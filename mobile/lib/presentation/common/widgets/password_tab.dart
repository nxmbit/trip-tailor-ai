import 'package:flutter/material.dart';
import 'package:frontend/core/utils/translation_helper.dart';
import '../../state/profile_management_state.dart';

class PasswordTab extends StatelessWidget {
  final ProfileManagementState state;
  final bool useFormKey;
  const PasswordTab({required this.state, this.useFormKey = true, super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: useFormKey ? state.passwordFormKey : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tr(context, 'profileSettings.password.title'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Text(tr(context, 'profileSettings.password.description')),
              const SizedBox(height: 24),
              TextFormField(
                controller: state.currentPasswordController,
                decoration: InputDecoration(
                  labelText: tr(context, 'profileSettings.password.current'),
                  border: const OutlineInputBorder(),
                ),
                obscureText: true,
                validator:
                    useFormKey
                        ? (value) =>
                            state.validateCurrentPassword(value, context, tr)
                        : null,
                enabled: !state.isLoading,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: state.newPasswordController,
                decoration: InputDecoration(
                  labelText: tr(context, 'profileSettings.password.new'),
                  border: const OutlineInputBorder(),
                ),
                obscureText: true,
                validator:
                    useFormKey
                        ? (value) =>
                            state.validateNewPassword(value, context, tr)
                        : null,
                enabled: !state.isLoading,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: state.confirmPasswordController,
                decoration: InputDecoration(
                  labelText: tr(context, 'profileSettings.password.confirm'),
                  border: const OutlineInputBorder(),
                ),
                obscureText: true,
                validator:
                    useFormKey
                        ? (value) =>
                            state.validateConfirmPassword(value, context, tr)
                        : null,
                enabled: !state.isLoading,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: state.isLoading ? null : state.updatePassword,
                  child:
                      state.isLoading && state.selectedTabIndex == 2
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : Text(tr(context, 'profileSettings.password.save')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
