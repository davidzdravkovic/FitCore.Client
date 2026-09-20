import 'package:fitcore_client/core/routing/tenant_paths.dart';
import 'package:flutter/material.dart';

enum DashboardSection {
  overview,
  members,
  services,
  plans,
  memberships,
  schedule,
  staff,
  billing,
  settings;

  String get location => switch (this) {
        DashboardSection.overview => TenantPaths.home,
        DashboardSection.members => TenantPaths.members,
        DashboardSection.services => TenantPaths.services,
        DashboardSection.plans => TenantPaths.plans,
        DashboardSection.memberships => TenantPaths.memberships,
        DashboardSection.schedule => TenantPaths.schedule,
        DashboardSection.staff => TenantPaths.staff,
        DashboardSection.billing => TenantPaths.billing,
        DashboardSection.settings => TenantPaths.settings,
      };

  static DashboardSection fromLocation(String path) {
    // Longer prefixes first so memberships ≠ members.
    if (path == TenantPaths.home || path == '${TenantPaths.home}/') {
      return DashboardSection.overview;
    }
    if (path.startsWith(TenantPaths.memberships)) {
      return DashboardSection.memberships;
    }
    if (path.startsWith(TenantPaths.members)) return DashboardSection.members;
    if (path.startsWith(TenantPaths.services)) return DashboardSection.services;
    if (path.startsWith(TenantPaths.plans)) return DashboardSection.plans;
    if (path.startsWith(TenantPaths.schedule)) return DashboardSection.schedule;
    if (path.startsWith(TenantPaths.staff)) return DashboardSection.staff;
    if (path.startsWith(TenantPaths.billing)) return DashboardSection.billing;
    if (path.startsWith(TenantPaths.settings)) return DashboardSection.settings;
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
    section: DashboardSection.services,
    label: 'Services',
    icon: Icons.fitness_center_outlined,
  ),
  DashboardNavItem(
    section: DashboardSection.plans,
    label: 'Plans',
    icon: Icons.sell_outlined,
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
