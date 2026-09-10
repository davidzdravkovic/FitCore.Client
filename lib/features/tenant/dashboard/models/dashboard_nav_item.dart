import 'package:flutter/material.dart';

enum DashboardSection {
  overview,
  members,
  memberships,
  schedule,
  checkIns,
  staff,
  billing,
  settings,
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
