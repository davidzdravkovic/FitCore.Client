import 'package:fitcore_client/core/api/api_exception.dart';
import 'package:fitcore_client/features/tenant/dashboard/helpers/dashboard_layout.dart';
import 'package:fitcore_client/features/tenant/staff/api/staff_api.dart';
import 'package:fitcore_client/features/tenant/staff/api/staff_models.dart';
import 'package:fitcore_client/features/tenant/staff/widgets/staff_form.dart';
import 'package:flutter/material.dart';

class StaffPanel extends StatefulWidget {
  const StaffPanel({super.key, this.staffApi});

  final StaffApi? staffApi;

  @override
  State<StaffPanel> createState() => _StaffPanelState();
}

class _StaffPanelState extends State<StaffPanel> {
  late final StaffApi _staffApi = widget.staffApi ?? StaffApi();

  List<Staff> _staff = const [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStaff();
  }

  Future<void> _loadStaff() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final staff = await _staffApi.list();
      if (!mounted) return;
      setState(() {
        _staff = staff;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _isLoading = false;
      });
    }
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
                staffApi: _staffApi,
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
      await _loadStaff();
    }
  }

  Future<void> _inviteStaff(Staff person) async {
    try {
      await _staffApi.invite(person.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign-in invite sent to ${person.email}')),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    }
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

    try {
      await _staffApi.delete(person.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${person.firstName} ${person.lastName} deleted'),
        ),
      );
      await _loadStaff();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    }
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
                  onPressed: _isLoading ? null : _loadStaff,
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
  }

  Widget _buildBody(ThemeData theme) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _loadStaff,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_staff.isEmpty) {
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
            for (final person in _staff)
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
