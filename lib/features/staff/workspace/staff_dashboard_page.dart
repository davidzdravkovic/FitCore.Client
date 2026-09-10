import 'package:fitcore_client/core/api/api_client.dart';
import 'package:fitcore_client/core/widgets/auth/portal_placeholder_dashboard.dart';
import 'package:fitcore_client/features/staff/auth/staff_session.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StaffDashboardPage extends StatelessWidget {
  const StaffDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final orgName = StaffSession.organizationName?.trim();

    return PortalPlaceholderDashboard(
      title: (orgName != null && orgName.isNotEmpty) ? orgName : 'Staff',
      firstName: StaffSession.firstName,
      icon: Icons.badge_outlined,
      body:
          'Your staff workspace is empty for now. '
          'Schedule, check-ins, and rosters will show up here.',
      onSignOut: () {
        ApiClient.instance.setAccessToken(null);
        StaffSession.clear();
        context.go('/staff/login');
      },
    );
  }
}
