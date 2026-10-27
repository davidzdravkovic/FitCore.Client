import 'package:fitcore_client/core/theme/fitcore_tokens.dart';
import 'package:fitcore_client/core/widgets/fit_record_table.dart';
import 'package:fitcore_client/core/widgets/fit_status_chip.dart';
import 'package:fitcore_client/features/tenant/plans/models/plan_response.dart';
import 'package:fitcore_client/features/tenant/services/models/service_response.dart';
import 'package:flutter/material.dart';

/// Service catalog: drill-in on phone, master–detail on wider layouts.
///
/// Phone: cards then full-page plans then detail sheet.
/// Wider: service list left, packages right (selection, no page replace).
class ServiceCatalog extends StatelessWidget {
  const ServiceCatalog({
    super.key,
    required this.services,
    required this.plansFor,
    required this.selectedId,
    required this.onSelect,
    required this.showDetail,
    required this.onShowDetail,
    required this.onHideDetail,
    required this.onAddPlan,
    required this.onDeactivateService,
    required this.onDeactivatePlan,
  });

  final List<ServiceResponse> services;
  final List<PlanResponse> Function(String serviceId) plansFor;
  final String? selectedId;
  final ValueChanged<String> onSelect;
  final bool showDetail;
  final VoidCallback onShowDetail;
  final VoidCallback onHideDetail;
  final ValueChanged<ServiceResponse> onAddPlan;
  final ValueChanged<ServiceResponse> onDeactivateService;
  final Future<void> Function(PlanResponse plan) onDeactivatePlan;

  ServiceResponse? get _selected {
    if (selectedId == null) return null;
    for (final service in services) {
      if (service.id == selectedId) return service;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= FitCoreBreakpoints.compact;
        final selected = _selected;

        if (wide) {
          return _MasterDetailCatalog(
            services: services,
            plansFor: plansFor,
            selected: selected,
            onSelect: onSelect,
            onAddPlan: onAddPlan,
            onDeactivateService: onDeactivateService,
            onDeactivatePlan: onDeactivatePlan,
          );
        }

        if (showDetail && selected != null) {
          return _PlanBrowseView(
            service: selected,
            plans: plansFor(selected.id),
            onBack: onHideDetail,
            onAddPlan: selected.isActive ? () => onAddPlan(selected) : null,
            onDeactivateService:
                selected.isActive ? () => onDeactivateService(selected) : null,
            onDeactivatePlan: onDeactivatePlan,
          );
        }

        return _ServiceCardGrid(
          services: services,
          plansFor: plansFor,
          onOpen: (service) {
            onSelect(service.id);
            onShowDetail();
          },
        );
      },
    );
  }
}

class _MasterDetailCatalog extends StatelessWidget {
  const _MasterDetailCatalog({
    required this.services,
    required this.plansFor,
    required this.selected,
    required this.onSelect,
    required this.onAddPlan,
    required this.onDeactivateService,
    required this.onDeactivatePlan,
  });

  final List<ServiceResponse> services;
  final List<PlanResponse> Function(String serviceId) plansFor;
  final ServiceResponse? selected;
  final ValueChanged<String> onSelect;
  final ValueChanged<ServiceResponse> onAddPlan;
  final ValueChanged<ServiceResponse> onDeactivateService;
  final Future<void> Function(PlanResponse plan) onDeactivatePlan;

  @override
  Widget build(BuildContext context) {
    final t = context.fc;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 300,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: t.borderSubtle)),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: services.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: FitCoreSpace.x2),
              itemBuilder: (context, index) {
                final service = services[index];
                return _ServiceListTile(
                  service: service,
                  planCount: plansFor(service.id).length,
                  selected: selected?.id == service.id,
                  onTap: () => onSelect(service.id),
                );
              },
            ),
          ),
        ),
        const SizedBox(width: FitCoreSpace.x5),
        Expanded(
          child: selected == null
              ? _SelectServiceHint()
              : _PlanBrowseView(
                  service: selected!,
                  plans: plansFor(selected!.id),
                  onBack: null,
                  onAddPlan:
                      selected!.isActive ? () => onAddPlan(selected!) : null,
                  onDeactivateService: selected!.isActive
                      ? () => onDeactivateService(selected!)
                      : null,
                  onDeactivatePlan: onDeactivatePlan,
                ),
        ),
      ],
    );
  }
}

class _SelectServiceHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.fc;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: FitCoreSpace.x10),
      child: Column(
        children: [
          Icon(Icons.touch_app_outlined, size: 28, color: t.textMuted),
          const SizedBox(height: FitCoreSpace.x3),
          Text('Select a service', style: theme.textTheme.titleSmall),
          const SizedBox(height: FitCoreSpace.x1),
          Text(
            'Packages for that service show here.',
            style: theme.textTheme.bodySmall?.copyWith(color: t.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ServiceListTile extends StatefulWidget {
  const _ServiceListTile({
    required this.service,
    required this.planCount,
    required this.selected,
    required this.onTap,
  });

  final ServiceResponse service;
  final int planCount;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_ServiceListTile> createState() => _ServiceListTileState();
}

class _ServiceListTileState extends State<_ServiceListTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.fc;
    final selected = widget.selected;
    final fill = selected
        ? t.elevated
        : (_hovered ? t.elevated.withValues(alpha: 0.6) : t.panel);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Material(
        color: fill,
        borderRadius: BorderRadius.circular(FitCoreRadius.md),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(FitCoreRadius.md),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(FitCoreRadius.md),
              border: Border.all(
                color: selected ? t.accent : t.borderSubtle,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: FitCoreSpace.x3,
                vertical: FitCoreSpace.x3,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.service.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: FitCoreSpace.x1),
                        Text(
                          widget.planCount == 1
                              ? '1 package'
                              : '${widget.planCount} packages',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: t.textSecondary,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: FitCoreSpace.x2),
                  FitStatusChip(
                    label: widget.service.isActive ? 'Active' : 'Inactive',
                    tone: widget.service.isActive
                        ? FitTone.positive
                        : FitTone.muted,
                    dense: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ServiceCardGrid extends StatelessWidget {
  const _ServiceCardGrid({
    required this.services,
    required this.plansFor,
    required this.onOpen,
  });

  final List<ServiceResponse> services;
  final List<PlanResponse> Function(String serviceId) plansFor;
  final ValueChanged<ServiceResponse> onOpen;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width >= FitCoreBreakpoints.medium
            ? 3
            : width >= FitCoreBreakpoints.compact
                ? 2
                : 1;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: services.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: FitCoreSpace.x3,
            crossAxisSpacing: FitCoreSpace.x3,
            mainAxisExtent: crossAxisCount == 1 ? 108 : 132,
          ),
          itemBuilder: (context, index) {
            final service = services[index];
            final count = plansFor(service.id).length;
            return _ServiceCard(
              service: service,
              planCount: count,
              onTap: () => onOpen(service),
            );
          },
        );
      },
    );
  }
}

class _ServiceCard extends StatefulWidget {
  const _ServiceCard({
    required this.service,
    required this.planCount,
    required this.onTap,
  });

  final ServiceResponse service;
  final int planCount;
  final VoidCallback onTap;

  @override
  State<_ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<_ServiceCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.fc;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Material(
        color: _hovered ? t.elevated : t.panel,
        borderRadius: BorderRadius.circular(FitCoreRadius.lg),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(FitCoreRadius.lg),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(FitCoreRadius.lg),
              border: Border.all(
                color: _hovered ? t.borderDefault : t.borderSubtle,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(FitCoreSpace.x4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.service.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: FitCoreSpace.x2),
                      FitStatusChip(
                        label: widget.service.isActive ? 'Active' : 'Inactive',
                        tone: widget.service.isActive
                            ? FitTone.positive
                            : FitTone.muted,
                        dense: true,
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Text(
                        widget.planCount == 1
                            ? '1 package'
                            : '${widget.planCount} packages',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: t.textSecondary,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: t.textMuted,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlanBrowseView extends StatelessWidget {
  const _PlanBrowseView({
    required this.service,
    required this.plans,
    required this.onDeactivatePlan,
    this.onBack,
    this.onAddPlan,
    this.onDeactivateService,
  });

  final ServiceResponse service;
  final List<PlanResponse> plans;
  final VoidCallback? onBack;
  final VoidCallback? onAddPlan;
  final VoidCallback? onDeactivateService;
  final Future<void> Function(PlanResponse plan) onDeactivatePlan;

  Future<void> _openPlanDetail(BuildContext context, PlanResponse plan) async {
    final phone =
        MediaQuery.sizeOf(context).width < FitCoreBreakpoints.compact;

    Widget detail(BuildContext host) {
      return _PlanDetailBody(
        serviceName: service.name,
        plan: plan,
        onDeactivate: plan.isActive
            ? () async {
                Navigator.of(host).pop();
                await onDeactivatePlan(plan);
              }
            : null,
        onClose: () => Navigator.of(host).pop(),
      );
    }

    if (phone) {
      await showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (sheetContext) {
          return SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                FitCoreSpace.x4,
                0,
                FitCoreSpace.x4,
                FitCoreSpace.x4 + MediaQuery.viewInsetsOf(sheetContext).bottom,
              ),
              child: detail(sheetContext),
            ),
          );
        },
      );
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          contentPadding: const EdgeInsets.fromLTRB(
            FitCoreSpace.x6,
            FitCoreSpace.x5,
            FitCoreSpace.x6,
            FitCoreSpace.x4,
          ),
          content: SizedBox(
            width: 420,
            child: detail(dialogContext),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.fc;

    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < FitCoreBreakpoints.compact;

        final titleBlock = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              service.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Packages you sell on this service',
              style: theme.textTheme.bodySmall?.copyWith(
                color: t.textSecondary,
              ),
            ),
          ],
        );

        final actions = <Widget>[
          FitStatusChip(
            label: service.isActive ? 'Active' : 'Inactive',
            tone: service.isActive ? FitTone.positive : FitTone.muted,
            dense: true,
          ),
          if (onAddPlan != null)
            FitRowAction(
              icon: Icons.add,
              tooltip: 'Add package',
              onPressed: onAddPlan,
            ),
          if (onDeactivateService != null)
            FitRowAction(
              icon: Icons.block_outlined,
              tooltip: 'Deactivate service',
              onPressed: onDeactivateService,
            ),
        ];

        final header = narrow
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      if (onBack != null) ...[
                        SizedBox(
                          width: 48,
                          height: 48,
                          child: IconButton(
                            onPressed: onBack,
                            tooltip: 'All services',
                            icon: const Icon(Icons.arrow_back, size: 20),
                          ),
                        ),
                        const SizedBox(width: FitCoreSpace.x1),
                      ],
                      Expanded(child: titleBlock),
                    ],
                  ),
                  const SizedBox(height: FitCoreSpace.x2),
                  Wrap(
                    spacing: FitCoreSpace.x2,
                    runSpacing: FitCoreSpace.x2,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: actions,
                  ),
                ],
              )
            : Row(
                children: [
                  if (onBack != null) ...[
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: IconButton(
                        onPressed: onBack,
                        tooltip: 'All services',
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.arrow_back, size: 18),
                      ),
                    ),
                    const SizedBox(width: FitCoreSpace.x2),
                  ],
                  Expanded(child: titleBlock),
                  ...actions,
                ],
              );

        final planWidth = constraints.maxWidth;
        final crossAxisCount = planWidth >= FitCoreBreakpoints.medium
            ? 3
            : planWidth >= 420
                ? 2
                : 1;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            header,
            const SizedBox(height: FitCoreSpace.x4),
            if (plans.isEmpty)
              _EmptyPlans(
                isActive: service.isActive,
                onAddPlan: onAddPlan,
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: plans.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: FitCoreSpace.x3,
                  crossAxisSpacing: FitCoreSpace.x3,
                  mainAxisExtent: crossAxisCount == 1 ? 128 : 148,
                ),
                itemBuilder: (context, index) {
                  final plan = plans[index];
                  return _PlanCard(
                    plan: plan,
                    onTap: () => _openPlanDetail(context, plan),
                  );
                },
              ),
          ],
        );
      },
    );
  }
}

class _PlanCard extends StatefulWidget {
  const _PlanCard({required this.plan, required this.onTap});

  final PlanResponse plan;
  final VoidCallback onTap;

  @override
  State<_PlanCard> createState() => _PlanCardState();
}

class _PlanCardState extends State<_PlanCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.fc;
    final plan = widget.plan;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Material(
        color: _hovered ? t.elevated : t.panel,
        borderRadius: BorderRadius.circular(FitCoreRadius.lg),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(FitCoreRadius.lg),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(FitCoreRadius.lg),
              border: Border.all(
                color: _hovered ? t.borderDefault : t.borderSubtle,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(FitCoreSpace.x4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          plan.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: FitCoreSpace.x2),
                      FitStatusChip(
                        label: plan.isActive ? 'Active' : 'Inactive',
                        tone: plan.isActive ? FitTone.positive : FitTone.muted,
                        dense: true,
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    plan.price.toStringAsFixed(2),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: FitCoreSpace.x1),
                  Text(
                    plan.entitlementSummary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: t.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlanDetailBody extends StatelessWidget {
  const _PlanDetailBody({
    required this.serviceName,
    required this.plan,
    required this.onClose,
    this.onDeactivate,
  });

  final String serviceName;
  final PlanResponse plan;
  final VoidCallback onClose;
  final VoidCallback? onDeactivate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.fc;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          plan.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: FitCoreSpace.x1),
        Text(
          serviceName,
          style: theme.textTheme.bodySmall?.copyWith(
            color: t.textSecondary,
          ),
        ),
        const SizedBox(height: FitCoreSpace.x4),
        Container(
          padding: const EdgeInsets.all(FitCoreSpace.x4),
          decoration: BoxDecoration(
            color: t.elevated,
            borderRadius: BorderRadius.circular(FitCoreRadius.md),
            border: Border.all(color: t.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DetailRow(
                label: 'Price',
                value: plan.price.toStringAsFixed(2),
              ),
              const SizedBox(height: FitCoreSpace.x3),
              _DetailRow(
                label: 'Sessions',
                value: '${plan.sessionCount ?? 0}',
              ),
              const SizedBox(height: FitCoreSpace.x3),
              _DetailRow(
                label: 'Type',
                value: plan.entitlementType.label,
              ),
              const SizedBox(height: FitCoreSpace.x3),
              Row(
                children: [
                  Text(
                    'Status',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: t.textMuted,
                    ),
                  ),
                  const Spacer(),
                  FitStatusChip(
                    label: plan.isActive ? 'Active' : 'Inactive',
                    tone: plan.isActive ? FitTone.positive : FitTone.muted,
                    dense: true,
                  ),
                ],
              ),
            ],
          ),
        ),
        if (onDeactivate != null) ...[
          const SizedBox(height: FitCoreSpace.x4),
          OutlinedButton.icon(
            onPressed: onDeactivate,
            icon: const Icon(Icons.block_outlined, size: 16),
            label: const Text('Deactivate package'),
          ),
        ],
        const SizedBox(height: FitCoreSpace.x2),
        TextButton(
          onPressed: onClose,
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.fc;

    return Row(
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(color: t.textMuted),
        ),
        const Spacer(),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

class _EmptyPlans extends StatelessWidget {
  const _EmptyPlans({required this.isActive, this.onAddPlan});

  final bool isActive;
  final VoidCallback? onAddPlan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.fc;
    final canAdd = isActive && onAddPlan != null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: FitCoreSpace.x8),
      child: Column(
        children: [
          Text(
            canAdd ? 'No packages on this service' : 'No packages',
            style: theme.textTheme.titleSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: FitCoreSpace.x2),
          Text(
            canAdd
                ? 'Add a session package to sell.'
                : 'This service has no packages.',
            style: theme.textTheme.bodySmall?.copyWith(color: t.textSecondary),
            textAlign: TextAlign.center,
          ),
          if (canAdd) ...[
            const SizedBox(height: FitCoreSpace.x4),
            FilledButton.icon(
              onPressed: onAddPlan,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add package'),
            ),
          ],
        ],
      ),
    );
  }
}
