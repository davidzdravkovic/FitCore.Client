import 'package:flutter/material.dart';

enum DashboardSection {
  overview,
  members,
  memberships,
  schedule,
  checkIns,
  staff,
  billing,
  settings;

  String get location => switch (this) {
        DashboardSection.overview => '/tenant',
        DashboardSection.members => '/tenant/members',
        DashboardSection.memberships => '/tenant/memberships',
        DashboardSection.schedule => '/tenant/schedule',
        DashboardSection.checkIns => '/tenant/check-ins',
        DashboardSection.staff => '/tenant/staff',
        DashboardSection.billing => '/tenant/billing',
        DashboardSection.settings => '/tenant/settings',
      };

  static DashboardSection fromLocation(String path) {
    // Longer prefixes first so /tenant/memberships ≠ /tenant/members.
    if (path == '/tenant' || path == '/tenant/') return DashboardSection.overview;
    if (path.startsWith('/tenant/memberships')) {
      return DashboardSection.memberships;
    }
    if (path.startsWith('/tenant/members')) return DashboardSection.members;
    if (path.startsWith('/tenant/schedule')) return DashboardSection.schedule;
    if (path.startsWith('/tenant/check-ins')) return DashboardSection.checkIns;
    if (path.startsWith('/tenant/staff')) return DashboardSection.staff;
    if (path.startsWith('/tenant/billing')) return DashboardSection.billing;
    if (path.startsWith('/tenant/settings')) return DashboardSection.settings;
    return DashboardSection.overview;
  }
}

class DashboardNavItem {
  const DashboardNavItem({
    required this.section,
    required this.label,
    required this.icon,
  });

  final DashboardSection section;
  final String label;
  final IconData icon;
}

const List<DashboardNavItem> dashboardNavItems = [
  DashboardNavItem(
    section: DashboardSection.overview,
    label: 'Overview',
    icon: Icons.dashboard_outlined,
  ),
  DashboardNavItem(
    section: DashboardSection.members,
    label: 'Members',
    icon: Icons.people_outline,
  ),
  DashboardNavItem(
    section: DashboardSection.memberships,
    label: 'Memberships',
    icon: Icons.card_membership_outlined,
  ),
  DashboardNavItem(
    section: DashboardSection.schedule,
    label: 'Schedule',
    icon: Icons.calendar_today_outlined,
  ),
  DashboardNavItem(
    section: DashboardSection.checkIns,
    label: 'Check-ins',
    icon: Icons.qr_code_scanner_outlined,
  ),
  DashboardNavItem(
    section: DashboardSection.staff,
    label: 'Staff',
    icon: Icons.badge_outlined,
  ),
  DashboardNavItem(
    section: DashboardSection.billing,
    label: 'Billing',
    icon: Icons.payments_outlined,
  ),
  DashboardNavItem(
    section: DashboardSection.settings,
    label: 'Settings',
    icon: Icons.settings_outlined,
  ),
];
