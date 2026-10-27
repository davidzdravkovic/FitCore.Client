import 'package:fitcore_client/core/api/api_client.dart';
import 'package:fitcore_client/core/routing/member_paths.dart';
import 'package:fitcore_client/core/theme/fitcore_tokens.dart';
import 'package:fitcore_client/features/member/auth/member_session.dart';
import 'package:fitcore_client/features/tenant/dashboard/helpers/dashboard_layout.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MemberWorkspacePage extends StatelessWidget {
  const MemberWorkspacePage({super.key, required this.child});

  final Widget child;

  void _signOut(BuildContext context) {
    ApiClient.instance.setAccessToken(null);
    MemberSession.clear();
    context.go(MemberPaths.login);
  }

  int _indexFor(String path) {
    if (path.startsWith(MemberPaths.profile)) return 1;
    return 0;
  }

  void _goIndex(BuildContext context, int index) {
    context.go(index == 1 ? MemberPaths.profile : MemberPaths.home);
  }

  @override
  Widget build(BuildContext context) {
    final orgName = MemberSession.organizationName?.trim();
    final title =
        (orgName != null && orgName.isNotEmpty) ? orgName : 'Member';
    final path = GoRouterState.of(context).uri.path;
    final selected = _indexFor(path);
    final wide = MediaQuery.sizeOf(context).width >=
        DashboardLayout.sidebarCollapsedBreakpoint;
    final t = context.fc;

    return Scaffold(
      backgroundColor: t.canvas,
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (wide)
            TextButton(
              onPressed: () => _signOut(context),
              child: const Text('Sign out'),
            ),
        ],
      ),
      body: wide
          ? Row(
              children: [
                NavigationRail(
                  selectedIndex: selected,
                  onDestinationSelected: (index) => _goIndex(context, index),
                  labelType: NavigationRailLabelType.all,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.calendar_today_outlined),
                      selectedIcon: Icon(Icons.calendar_today),
                      label: Text('Schedule'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.person_outline),
                      selectedIcon: Icon(Icons.person),
                      label: Text('Profile'),
                    ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: child),
              ],
            )
          : child,
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: selected,
              onDestinationSelected: (index) => _goIndex(context, index),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.calendar_today_outlined),
                  selectedIcon: Icon(Icons.calendar_today),
                  label: 'Schedule',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
    );
  }
}
