import 'package:fitcore_client/features/tenant/dashboard/helpers/dashboard_layout.dart';
import 'package:fitcore_client/features/tenant/memberships/memberships_controller.dart';
import 'package:fitcore_client/features/tenant/memberships/models/memberships_models.dart';
import 'package:fitcore_client/features/tenant/memberships/widgets/assign_membership_form.dart';
import 'package:flutter/material.dart';

class MembershipsPanel extends StatefulWidget {
  const MembershipsPanel({super.key, this.controller});

  final MembershipsController? controller;

  @override
  State<MembershipsPanel> createState() => _MembershipsPanelState();
}

class _MembershipsPanelState extends State<MembershipsPanel> {
  late final MembershipsController _controller =
      widget.controller ?? MembershipsController();
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

  Future<void> _openAssignForm() async {
    final created = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Assign membership'),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: AssignMembershipForm(
                members: _controller.members,
                activePlans: _controller.activePlans,
                membershipsApi: _controller.membershipsApi,
                onAssigned: (membership) {
                  Navigator.of(dialogContext).pop(true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Assigned ${membership.planName} to ${membership.memberName}',
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

  Future<void> _cancelMembership(MembershipResponse membership) async {
    var reason = MembershipCancelReason.memberRequest;
    final noteController = TextEditingController();

    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: const Text('Cancel membership'),
                content: SizedBox(
                  width: 420,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Cancel ${membership.planName} for ${membership.memberName}? '
                        'This ends the entitlement. No refund is processed in the app.',
                      ),
                      const SizedBox(height: 16),
                      DropdownMenu<MembershipCancelReason>(
                        initialSelection: reason,
                        label: const Text('Reason'),
                        expandedInsets: EdgeInsets.zero,
                        dropdownMenuEntries: [
                          for (final value in MembershipCancelReason.values)
                            DropdownMenuEntry(
                              value: value,
                              label: value.label,
                            ),
                        ],
                        onSelected: (value) {
                          if (value == null) return;
                          setDialogState(() => reason = value);
                        },
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: noteController,
                        maxLength: 500,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Note (optional)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    child: const Text('Keep'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                    child: const Text('Cancel membership'),
                  ),
                ],
              );
            },
          );
        },
      );

      final note = noteController.text;

      if (confirmed != true) return;

      final error = await _controller.cancel(
        membership,
        CancelMembershipRequest(reason: reason, note: note),
      );
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error ??
                'Cancelled ${membership.planName} for ${membership.memberName}',
          ),
        ),
      );
    } finally {
      noteController.dispose();
    }
  }

  String _formatDate(DateTime value) {
    final local = value.toLocal();
    final y = local.year.toString().padLeft(4, '0');
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  String _entitlementCell(MembershipResponse membership) {
    if (membership.sessionsRemaining != null) {
      return '${membership.sessionsRemaining} sessions left';
    }
    if (membership.endAt != null) {
      return 'Ends ${_formatDate(membership.endAt!)}';
    }
    return '—';
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
                  onPressed: _openAssignForm,
                  icon: const Icon(Icons.add),
                  label: const Text('Assign'),
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

    if (_controller.memberships.isEmpty) {
      return Center(
        child: Text(
          'No memberships yet. Assign a plan to a member to get started.',
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
            DataColumn(label: Text('Member')),
            DataColumn(label: Text('Plan')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Start')),
            DataColumn(label: Text('Entitlement')),
            DataColumn(label: Text('')),
          ],
          rows: [
            for (final membership in _controller.memberships)
              DataRow(
                cells: [
                  DataCell(Text(membership.memberName)),
                  DataCell(Text(membership.planName)),
                  DataCell(Text(membership.status)),
                  DataCell(Text(_formatDate(membership.startAt))),
                  DataCell(Text(_entitlementCell(membership))),
                  DataCell(
                    membership.isCancellable
                        ? IconButton(
                            tooltip: 'Cancel membership',
                            onPressed: () => _cancelMembership(membership),
                            icon: const Icon(Icons.cancel_outlined),
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
