import 'package:fitcore_client/features/tenant_dashboard/models/dashboard_nav_item.dart';
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
    final colorScheme = theme.colorScheme;

    return Material(
      color: colorScheme.surface,
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.55),
            ),
          ),
        ),
        child: Row(
          children: [
            if (onOpenMenu != null) ...[
              IconButton(
                onPressed: onOpenMenu,
                icon: const Icon(Icons.menu),
                tooltip: 'Menu',
              ),
              const SizedBox(width: 4),
            ],
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: colorScheme.primary.withValues(alpha: 0.2),
                    child: Text(
                      ownerName.isNotEmpty ? ownerName[0].toUpperCase() : 'U',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    ownerName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: onSignOut,
              child: const Text('Sign out'),
            ),
          ],
        ),
      ),
    );
  }
}

String dashboardSectionTitle(DashboardSection section) {
  return dashboardNavItems
      .firstWhere((item) => item.section == section)
      .label;
}
