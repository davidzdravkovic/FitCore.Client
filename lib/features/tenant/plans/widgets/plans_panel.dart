import 'package:fitcore_client/features/tenant/dashboard/helpers/dashboard_layout.dart';
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
    final activeServices =
        _controller.services.where((s) => s.isActive).toList();

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
        final theme = Theme.of(context);

        return Padding(
          padding: const EdgeInsets.all(DashboardLayout.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: FilledButton.icon(
                  onPressed: _openCreateForm,
                  icon: const Icon(Icons.add),
                  label: const Text('Add plan'),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(child: _buildBody(theme)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_controller.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_controller.error!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _controller.load,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_controller.plans.isEmpty) {
      return Center(
        child: Text(
          'No plans yet. Create a service, then add a plan to sell.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return SingleChildScrollView(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Service')),
            DataColumn(label: Text('Price')),
            DataColumn(label: Text('Entitlement')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('')),
          ],
          rows: [
            for (final plan in _controller.plans)
              DataRow(
                cells: [
                  DataCell(Text(plan.name)),
                  DataCell(Text(_controller.serviceName(plan.serviceId))),
                  DataCell(Text(plan.price.toStringAsFixed(2))),
                  DataCell(Text(
                    '${plan.entitlementType.label} · ${plan.entitlementSummary}',
                  )),
                  DataCell(Text(plan.isActive ? 'Active' : 'Inactive')),
                  DataCell(
                    plan.isActive
                        ? IconButton(
                            tooltip: 'Deactivate',
                            onPressed: () => _deactivate(plan),
                            icon: const Icon(Icons.block_outlined),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
