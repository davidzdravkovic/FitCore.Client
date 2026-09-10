import 'package:fitcore_client/core/api/api_client.dart';
import 'package:fitcore_client/core/auth/portal_auth_models.dart';
import 'package:fitcore_client/core/widgets/auth/password_login_form.dart';
import 'package:fitcore_client/features/member/auth/api/member_auth_api.dart';
import 'package:fitcore_client/features/member/auth/member_session.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MemberLoginPage extends StatelessWidget {
  const MemberLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final api = MemberAuthApi();

    return PasswordLoginForm(
      subtitle: 'Member sign in',
      emailHint: 'you@email.com',
      onSubmit: (email, password) async {
        final response = await api.login(
          EmailPasswordLoginRequest(email: email, password: password),
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
