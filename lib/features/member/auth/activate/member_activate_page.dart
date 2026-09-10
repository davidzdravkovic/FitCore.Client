import 'package:fitcore_client/core/api/api_client.dart';
import 'package:fitcore_client/core/auth/portal_auth_models.dart';
import 'package:fitcore_client/core/widgets/auth/invite_activate_form.dart';
import 'package:fitcore_client/features/member/auth/api/member_auth_api.dart';
import 'package:fitcore_client/features/member/auth/member_session.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MemberActivatePage extends StatelessWidget {
  const MemberActivatePage({super.key, this.token});

  final String? token;

  @override
  Widget build(BuildContext context) {
    final api = MemberAuthApi();

    return InviteActivateForm(
      token: token,
      instructionsWithToken:
          'Choose a password to finish setting up your account.',
      missingTokenLoginLabel: 'Go to member sign in',
      onMissingTokenLogin: () => context.go('/member/login'),
      onSubmit: (inviteToken, password) async {
        final response = await api.activate(
          InviteActivateRequest(token: inviteToken, password: password),
        );

        if (!context.mounted) return;

        ApiClient.instance.setAccessToken(response.accessToken);
        MemberSession.set(
          organizationName: response.organizationName,
          firstName: response.firstName,
        );
        context.go('/member');
      },
    );
  }
}
