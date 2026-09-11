import 'package:fitcore_client/features/tenant/auth/login/tenant_login_page.dart';
import 'package:fitcore_client/features/tenant/auth/registry/tenant_registry_page.dart';
import 'package:fitcore_client/features/tenant/auth/tenant_session.dart';
import 'package:fitcore_client/features/tenant/dashboard/tenant_dashboard_page.dart';
import 'package:fitcore_client/features/tenant/dashboard/widgets/dashboard_placeholder_panel.dart';
import 'package:fitcore_client/features/tenant/dashboard/widgets/overview/overview_page.dart';
import 'package:fitcore_client/features/tenant/members/widgets/members_panel.dart';
import 'package:fitcore_client/features/tenant/staff/widgets/staff_panel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final List<RouteBase> tenantRoutes = [
  GoRoute(
    path: '/tenant/login',
    builder: (context, state) => const TenantLoginPage(),
  ),
  GoRoute(
    path: '/tenant/registry',
    builder: (context, state) {
      final token = state.uri.queryParameters['token'];
      return TenantRegistryPage(token: token);
    },
  ),
  ShellRoute(
    builder: (context, state, child) => TenantDashboardPage(child: child),
    routes: [
      GoRoute(
        path: '/tenant',
        builder: (context, state) {
          final orgName = TenantSession.organizationName?.trim() ?? '';
          final firstName = TenantSession.ownerFirstName?.trim() ?? '';
          return OverviewPage(
            ownerFirstName: firstName.isNotEmpty ? firstName : 'Owner',
            organizationName: orgName.isNotEmpty ? orgName : 'Your gym',
          );
        },
      ),
      GoRoute(
        path: '/tenant/members',
        builder: (context, state) => const MembersPanel(),
      ),
      GoRoute(
        path: '/tenant/memberships',
        builder: (context, state) => const DashboardPlaceholderPanel(
          title: 'Memberships',
          description:
              'Plans, renewals, and freezes will be managed from this section.',
          icon: Icons.card_membership_outlined,
        ),
      ),
      GoRoute(
        path: '/tenant/schedule',
        builder: (context, state) => const DashboardPlaceholderPanel(
          title: 'Schedule',
          description:
              'Classes, trainers, and recurring sessions will show up here.',
          icon: Icons.calendar_today_outlined,
        ),
      ),
      GoRoute(
        path: '/tenant/check-ins',
        builder: (context, state) => const DashboardPlaceholderPanel(
          title: 'Check-ins',
          description:
              'Front-desk and QR check-ins will be tracked in this workspace.',
          icon: Icons.qr_code_scanner_outlined,
        ),
      ),
      GoRoute(
        path: '/tenant/staff',
        builder: (context, state) => const StaffPanel(),
      ),
      GoRoute(
        path: '/tenant/billing',
        builder: (context, state) => const DashboardPlaceholderPanel(
          title: 'Billing',
          description:
              'Invoices, payments, and failed charges will appear in this area.',
          icon: Icons.payments_outlined,
        ),
      ),
      GoRoute(
        path: '/tenant/settings',
        builder: (context, state) => const DashboardPlaceholderPanel(
          title: 'Settings',
          description:
              'Gym profile, timezone, and workspace preferences will go here.',
          icon: Icons.settings_outlined,
        ),
      ),
    ],
  ),
];
