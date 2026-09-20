import 'package:fitcore_client/core/widgets/fit_data_panel.dart';
import 'package:fitcore_client/core/widgets/fit_page_header.dart';
import 'package:fitcore_client/core/widgets/fit_panel_states.dart';
import 'package:fitcore_client/core/widgets/fit_record_table.dart';
import 'package:fitcore_client/core/widgets/fit_status_chip.dart';
import 'package:fitcore_client/features/tenant/services/models/service_response.dart';
import 'package:fitcore_client/features/tenant/services/services_controller.dart';
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
    final created = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add service'),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: ServiceForm(
                servicesApi: _controller.servicesApi,
                onCreated: (service) {
                  Navigator.of(dialogContext).pop(true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${service.name} created')),
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

  Future<void> _deactivate(ServiceResponse service) async {
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

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final services = _controller.services;

        return FitPageBody(
          header: FitPageHeader(
            title: 'Services',
            description: 'What your gym offers. Plans are built on services.',
            meta: services.isNotEmpty
                ? FitCountBadge(count: services.length, noun: 'total')
                : null,
            actions: [
              FilledButton.icon(
                onPressed: _openCreateForm,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add service'),
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
        message: 'Add a service (e.g. Gym access, PT) to sell plans.',
        action: FilledButton.icon(
          onPressed: _openCreateForm,
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Add service'),
        ),
      );
    }

    return FitRecordTable(
      columns: const [
        FitColumn(label: 'Name', flex: 3, minWidth: 180),
        FitColumn(label: 'Description', flex: 4, minWidth: 220, hideBelow: 900),
        FitColumn(label: 'Status', flex: 2, minWidth: 130),
      ],
      rows: [
        for (final service in _controller.services)
          FitRecordRow(
            cells: [
              FitTextCell(service.name, strong: true),
              if (service.description?.isNotEmpty == true)
                FitTextCell(service.description!, muted: true)
              else
                const FitTextCell.empty(),
              FitStatusChip(
                label: service.isActive ? 'Active' : 'Inactive',
                tone: service.isActive ? FitTone.positive : FitTone.muted,
              ),
            ],
            actions: [
              if (service.isActive)
                FitRowAction(
                  icon: Icons.block_outlined,
                  tooltip: 'Deactivate',
                  onPressed: () => _deactivate(service),
                ),
            ],
          ),
      ],
    );
  }
}
