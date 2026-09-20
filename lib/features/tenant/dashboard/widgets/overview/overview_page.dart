import 'package:fitcore_client/core/routing/tenant_paths.dart';
import 'package:fitcore_client/core/theme/fitcore_tokens.dart';
import 'package:fitcore_client/core/time/tenant_clock.dart';
import 'package:fitcore_client/core/widgets/fit_page_header.dart';
import 'package:fitcore_client/core/widgets/fit_panel_states.dart';
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
    final welcomeName = widget.ownerFirstName.isNotEmpty
        ? widget.ownerFirstName
        : 'there';
    final gymLabel = widget.organizationName.isNotEmpty
        ? widget.organizationName
        : 'your gym';
    final phone =
        MediaQuery.sizeOf(context).width < FitCoreBreakpoints.compact;
    final pad = phone ? FitCoreSpace.x3 : FitCoreSpace.x6;

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final snap = _controller.snapshot;
        final loading = _controller.isLoading && snap == null;

        return LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: Padding(
                  padding: EdgeInsets.all(pad),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FitPageHeader(
                        dense: phone,
                        title: 'Welcome, $welcomeName',
                        description: phone
                            ? null
                            : '$gymLabel · ${formatDayHeadline(TenantClock.now())}',
                        actions: [
                          FilledButton.icon(
                            onPressed: () => context.go(TenantPaths.schedule),
                            icon: const Icon(
                              Icons.calendar_month_outlined,
                              size: 16,
                            ),
                            label: Text(phone ? 'Schedule' : 'Open schedule'),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: phone ? FitCoreSpace.x3 : FitCoreSpace.x6,
                      ),
                      if (_controller.error != null)
                        FitErrorBanner(
                          message: _controller.error!,
                          onRetry: _controller.load,
                        )
                      else
                        _StatsRow(
                          activeMembers: snap?.activeMembers ?? 0,
                          activeMemberships: snap?.activeMemberships ?? 0,
                          visitsToday: snap?.visitsToday ?? 0,
                          isLoading: loading,
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.activeMembers,
    required this.activeMemberships,
    required this.visitsToday,
    required this.isLoading,
  });

  final int activeMembers;
  final int activeMemberships;
  final int visitsToday;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final t = context.fc;

    OverviewStatCard card({
      required String label,
      required String value,
      required IconData icon,
      required Color accent,
      required String hint,
      bool compact = false,
    }) {
      return OverviewStatCard(
        label: label,
        value: value,
        icon: icon,
        accent: accent,
        hint: hint,
        isLoading: isLoading,
        compact: compact,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final phone = constraints.maxWidth < FitCoreBreakpoints.compact;
        final gap = phone ? FitCoreSpace.x2 : FitCoreSpace.x3;

        final members = card(
          label: 'Active members',
          value: '$activeMembers',
          icon: Icons.people_outline,
          accent: t.statePositive,
          hint: 'Status = Active',
          compact: phone,
        );
        final memberships = card(
          label: 'Active memberships',
          value: '$activeMemberships',
          icon: Icons.card_membership_outlined,
          accent: t.accent,
          hint: 'Packs currently active',
          compact: phone,
        );
        final visits = card(
          label: 'Visits today',
          value: '$visitsToday',
          icon: Icons.event_available_outlined,
          accent: t.visitScheduled,
          hint: 'Tenant timezone day',
          compact: phone,
        );

        // Phone: 2-up grid (matches CRM density), not a tall stack of 3.
        if (phone) {
          return Column(
            children: [
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: members),
                    SizedBox(width: gap),
                    Expanded(child: memberships),
                  ],
                ),
              ),
              SizedBox(height: gap),
              visits,
            ],
          );
        }

        if (constraints.maxWidth >= 860) {
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: members),
                SizedBox(width: gap),
                Expanded(child: memberships),
                SizedBox(width: gap),
                Expanded(child: visits),
              ],
            ),
          );
        }

        return Column(
          children: [
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: members),
                  SizedBox(width: gap),
                  Expanded(child: memberships),
                ],
              ),
            ),
            SizedBox(height: gap),
            visits,
          ],
        );
      },
    );
  }
}
