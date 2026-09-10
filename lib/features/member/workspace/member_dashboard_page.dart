import 'package:fitcore_client/core/api/api_client.dart';
import 'package:fitcore_client/core/widgets/auth/portal_placeholder_dashboard.dart';
import 'package:fitcore_client/features/member/auth/member_session.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MemberDashboardPage extends StatelessWidget {
  const MemberDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final orgName = MemberSession.organizationName?.trim();

    return PortalPlaceholderDashboard(
      title: (orgName != null && orgName.isNotEmpty) ? orgName : 'Member',
      firstName: MemberSession.firstName,
      icon: Icons.person_outline,
      body:
          'Your member area is empty for now. '
          'Bookings, memberships, and check-ins will show up here.',
      onSignOut: () {
        ApiClient.instance.setAccessToken(null);
        MemberSession.clear();
        context.go('/member/login');
      },
    );
  }
}
