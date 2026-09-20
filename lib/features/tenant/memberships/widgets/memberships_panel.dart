import 'package:fitcore_client/core/widgets/fit_data_panel.dart';
import 'package:fitcore_client/core/widgets/fit_page_header.dart';
import 'package:fitcore_client/core/widgets/fit_panel_states.dart';
import 'package:fitcore_client/core/widgets/fit_record_table.dart';
import 'package:fitcore_client/core/widgets/fit_status_chip.dart';
import 'package:fitcore_client/features/tenant/memberships/memberships_controller.dart';
import 'package:fitcore_client/features/tenant/memberships/models/cancel_membership_request.dart';
import 'package:fitcore_client/features/tenant/memberships/models/membership_cancel_reason.dart';
import 'package:fitcore_client/features/tenant/memberships/models/membership_response.dart';
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
                            DropdownMenuEntry(value: value, label: value.label),
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
    if (membership.sessionsAvailable >= 0) {
      return '${membership.sessionsAvailable} available '
          '(${membership.sessionsReserved} reserved, '
          '${membership.sessionsBurned} burned / ${membership.sessionTotal})';
    }
    return 'No sessions';
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final memberships = _controller.memberships;

        return FitPageBody(
          header: FitPageHeader(
            title: 'Memberships',
            description: 'Plans assigned to members and what is left on them.',
            meta: memberships.isNotEmpty
                ? FitCountBadge(count: memberships.length, noun: 'total')
                : null,
            actions: [
              FilledButton.icon(
                onPressed: _openAssignForm,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Assign'),
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
      return const FitTableSkeleton(columnFlex: [3, 3, 2, 2, 3]);
    }

    if (_controller.error != null) {
      return FitErrorState(
        message: _controller.error!,
        onRetry: _controller.load,
      );
    }

    if (_controller.memberships.isEmpty) {
      return FitEmptyState(
        icon: Icons.card_membership_outlined,
        title: 'No memberships yet',
        message: 'Assign a plan to a member to get started.',
        action: FilledButton.icon(
          onPressed: _openAssignForm,
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Assign'),
        ),
      );
    }

    return FitRecordTable(
      columns: const [
        FitColumn(label: 'Member', flex: 3, minWidth: 170),
        FitColumn(label: 'Plan', flex: 3, minWidth: 160),
        FitColumn(label: 'Status', flex: 2, minWidth: 130),
        FitColumn(label: 'Start', flex: 2, minWidth: 110, hideBelow: 1040),
        FitColumn(
          label: 'Entitlement',
          flex: 3,
          minWidth: 220,
          hideBelow: 1180,
        ),
      ],
      rows: [
        for (final membership in _controller.memberships)
          FitRecordRow(
            leading: FitAvatar(name: membership.memberName),
            cells: [
              FitTextCell(membership.memberName, strong: true),
              FitTextCell(membership.planName),
              FitStatusChip(
                label: membership.status,
                tone: _statusTone(membership.status),
              ),
              FitTextCell(
                _formatDate(membership.startAt),
                muted: true,
                mono: true,
              ),
              FitTextCell(_entitlementCell(membership), muted: true),
            ],
            actions: [
              if (membership.isCancellable)
                FitRowAction(
                  icon: Icons.cancel_outlined,
                  tooltip: 'Cancel membership',
                  danger: true,
                  onPressed: () => _cancelMembership(membership),
                ),
            ],
          ),
      ],
    );
  }

  /// Visual weight for the status string the API already returns.
  FitTone _statusTone(String status) {
    return switch (status.trim().toLowerCase()) {
      'active' => FitTone.positive,
      'paused' => FitTone.warning,
      'pending' => FitTone.caution,
      'cancelled' => FitTone.negative,
      'expired' || 'completed' => FitTone.muted,
      _ => FitTone.neutral,
    };
  }
}
