import 'package:fitcore_client/core/api/api_exception.dart';
import 'package:fitcore_client/features/tenant/dashboard/helpers/dashboard_layout.dart';
import 'package:fitcore_client/features/tenant/members/api/members_api.dart';
import 'package:fitcore_client/features/tenant/members/api/members_models.dart';
import 'package:fitcore_client/features/tenant/members/widgets/member_form.dart';
import 'package:flutter/material.dart';

class MembersPanel extends StatefulWidget {
  const MembersPanel({super.key, this.membersApi});

  final MembersApi? membersApi;

  @override
  State<MembersPanel> createState() => _MembersPanelState();
}

class _MembersPanelState extends State<MembersPanel> {
  late final MembersApi _membersApi = widget.membersApi ?? MembersApi();

  List<Member> _members = const [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final members = await _membersApi.list();
      if (!mounted) return;
      setState(() {
        _members = members;
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
                membersApi: _membersApi,
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
      await _loadMembers();
    }
  }

  Future<void> _inviteMember(Member member) async {
    try {
      await _membersApi.invite(member.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Account invite sent to ${member.email}')),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    }
  }

  Future<void> _deleteMember(Member member) async {
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

    try {
      await _membersApi.delete(member.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${member.firstName} ${member.lastName} deleted'),
        ),
      );
      await _loadMembers();
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
          'Import is for bringing members (and history) from another system. Coming soon.',
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
                  onPressed: _isLoading ? null : _loadMembers,
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
              onPressed: _loadMembers,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_members.isEmpty) {
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
            for (final member in _members)
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
