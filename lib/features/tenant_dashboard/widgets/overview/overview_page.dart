import 'package:fitcore_client/features/tenant_dashboard/helpers/dashboard_layout.dart';
import 'package:fitcore_client/features/tenant_dashboard/widgets/overview/overview_stat_card.dart';
import 'package:flutter/material.dart';

class OverviewPage extends StatelessWidget {
  const OverviewPage({
    super.key,
    required this.ownerFirstName,
    required this.organizationName,
  });

  final String ownerFirstName;
  final String organizationName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final welcomeName =
        ownerFirstName.isNotEmpty ? ownerFirstName : 'there';
    final gymLabel =
        organizationName.isNotEmpty ? organizationName : 'your gym';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(DashboardLayout.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Welcome, $welcomeName',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$gymLabel is ready. Use the sidebar to explore your workspace.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: DashboardLayout.sectionGap + 8),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 720;
              final cards = const [
                OverviewStatCard(
                  label: 'Active members',
                  value: '—',
                  icon: Icons.people_outline,
                ),
                OverviewStatCard(
                  label: 'Check-ins today',
                  value: '—',
                  icon: Icons.login_outlined,
                ),
                OverviewStatCard(
                  label: 'Classes this week',
                  value: '—',
                  icon: Icons.fitness_center_outlined,
                ),
                OverviewStatCard(
                  label: 'Open invoices',
                  value: '—',
                  icon: Icons.receipt_long_outlined,
                ),
              ];

              if (wide) {
                return Row(
                  children: [
                    for (var i = 0; i < cards.length; i++) ...[
                      if (i > 0) const SizedBox(width: 12),
                      Expanded(child: cards[i]),
                    ],
                  ],
                );
              }

              return GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.35,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: cards,
              );
            },
          ),
          const SizedBox(height: DashboardLayout.sectionGap + 8),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.55),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Getting started',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Members, schedules, and billing are placeholders for now. Pick a section from the left to open its future workspace.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
