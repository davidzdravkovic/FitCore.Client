import 'package:fitcore_client/features/tenant/dashboard/helpers/dashboard_layout.dart';
import 'package:fitcore_client/features/tenant/dashboard/models/dashboard_nav_item.dart';
import 'package:fitcore_client/features/tenant/dashboard/widgets/dashboard_sidebar.dart';
import 'package:fitcore_client/features/tenant/dashboard/widgets/dashboard_top_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DashboardShell extends StatelessWidget {
  const DashboardShell({
    super.key,
    required this.organizationName,
    required this.ownerName,
    required this.onSignOut,
    required this.child,
  });

  final String organizationName;
  final String ownerName;
  final VoidCallback onSignOut;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    final selected = DashboardSection.fromLocation(path);
    final wide = MediaQuery.sizeOf(context).width >=
        DashboardLayout.sidebarCollapsedBreakpoint;
    final dividerColor =
        Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.55);

    if (wide) {
      return Scaffold(
        body: SafeArea(
          child: Row(
            children: [
              SizedBox(
                width: DashboardLayout.sidebarWidth,
                child: DashboardSidebar(
                  selected: selected,
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
                    Expanded(child: child),
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
            organizationName: organizationName,
            closeDrawerOnSelect: true,
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
                Expanded(child: child),
              ],
            );
          },
        ),
      ),
    );
  }
}
