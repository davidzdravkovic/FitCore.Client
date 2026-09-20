import 'package:fitcore_client/core/widgets/fit_data_panel.dart';
import 'package:fitcore_client/core/widgets/fit_page_header.dart';
import 'package:fitcore_client/core/widgets/fit_panel_states.dart';
import 'package:fitcore_client/core/widgets/fit_record_table.dart';
import 'package:fitcore_client/core/widgets/fit_status_chip.dart';
import 'package:fitcore_client/features/tenant/plans/models/plan_response.dart';
import 'package:fitcore_client/features/tenant/plans/plans_controller.dart';
import 'package:fitcore_client/features/tenant/plans/widgets/plan_form.dart';
import 'package:flutter/material.dart';

class PlansPanel extends StatefulWidget {
  const PlansPanel({super.key, this.controller});

  final PlansController? controller;

  @override
  State<PlansPanel> createState() => _PlansPanelState();
}

class _PlansPanelState extends State<PlansPanel> {
  late final PlansController _controller =
      widget.controller ?? PlansController();
  late final bool _ownsController = widget.controller == null;

  @override
  void initState() {
    super.initState();
    _controller.load();
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  Future<void> _openCreateForm() async {
    final activeServices = _controller.services
        .where((s) => s.isActive)
        .toList();

    final created = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add plan'),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: PlanForm(
                activeServices: activeServices,
                plansApi: _controller.plansApi,
                onCreated: (plan) {
                  Navigator.of(dialogContext).pop(true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${plan.name} created')),
                  );
                },
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );

    if (created == true) {
      await _controller.load();
    }
  }

  Future<void> _deactivate(PlanResponse plan) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Deactivate plan'),
          content: Text(
            'Deactivate ${plan.name}? It will no longer be available for new memberships.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Deactivate'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    final error = await _controller.deactivate(plan);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error ?? '${plan.name} deactivated')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final plans = _controller.plans;

        return FitPageBody(
          header: FitPageHeader(
            title: 'Plans',
            description: 'Sellable packages built on top of your services.',
            meta: plans.isNotEmpty
                ? FitCountBadge(count: plans.length, noun: 'total')
                : null,
            actions: [
              FilledButton.icon(
                onPressed: _openCreateForm,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add plan'),
              ),
            ],
          ),
          child: FitDataPanel(child: _buildBody()),
        );
      },
    );
  }

  Widget _buildBody() {
    if (_controller.isLoading) {
      return const FitTableSkeleton(columnFlex: [3, 2, 1, 3, 2]);
    }

    if (_controller.error != null) {
      return FitErrorState(
        message: _controller.error!,
        onRetry: _controller.load,
      );
    }

    if (_controller.plans.isEmpty) {
      return FitEmptyState(
        icon: Icons.sell_outlined,
        title: 'No plans yet',
        message: 'Create a service, then add a plan to sell.',
        action: FilledButton.icon(
          onPressed: _openCreateForm,
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Add plan'),
        ),
      );
    }

    return FitRecordTable(
      columns: const [
        FitColumn(label: 'Name', flex: 3, minWidth: 170),
        FitColumn(label: 'Service', flex: 2, minWidth: 140),
        FitColumn(label: 'Price', flex: 1, minWidth: 90),
        FitColumn(
          label: 'Entitlement',
          flex: 3,
          minWidth: 200,
          hideBelow: 1100,
        ),
        FitColumn(label: 'Status', flex: 2, minWidth: 130),
      ],
      rows: [
        for (final plan in _controller.plans)
          FitRecordRow(
            cells: [
              FitTextCell(plan.name, strong: true),
              FitTextCell(_controller.serviceName(plan.serviceId), muted: true),
              FitTextCell(plan.price.toStringAsFixed(2), mono: true),
              FitTextCell(
                '${plan.entitlementType.label} · ${plan.entitlementSummary}',
                muted: true,
              ),
              FitStatusChip(
                label: plan.isActive ? 'Active' : 'Inactive',
                tone: plan.isActive ? FitTone.positive : FitTone.muted,
              ),
            ],
            actions: [
              if (plan.isActive)
                FitRowAction(
                  icon: Icons.block_outlined,
                  tooltip: 'Deactivate',
                  onPressed: () => _deactivate(plan),
                ),
            ],
          ),
      ],
    );
  }
}
