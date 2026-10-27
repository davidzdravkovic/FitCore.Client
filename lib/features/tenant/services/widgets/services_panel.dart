import 'package:fitcore_client/core/theme/fitcore_tokens.dart';
import 'package:fitcore_client/core/widgets/fit_data_panel.dart';
import 'package:fitcore_client/core/widgets/fit_page_header.dart';
import 'package:fitcore_client/core/widgets/fit_panel_states.dart';
import 'package:fitcore_client/features/tenant/plans/models/plan_response.dart';
import 'package:fitcore_client/features/tenant/plans/widgets/plan_form.dart';
import 'package:fitcore_client/features/tenant/services/models/service_response.dart';
import 'package:fitcore_client/features/tenant/services/services_controller.dart';
import 'package:fitcore_client/features/tenant/services/widgets/service_catalog_section.dart';
import 'package:fitcore_client/features/tenant/services/widgets/service_form.dart';
import 'package:flutter/material.dart';

class ServicesPanel extends StatefulWidget {
  const ServicesPanel({super.key, this.controller});

  final ServicesController? controller;

  @override
  State<ServicesPanel> createState() => _ServicesPanelState();
}

class _ServicesPanelState extends State<ServicesPanel> {
  late final ServicesController _controller =
      widget.controller ?? ServicesController();
  late final bool _ownsController = widget.controller == null;
  String? _selectedId;
  bool _showDetail = false;

  bool get _phone =>
      MediaQuery.sizeOf(context).width < FitCoreBreakpoints.compact;

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

  void _ensureSelection(List<ServiceResponse> services) {
    if (services.isEmpty) return;
    if (_selectedId != null &&
        services.any((s) => s.id == _selectedId)) {
      return;
    }
    final next = services.first.id;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_selectedId != null &&
          services.any((s) => s.id == _selectedId)) {
        return;
      }
      setState(() => _selectedId = next);
    });
  }

  Future<bool?> _presentForm({
    required String title,
    required Widget Function(BuildContext host) formBuilder,
  }) {
    if (_phone) {
      return showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (sheetContext) {
          return Padding(
            padding: EdgeInsets.fromLTRB(
              FitCoreSpace.x4,
              0,
              FitCoreSpace.x4,
              FitCoreSpace.x4 + MediaQuery.viewInsetsOf(sheetContext).bottom,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: Theme.of(sheetContext).textTheme.titleMedium,
                  ),
                  const SizedBox(height: FitCoreSpace.x4),
                  formBuilder(sheetContext),
                  const SizedBox(height: FitCoreSpace.x3),
                  TextButton(
                    onPressed: () => Navigator.of(sheetContext).pop(false),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: SizedBox(
            width: fitDialogWidth(dialogContext),
            child: SingleChildScrollView(
              child: formBuilder(dialogContext),
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
  }

  Future<void> _openCreateServiceForm() async {
    final created = await _presentForm(
      title: 'Add service',
      formBuilder: (host) => ServiceForm(
        servicesApi: _controller.servicesApi,
        onCreated: (service) {
          Navigator.of(host).pop(true);
          setState(() {
            _selectedId = service.id;
            _showDetail = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${service.name} created')),
          );
        },
      ),
    );

    if (created == true) {
      await _controller.load();
    }
  }

  Future<void> _openCreatePlanForm(ServiceResponse service) async {
    if (!service.isActive) return;

    final created = await _presentForm(
      title: 'Add plan · ${service.name}',
      formBuilder: (host) => PlanForm(
        activeServices: [service],
        lockedServiceId: service.id,
        plansApi: _controller.plansApi,
        onCreated: (plan) {
          Navigator.of(host).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${plan.name} created')),
          );
        },
      ),
    );

    if (created == true) {
      setState(() {
        _selectedId = service.id;
        _showDetail = true;
      });
      await _controller.load();
    }
  }

  void _selectService(String id) {
    setState(() => _selectedId = id);
  }

  Future<void> _deactivateService(ServiceResponse service) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Deactivate service'),
          content: Text(
            'Deactivate ${service.name}? It will no longer be available for new plans.',
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

    final error = await _controller.deactivate(service);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error ?? '${service.name} deactivated')),
    );
  }

  Future<void> _deactivatePlan(PlanResponse plan) async {
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

    final error = await _controller.deactivatePlan(plan);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error ?? '${plan.name} deactivated')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final phone = _phone;

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final services = _controller.services;
        if (!_controller.isLoading && _controller.error == null) {
          _ensureSelection(services);
        }

        return FitPageBody(
          header: FitPageHeader(
            dense: phone,
            title: 'Services',
            description: phone
                ? null
                : 'Pick a service to see the packages you sell on it.',
            meta: services.isNotEmpty
                ? FitCountBadge(count: services.length, noun: 'total')
                : null,
            actions: [
              FilledButton.icon(
                onPressed: _openCreateServiceForm,
                icon: const Icon(Icons.add, size: 16),
                label: Text(phone ? 'Add' : 'Add service'),
              ),
            ],
          ),
          child: _buildBody(),
        );
      },
    );
  }

  Widget _buildBody() {
    if (_controller.isLoading) {
      return const FitTableSkeleton(columnFlex: [3, 4, 2]);
    }

    if (_controller.error != null) {
      return FitErrorState(
        message: _controller.error!,
        onRetry: _controller.load,
      );
    }

    if (_controller.services.isEmpty) {
      return FitEmptyState(
        icon: Icons.fitness_center_outlined,
        title: 'No services yet',
        message:
            'Add a service (e.g. Gym access, PT), then add packages under it.',
        action: FilledButton.icon(
          onPressed: _openCreateServiceForm,
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Add service'),
        ),
      );
    }

    final services = _controller.services;

    return ServiceCatalog(
      services: services,
      plansFor: _controller.plansFor,
      selectedId: _selectedId,
      onSelect: _selectService,
      showDetail: _showDetail,
      onShowDetail: () => setState(() => _showDetail = true),
      onHideDetail: () => setState(() => _showDetail = false),
      onAddPlan: _openCreatePlanForm,
      onDeactivateService: _deactivateService,
      onDeactivatePlan: _deactivatePlan,
    );
  }
}
