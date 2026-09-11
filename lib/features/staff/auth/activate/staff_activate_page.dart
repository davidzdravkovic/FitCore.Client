import 'package:fitcore_client/core/api/api_client.dart';
import 'package:fitcore_client/core/auth/portal_auth_models.dart';
import 'package:fitcore_client/core/widgets/auth/invite_activate_form.dart';
import 'package:fitcore_client/features/staff/auth/api/staff_auth_api.dart';
import 'package:fitcore_client/features/staff/auth/staff_session.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StaffActivatePage extends StatelessWidget {
  const StaffActivatePage({super.key, this.token});

  final String? token;

  @override
  Widget build(BuildContext context) {
    final api = StaffAuthApi();

    Future<void> setPassword(String inviteToken, String password) async {
      final response = await api.activate(
        InviteActivateRequest(token: inviteToken, password: password),
      );

      if (!context.mounted) return;

      ApiClient.instance.setAccessToken(response.accessToken);
      StaffSession.set(
        organizationName: response.organizationName,
        firstName: response.firstName,
      );
      context.go('/staff');
    }

    return InviteActivateForm(
      token: token,
      instructionsWithToken:
          'Choose a password to finish setting up your staff access.',
      missingTokenLoginLabel: 'Go to staff sign in',
      onMissingTokenLogin: () => context.go('/staff/login'),
      onSubmit: (inviteToken, password) async {
        await setPassword(inviteToken, password);
      },
    );
  }
}
