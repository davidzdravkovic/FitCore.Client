import 'package:fitcore_client/core/widgets/fit_data_panel.dart';
import 'package:fitcore_client/core/widgets/fit_page_header.dart';
import 'package:fitcore_client/core/widgets/fit_panel_states.dart';
import 'package:fitcore_client/core/widgets/fit_record_table.dart';
import 'package:fitcore_client/core/widgets/fit_status_chip.dart';
import 'package:fitcore_client/features/tenant/members/models/member_response.dart';
import 'package:fitcore_client/features/tenant/members/models/member_status.dart';
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

  Future<void> _openImportMemberForm() async {
    final imported = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Import member'),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: MemberForm(
                isImport: true,
                membersApi: _controller.membersApi,
                onCreated: (member) {
                  Navigator.of(dialogContext).pop(true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${member.firstName} ${member.lastName} imported',
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

    if (imported == true) {
      await _controller.load();
    }
  }

  Future<void> _inviteMember(MemberResponse member) async {
    final error = await _controller.invite(member);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error ?? 'Account invite sent to ${member.email}'),
      ),
    );
  }

  Future<void> _deleteMember(MemberResponse member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Cancel member'),
          content: Text(
            'Cancel ${member.firstName} ${member.lastName}? '
            'They will be deleted an unseen by the gym.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Keep'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Cancel member'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    final error = await _controller.delete(member);
    if (!mounted) return;

    if (error != null) {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Cannot cancel member'),
            content: SingleChildScrollView(child: Text(error)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${member.firstName} ${member.lastName} cancelled'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const menuWidth = 220.0;

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final members = _controller.members;
        final hasRecords = members.isNotEmpty;

        return FitPageBody(
          header: FitPageHeader(
            title: 'Members',
            description: 'People in your gym and the state of each record.',
            meta: hasRecords
                ? FitCountBadge(count: members.length, noun: 'total')
                : null,
            actions: [
              OutlinedButton.icon(
                onPressed: _controller.isLoading ? null : _controller.load,
                icon: const Icon(Icons.people_outline, size: 16),
                label: const Text('All members'),
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
                      onPressed: _openCreateMemberForm,
                      child: const Text('Add member'),
                    ),
                  ),
                  SizedBox(
                    width: menuWidth,
                    child: MenuItemButton(
                      leadingIcon: const Icon(Icons.upload_file_outlined),
                      onPressed: _openImportMemberForm,
                      child: const Text('Import members'),
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
      return const FitTableSkeleton(columnFlex: [3, 3, 2, 2]);
    }

    if (_controller.error != null) {
      return FitErrorState(
        message: _controller.error!,
        onRetry: _controller.load,
      );
    }

    if (_controller.members.isEmpty) {
      return FitEmptyState(
        icon: Icons.people_outline,
        title: 'No members yet',
        message: 'Add your first member to get started.',
        action: FilledButton.icon(
          onPressed: _openCreateMemberForm,
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Add member'),
        ),
      );
    }

    return FitRecordTable(
      columns: const [
        FitColumn(label: 'Name', flex: 3, minWidth: 180),
        FitColumn(label: 'Email', flex: 3, minWidth: 200),
        FitColumn(label: 'Phone', flex: 2, minWidth: 140, hideBelow: 1040),
        FitColumn(label: 'Status', flex: 2, minWidth: 130),
      ],
      rows: [
        for (final member in _controller.members)
          FitRecordRow(
            leading: FitAvatar(name: '${member.firstName} ${member.lastName}'),
            cells: [
              FitTextCell(
                '${member.firstName} ${member.lastName}',
                strong: true,
              ),
              if (member.email?.isNotEmpty == true)
                FitTextCell(member.email!, muted: true)
              else
                const FitTextCell.empty(),
              if (member.phone?.isNotEmpty == true)
                FitTextCell(member.phone!, muted: true, mono: true)
              else
                const FitTextCell.empty(),
              FitStatusChip(
                label: member.status.label,
                tone: member.status.tone,
              ),
            ],
            actions: [
              FitRowAction(
                icon: Icons.outgoing_mail,
                tooltip: member.email?.isNotEmpty == true
                    ? 'Invite to set up account'
                    : 'Needs an email first',
                onPressed: member.email?.isNotEmpty == true
                    ? () => _inviteMember(member)
                    : null,
              ),
              FitRowAction(
                icon: Icons.person_off_outlined,
                tooltip: 'Cancel member',
                danger: true,
                onPressed: () => _deleteMember(member),
              ),
            ],
          ),
      ],
    );
  }
}

/// Visual weight for the statuses the API already returns.
extension on MemberStatus {
  FitTone get tone => switch (this) {
    MemberStatus.lead => FitTone.neutral,
    MemberStatus.trial => FitTone.caution,
    MemberStatus.active => FitTone.positive,
    MemberStatus.paused => FitTone.warning,
    MemberStatus.cancelled => FitTone.negative,
  };
}
