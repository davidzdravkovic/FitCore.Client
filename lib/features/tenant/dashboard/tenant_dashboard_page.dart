import 'package:fitcore_client/core/api/api_client.dart';
import 'package:fitcore_client/features/tenant/auth/tenant_session.dart';
import 'package:fitcore_client/features/tenant/dashboard/widgets/dashboard_shell.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TenantDashboardPage extends StatelessWidget {
  const TenantDashboardPage({super.key, required this.child});

  final Widget child;

  void _signOut(BuildContext context) {
    ApiClient.instance.setAccessToken(null);
    TenantSession.clear();
    context.go('/tenant/login');
  }

  @override
  Widget build(BuildContext context) {
    final orgName = TenantSession.organizationName?.trim();
    final firstName = TenantSession.ownerFirstName?.trim();

    return DashboardShell(
      organizationName:
          (orgName != null && orgName.isNotEmpty) ? orgName : 'Your gym',
      ownerName:
          (firstName != null && firstName.isNotEmpty) ? firstName : 'Owner',
      onSignOut: () => _signOut(context),
      child: child,
    );
  }
}
