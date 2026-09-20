import 'package:fitcore_client/core/widgets/fit_data_panel.dart';
import 'package:fitcore_client/core/widgets/fit_page_header.dart';
import 'package:fitcore_client/core/widgets/fit_panel_states.dart';
import 'package:fitcore_client/core/widgets/fit_record_table.dart';
import 'package:fitcore_client/features/tenant/staff/models/staff_response.dart';
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

  Future<void> _inviteStaff(StaffResponse person) async {
    final error = await _controller.invite(person);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error ?? 'Sign-in invite sent to ${person.email}'),
      ),
    );
  }

  Future<void> _deleteStaff(StaffResponse person) async {
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
        final staff = _controller.staff;

        return FitPageBody(
          header: FitPageHeader(
            title: 'Staff',
            description: 'Coaches and operators who can sign in to FitCore.',
            meta: staff.isNotEmpty
                ? FitCountBadge(count: staff.length, noun: 'total')
                : null,
            actions: [
              OutlinedButton.icon(
                onPressed: _controller.isLoading ? null : _controller.load,
                icon: const Icon(Icons.badge_outlined, size: 16),
                label: const Text('All staff'),
              ),
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
                    icon: const Icon(Icons.add, size: 16),
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
          child: FitDataPanel(child: _buildBody()),
        );
      },
    );
  }

  Widget _buildBody() {
    if (_controller.isLoading) {
      return const FitTableSkeleton(columnFlex: [3, 4]);
    }

    if (_controller.error != null) {
      return FitErrorState(
        message: _controller.error!,
        onRetry: _controller.load,
      );
    }

    if (_controller.staff.isEmpty) {
      return FitEmptyState(
        icon: Icons.badge_outlined,
        title: 'No staff yet',
        message: 'Add your first staff member to get started.',
        action: FilledButton.icon(
          onPressed: _openCreateStaffForm,
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Add staff'),
        ),
      );
    }

    return FitRecordTable(
      columns: const [
        FitColumn(label: 'Name', flex: 3, minWidth: 180),
        FitColumn(label: 'Email', flex: 4, minWidth: 220),
      ],
      rows: [
        for (final person in _controller.staff)
          FitRecordRow(
            leading: FitAvatar(name: '${person.firstName} ${person.lastName}'),
            cells: [
              FitTextCell(
                '${person.firstName} ${person.lastName}',
                strong: true,
              ),
              FitTextCell(person.email, muted: true),
            ],
            actions: [
              FitRowAction(
                icon: Icons.outgoing_mail,
                tooltip: 'Invite to sign in',
                onPressed: () => _inviteStaff(person),
              ),
              FitRowAction(
                icon: Icons.delete_outline,
                tooltip: 'Delete',
                danger: true,
                onPressed: () => _deleteStaff(person),
              ),
            ],
          ),
      ],
    );
  }
}
