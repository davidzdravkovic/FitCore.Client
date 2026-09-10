import 'package:fitcore_client/core/api/api_client.dart';
import 'package:fitcore_client/core/auth/portal_auth_models.dart';
import 'package:fitcore_client/core/widgets/auth/password_login_form.dart';
import 'package:fitcore_client/features/staff/auth/api/staff_auth_api.dart';
import 'package:fitcore_client/features/staff/auth/staff_session.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StaffLoginPage extends StatelessWidget {
  const StaffLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final api = StaffAuthApi();

    return PasswordLoginForm(
      subtitle: 'Staff sign in',
      emailHint: 'coach@gym.com',
      onSubmit: (email, password) async {
        final response = await api.login(
          EmailPasswordLoginRequest(email: email, password: password),
        );

        if (!context.mounted) return;

        ApiClient.instance.setAccessToken(response.accessToken);
        StaffSession.set(
          organizationName: response.organizationName,
          firstName: response.firstName,
        );
        context.go('/staff');
      },
    );
  }
}
