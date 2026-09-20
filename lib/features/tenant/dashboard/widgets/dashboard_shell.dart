import 'dart:math' as math;

import 'package:fitcore_client/core/theme/fitcore_tokens.dart';
import 'package:fitcore_client/features/tenant/dashboard/helpers/dashboard_layout.dart';
import 'package:fitcore_client/features/tenant/dashboard/navigation/dashboard_nav_item.dart';
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
    final t = context.fc;
    final wide =
        MediaQuery.sizeOf(context).width >=
        DashboardLayout.sidebarCollapsedBreakpoint;

    if (wide) {
      return Scaffold(
        backgroundColor: t.canvas,
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
              Container(width: 1, color: t.borderSubtle),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
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
      backgroundColor: t.canvas,
      drawer: Drawer(
        width: math.min(
          DashboardLayout.sidebarWidth,
          MediaQuery.sizeOf(context).width * 0.86,
        ),
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
