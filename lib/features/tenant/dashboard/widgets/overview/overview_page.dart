import 'package:fitcore_client/core/routing/tenant_paths.dart';
import 'package:fitcore_client/core/time/tenant_clock.dart';
import 'package:fitcore_client/features/tenant/dashboard/helpers/dashboard_layout.dart';
import 'package:fitcore_client/features/tenant/dashboard/overview/overview_controller.dart';
import 'package:fitcore_client/features/tenant/dashboard/widgets/overview/overview_stat_card.dart';
import 'package:fitcore_client/features/tenant/visits/widgets/visit_display.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OverviewPage extends StatefulWidget {
  const OverviewPage({
    super.key,
    required this.ownerFirstName,
    required this.organizationName,
  });

  final String ownerFirstName;
  final String organizationName;

  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  final OverviewController _controller = OverviewController();

  @override
  void initState() {
    super.initState();
    _controller.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final welcomeName =
        widget.ownerFirstName.isNotEmpty ? widget.ownerFirstName : 'there';
    final gymLabel = widget.organizationName.isNotEmpty
        ? widget.organizationName
        : 'your gym';

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final snap = _controller.snapshot;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(DashboardLayout.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _HeroBanner(
                welcomeName: welcomeName,
                gymLabel: gymLabel,
                dayLabel: formatDayHeadline(TenantClock.now()),
                onOpenSchedule: () => context.go(TenantPaths.schedule),
              ),
              const SizedBox(height: DashboardLayout.sectionGap + 4),
              if (_controller.error != null)
                _ErrorBanner(
                  message: _controller.error!,
                  onRetry: _controller.load,
                )
              else if (_controller.isLoading && snap == null)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                _StatsRow(
                  activeMembers: snap?.activeMembers ?? 0,
                  activeMemberships: snap?.activeMemberships ?? 0,
                  visitsToday: snap?.visitsToday ?? 0,
                ),
            ],
          ),
        );
      },
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({
    required this.welcomeName,
    required this.gymLabel,
    required this.dayLabel,
    required this.onOpenSchedule,
  });

  final String welcomeName;
  final String gymLabel;
  final String dayLabel;
  final VoidCallback onOpenSchedule;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withValues(alpha: 0.22),
            colorScheme.tertiary.withValues(alpha: 0.12),
            colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          ],
        ),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stacked = constraints.maxWidth < 640;
          final text = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dayLabel,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Welcome, $welcomeName',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$gymLabel · today\'s pulse across members, packs, and the board.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ],
          );

          final cta = FilledButton.icon(
            onPressed: onOpenSchedule,
            icon: const Icon(Icons.calendar_month_outlined),
            label: const Text('Open schedule'),
          );

          if (stacked) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                text,
                const SizedBox(height: 20),
                Align(alignment: Alignment.centerLeft, child: cta),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: text),
              const SizedBox(width: 16),
              cta,
            ],
          );
        },
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.activeMembers,
    required this.activeMemberships,
    required this.visitsToday,
  });

  final int activeMembers;
  final int activeMemberships;
  final int visitsToday;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final cards = [
      OverviewStatCard(
        label: 'Active members',
        value: '$activeMembers',
        icon: Icons.people_outline,
        accent: colorScheme.primary,
        hint: 'Status = Active',
      ),
      OverviewStatCard(
        label: 'Active memberships',
        value: '$activeMemberships',
        icon: Icons.card_membership_outlined,
        accent: colorScheme.tertiary,
        hint: 'Packs currently active',
      ),
      OverviewStatCard(
        label: 'Visits today',
        value: '$visitsToday',
        icon: Icons.event_available_outlined,
        accent: const Color(0xFF4C8DFF),
        hint: 'Tenant timezone day',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 900) {
          return Row(
            children: [
              for (var i = 0; i < cards.length; i++) ...[
                if (i > 0) const SizedBox(width: 14),
                Expanded(child: cards[i]),
              ],
            ],
          );
        }

        if (constraints.maxWidth >= 560) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(child: cards[0]),
                  const SizedBox(width: 14),
                  Expanded(child: cards[1]),
                ],
              ),
              const SizedBox(height: 14),
              cards[2],
            ],
          );
        }

        return Column(
          children: [
            for (var i = 0; i < cards.length; i++) ...[
              if (i > 0) const SizedBox(height: 12),
              cards[i],
            ],
          ],
        );
      },
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(child: Text(message)),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
