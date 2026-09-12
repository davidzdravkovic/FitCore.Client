import 'package:fitcore_client/features/tenant/dashboard/helpers/dashboard_layout.dart';
import 'package:fitcore_client/features/tenant/members/models/members_models.dart';
import 'package:fitcore_client/features/tenant/members/members_controller.dart';
import 'package:fitcore_client/features/tenant/members/widgets/member_form.dart';
import 'package:flutter/material.dart';

class MembersPanel extends StatefulWidget {
  const MembersPanel({super.key, this.controller});

  final MembersController? controller;

  @override
  State<MembersPanel> createState() => _MembersPanelState();
}

class _MembersPanelState extends State<MembersPanel> {
  late final MembersController _controller =
      widget.controller ?? MembersController();
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

  Future<void> _openCreateMemberForm() async {
    final created = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add member'),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: MemberForm(
                membersApi: _controller.membersApi,
                onCreated: (member) {
                  Navigator.of(dialogContext).pop(true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${member.firstName} ${member.lastName} created',
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

  Future<void> _inviteMember(MemberResponse member) async {
    final error = await _controller.invite(member);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          error ?? 'Account invite sent to ${member.email}',
        ),
      ),
    );
  }

  Future<void> _deleteMember(MemberResponse member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete member'),
          content: Text(
            'Remove ${member.firstName} ${member.lastName}? '
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

    final error = await _controller.delete(member);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          error ?? '${member.firstName} ${member.lastName} deleted',
        ),
      ),
    );
  }

  void _showImportComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Import is for bringing members (and history) from another system. Coming soon.',
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
                      icon: const Icon(Icons.people_outline),
                      label: const Text('All members'),
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
                            onPressed: _openCreateMemberForm,
                            child: const Text('Add member'),
                          ),
                        ),
                        SizedBox(
                          width: menuWidth,
                          child: MenuItemButton(
                            leadingIcon: const Icon(Icons.upload_file_outlined),
                            onPressed: _showImportComingSoon,
                            child: const Text('Import members'),
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

    if (_controller.members.isEmpty) {
      return Center(
        child: Text(
          'No members yet. Add your first member to get started.',
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
            DataColumn(label: Text('Phone')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('')),
          ],
          rows: [
            for (final member in _controller.members)
              DataRow(
                cells: [
                  DataCell(Text('${member.firstName} ${member.lastName}')),
                  DataCell(Text(member.email?.isNotEmpty == true
                      ? member.email!
                      : '—')),
                  DataCell(Text(member.phone?.isNotEmpty == true
                      ? member.phone!
                      : '—')),
                  DataCell(Text(member.status.label)),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: member.email?.isNotEmpty == true
                              ? 'Invite to set up account'
                              : 'Needs an email first',
                          onPressed: member.email?.isNotEmpty == true
                              ? () => _inviteMember(member)
                              : null,
                          icon: const Icon(Icons.outgoing_mail),
                        ),
                        IconButton(
                          tooltip: 'Delete',
                          onPressed: () => _deleteMember(member),
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
