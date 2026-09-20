import 'package:fitcore_client/core/theme/fitcore_tokens.dart';
import 'package:fitcore_client/core/widgets/fit_record_table.dart'
    show FitAvatar;
import 'package:fitcore_client/features/tenant/dashboard/navigation/dashboard_nav_item.dart';
import 'package:flutter/material.dart';

class DashboardTopBar extends StatelessWidget {
  const DashboardTopBar({
    super.key,
    required this.title,
    required this.ownerName,
    required this.onSignOut,
    this.onOpenMenu,
  });

  final String title;
  final String ownerName;
  final VoidCallback onSignOut;
  final VoidCallback? onOpenMenu;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.fc;
    final compact =
        MediaQuery.sizeOf(context).width < FitCoreBreakpoints.compact;

    return Container(
      height: 52,
      padding: EdgeInsets.only(
        left: onOpenMenu != null ? FitCoreSpace.x2 : FitCoreSpace.x5,
        right: FitCoreSpace.x3,
      ),
      decoration: BoxDecoration(
        color: t.canvas,
        border: Border(bottom: BorderSide(color: t.borderSubtle)),
      ),
      child: Row(
        children: [
          if (onOpenMenu != null) ...[
            IconButton(
              onPressed: onOpenMenu,
              icon: const Icon(Icons.menu, size: 20),
              tooltip: 'Menu',
            ),
            const SizedBox(width: FitCoreSpace.x1),
          ],
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall?.copyWith(letterSpacing: -0.1),
            ),
          ),
          FitAvatar(name: ownerName, size: 26),
          if (!compact) ...[
            const SizedBox(width: FitCoreSpace.x2),
            Text(
              ownerName,
              style: theme.textTheme.labelMedium?.copyWith(
                color: t.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: FitCoreSpace.x3),
            Container(width: 1, height: 20, color: t.borderSubtle),
            const SizedBox(width: FitCoreSpace.x2),
            TextButton(
              onPressed: onSignOut,
              style: TextButton.styleFrom(foregroundColor: t.textSecondary),
              child: const Text('Sign out'),
            ),
          ] else ...[
            const SizedBox(width: FitCoreSpace.x1),
            IconButton(
              onPressed: onSignOut,
              icon: const Icon(Icons.logout, size: 18),
              tooltip: 'Sign out',
            ),
          ],
        ],
      ),
    );
  }
}

String dashboardSectionTitle(DashboardSection section) {
  return dashboardNavItems.firstWhere((item) => item.section == section).label;
}
