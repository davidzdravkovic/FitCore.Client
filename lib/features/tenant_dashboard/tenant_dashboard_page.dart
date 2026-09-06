import 'package:fitcore_client/core/api/api_client.dart';
import 'package:fitcore_client/features/tenant_dashboard/models/dashboard_nav_item.dart';
import 'package:fitcore_client/features/tenant_dashboard/tenant_session.dart';
import 'package:fitcore_client/features/tenant_dashboard/widgets/dashboard_shell.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TenantDashboardPage extends StatefulWidget {
  const TenantDashboardPage({super.key});

  @override
  State<TenantDashboardPage> createState() => _TenantDashboardPageState();
}

class _TenantDashboardPageState extends State<TenantDashboardPage> {
  DashboardSection _selected = DashboardSection.overview;

  void _signOut() {
    ApiClient.instance.setAccessToken(null);
    TenantSession.clear();
    context.go('/tenant/registry');
  }

  @override
  Widget build(BuildContext context) {
    final orgName = TenantSession.organizationName?.trim();
    final firstName = TenantSession.ownerFirstName?.trim();

    return DashboardShell(
      selected: _selected,
      onSelect: (section) => setState(() => _selected = section),
      organizationName:
          (orgName != null && orgName.isNotEmpty) ? orgName : 'Your gym',
      ownerName:
          (firstName != null && firstName.isNotEmpty) ? firstName : 'Owner',
      onSignOut: _signOut,
    );
  }
}
