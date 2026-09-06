import 'package:fitcore_client/features/tenant_dashboard/helpers/dashboard_layout.dart';
import 'package:fitcore_client/features/tenant_dashboard/models/dashboard_nav_item.dart';
import 'package:fitcore_client/features/tenant_dashboard/widgets/dashboard_placeholder_panel.dart';
import 'package:fitcore_client/features/tenant_dashboard/widgets/dashboard_sidebar.dart';
import 'package:fitcore_client/features/tenant_dashboard/widgets/dashboard_top_bar.dart';
import 'package:fitcore_client/features/tenant_dashboard/widgets/overview/overview_page.dart';
import 'package:flutter/material.dart';

class DashboardShell extends StatelessWidget {
  const DashboardShell({
    super.key,
    required this.selected,
    required this.onSelect,
    required this.organizationName,
    required this.ownerName,
    required this.onSignOut,
  });

  final DashboardSection selected;
  final ValueChanged<DashboardSection> onSelect;
  final String organizationName;
  final String ownerName;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >=
        DashboardLayout.sidebarCollapsedBreakpoint;
    final dividerColor =
        Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.55);

    final sectionBody = _SectionBody(
      section: selected,
      ownerFirstName: ownerName,
      organizationName: organizationName,
    );

    if (wide) {
      return Scaffold(
        body: SafeArea(
          child: Row(
            children: [
              SizedBox(
                width: DashboardLayout.sidebarWidth,
                child: DashboardSidebar(
                  selected: selected,
                  onSelect: onSelect,
                  organizationName: organizationName,
                ),
              ),
              VerticalDivider(width: 1, thickness: 1, color: dividerColor),
              Expanded(
                child: Column(
                  children: [
                    DashboardTopBar(
                      title: dashboardSectionTitle(selected),
                      ownerName: ownerName,
                      onSignOut: onSignOut,
                    ),
                    Expanded(child: sectionBody),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      drawer: Drawer(
        child: SafeArea(
          child: DashboardSidebar(
            selected: selected,
            onSelect: (section) {
              onSelect(section);
              Navigator.of(context).pop();
            },
            organizationName: organizationName,
          ),
        ),
      ),
      body: SafeArea(
        child: Builder(
          builder: (scaffoldContext) {
            return Column(
              children: [
                DashboardTopBar(
                  title: dashboardSectionTitle(selected),
                  ownerName: ownerName,
                  onSignOut: onSignOut,
                  onOpenMenu: () => Scaffold.of(scaffoldContext).openDrawer(),
                ),
                Expanded(child: sectionBody),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SectionBody extends StatelessWidget {
  const _SectionBody({
    required this.section,
    required this.ownerFirstName,
    required this.organizationName,
  });

  final DashboardSection section;
  final String ownerFirstName;
  final String organizationName;

  @override
  Widget build(BuildContext context) {
    return switch (section) {
      DashboardSection.overview => OverviewPage(
          ownerFirstName: ownerFirstName,
          organizationName: organizationName,
        ),
      DashboardSection.members => const DashboardPlaceholderPanel(
          title: 'Members',
          description:
              'Member profiles, status, and contact details will live here.',
          icon: Icons.people_outline,
        ),
      DashboardSection.memberships => const DashboardPlaceholderPanel(
          title: 'Memberships',
          description:
              'Plans, renewals, and freezes will be managed from this section.',
          icon: Icons.card_membership_outlined,
        ),
      DashboardSection.schedule => const DashboardPlaceholderPanel(
          title: 'Schedule',
          description:
              'Classes, trainers, and recurring sessions will show up here.',
          icon: Icons.calendar_today_outlined,
        ),
      DashboardSection.checkIns => const DashboardPlaceholderPanel(
          title: 'Check-ins',
          description:
              'Front-desk and QR check-ins will be tracked in this workspace.',
          icon: Icons.qr_code_scanner_outlined,
        ),
      DashboardSection.staff => const DashboardPlaceholderPanel(
          title: 'Staff',
          description:
              'Coaches, roles, and permissions will be configured here.',
          icon: Icons.badge_outlined,
        ),
      DashboardSection.billing => const DashboardPlaceholderPanel(
          title: 'Billing',
          description:
              'Invoices, payments, and failed charges will appear in this area.',
          icon: Icons.payments_outlined,
        ),
      DashboardSection.settings => const DashboardPlaceholderPanel(
          title: 'Settings',
          description:
              'Gym profile, timezone, and workspace preferences will go here.',
          icon: Icons.settings_outlined,
        ),
    };
  }
}
