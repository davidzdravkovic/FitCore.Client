import 'package:fitcore_client/features/tenant/dashboard/helpers/dashboard_layout.dart';
import 'package:fitcore_client/features/tenant/staff/api/staff_models.dart';
import 'package:fitcore_client/features/tenant/staff/staff_controller.dart';
import 'package:fitcore_client/features/tenant/staff/widgets/staff_form.dart';
import 'package:flutter/material.dart';

class StaffPanel extends StatefulWidget {
  const StaffPanel({super.key, this.controller});

  final StaffController? controller;

  @override
  State<StaffPanel> createState() => _StaffPanelState();
}

class _StaffPanelState extends State<StaffPanel> {
  late final StaffController _controller =
      widget.controller ?? StaffController();
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

  Future<void> _openCreateStaffForm() async {
    final created = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add staff'),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: StaffForm(
                staffApi: _controller.staffApi,
                onCreated: (staff) {
                  Navigator.of(dialogContext).pop(true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${staff.firstName} ${staff.lastName} created',
                      ),
                    ),
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

  Future<void> _inviteStaff(Staff person) async {
    final error = await _controller.invite(person);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          error ?? 'Sign-in invite sent to ${person.email}',
        ),
      ),
    );
  }

  Future<void> _deleteStaff(Staff person) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete staff'),
          content: Text(
            'Remove ${person.firstName} ${person.lastName}? '
            'They will no longer appear in the list.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    final error = await _controller.delete(person);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          error ?? '${person.firstName} ${person.lastName} deleted',
        ),
      ),
    );
  }

  void _showImportComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Import is for bringing staff (and history) from another system. Coming soon.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const menuWidth = 220.0;

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
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _controller.isLoading ? null : _controller.load,
                      icon: const Icon(Icons.badge_outlined),
                      label: const Text('All staff'),
                    ),
                    const SizedBox(width: 12),
                    MenuAnchor(
                      crossAxisUnconstrained: false,
                      consumeOutsideTap: true,
                      alignmentOffset: const Offset(0, 4),
                      style: const MenuStyle(
                        alignment: AlignmentDirectional.bottomEnd,
                        padding: WidgetStatePropertyAll(
                          EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                      builder: (context, controller, child) {
                        return FilledButton.icon(
                          onPressed: () {
                            if (controller.isOpen) {
                              controller.close();
                            } else {
                              controller.open();
                            }
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('New'),
                        );
                      },
                      menuChildren: [
                        SizedBox(
                          width: menuWidth,
                          child: MenuItemButton(
                            leadingIcon: const Icon(Icons.person_add_outlined),
                            onPressed: _openCreateStaffForm,
                            child: const Text('Add staff'),
                          ),
                        ),
                        SizedBox(
                          width: menuWidth,
                          child: MenuItemButton(
                            leadingIcon: const Icon(Icons.upload_file_outlined),
                            onPressed: _showImportComingSoon,
                            child: const Text('Import staff'),
                          ),
                        ),
                      ],
                    ),
                  ],
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

    if (_controller.staff.isEmpty) {
      return Center(
        child: Text(
          'No staff yet. Add your first staff member to get started.',
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
            DataColumn(label: Text('Email')),
            DataColumn(label: Text('')),
          ],
          rows: [
            for (final person in _controller.staff)
              DataRow(
                cells: [
                  DataCell(Text('${person.firstName} ${person.lastName}')),
                  DataCell(Text(person.email)),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Invite to sign in',
                          onPressed: () => _inviteStaff(person),
                          icon: const Icon(Icons.outgoing_mail),
                        ),
                        IconButton(
                          tooltip: 'Delete',
                          onPressed: () => _deleteStaff(person),
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
