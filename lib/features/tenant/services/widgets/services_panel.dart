import 'package:fitcore_client/features/tenant/dashboard/helpers/dashboard_layout.dart';
import 'package:fitcore_client/features/tenant/services/models/services_models.dart';
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
      SnackBar(
        content: Text(error ?? '${service.name} deactivated'),
      ),
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
                  label: const Text('Add service'),
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

    if (_controller.services.isEmpty) {
      return Center(
        child: Text(
          'No services yet. Add a service (e.g. Gym access, PT) to sell plans.',
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
            DataColumn(label: Text('Description')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('')),
          ],
          rows: [
            for (final service in _controller.services)
              DataRow(
                cells: [
                  DataCell(Text(service.name)),
                  DataCell(Text(
                    service.description?.isNotEmpty == true
                        ? service.description!
                        : '—',
                  )),
                  DataCell(Text(service.isActive ? 'Active' : 'Inactive')),
                  DataCell(
                    service.isActive
                        ? IconButton(
                            tooltip: 'Deactivate',
                            onPressed: () => _deactivate(service),
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
