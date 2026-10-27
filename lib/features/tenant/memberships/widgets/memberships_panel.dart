import 'package:fitcore_client/core/theme/fitcore_tokens.dart';
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

  bool get _phone =>
      MediaQuery.sizeOf(context).width < FitCoreBreakpoints.compact;

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

  Future<bool?> _presentForm({
    required String title,
    required Widget Function(BuildContext host) formBuilder,
    List<Widget> Function(BuildContext host)? actions,
  }) {
    if (_phone) {
      return showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (sheetContext) {
          return Padding(
            padding: EdgeInsets.fromLTRB(
              FitCoreSpace.x4,
              0,
              FitCoreSpace.x4,
              FitCoreSpace.x4 + MediaQuery.viewInsetsOf(sheetContext).bottom,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: Theme.of(sheetContext).textTheme.titleMedium,
                  ),
                  const SizedBox(height: FitCoreSpace.x4),
                  formBuilder(sheetContext),
                  if (actions != null) ...[
                    const SizedBox(height: FitCoreSpace.x3),
                    ...actions(sheetContext),
                  ] else ...[
                    const SizedBox(height: FitCoreSpace.x3),
                    TextButton(
                      onPressed: () => Navigator.of(sheetContext).pop(false),
                      child: const Text('Cancel'),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      );
    }

    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: SizedBox(
            width: fitDialogWidth(dialogContext),
            child: SingleChildScrollView(
              child: formBuilder(dialogContext),
            ),
          ),
          actions: actions != null
              ? actions(dialogContext)
              : [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    child: const Text('Cancel'),
                  ),
                ],
        );
      },
    );
  }

  Future<void> _openAssignForm() async {
    final created = await _presentForm(
      title: 'Assign membership',
      formBuilder: (host) => AssignMembershipForm(
        members: _controller.members,
        activePlans: _controller.activePlans,
        membershipsApi: _controller.membershipsApi,
        onAssigned: (membership) {
          Navigator.of(host).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Assigned ${membership.planName} to ${membership.memberName}',
              ),
            ),
          );
        },
      ),
    );

    if (created == true) {
      await _controller.load();
    }
  }

  Future<void> _openDetail(MembershipResponse membership) async {
    Widget body(BuildContext host) {
      return _MembershipDetailBody(
        membership: membership,
        entitlement: _entitlementCell(membership),
        startLabel: _formatDate(membership.startAt),
        statusTone: _statusTone(membership.status),
        onClose: () => Navigator.of(host).pop(),
        onCancel: membership.isCancellable
            ? () async {
                Navigator.of(host).pop();
                await _cancelMembership(membership);
              }
            : null,
      );
    }

    if (_phone) {
      await showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (sheetContext) {
          return SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                FitCoreSpace.x4,
                0,
                FitCoreSpace.x4,
                FitCoreSpace.x4 + MediaQuery.viewInsetsOf(sheetContext).bottom,
              ),
              child: body(sheetContext),
            ),
          );
        },
      );
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          contentPadding: const EdgeInsets.fromLTRB(
            FitCoreSpace.x6,
            FitCoreSpace.x5,
            FitCoreSpace.x6,
            FitCoreSpace.x4,
          ),
          content: SizedBox(width: 420, child: body(dialogContext)),
        );
      },
    );
  }

  Future<void> _cancelMembership(MembershipResponse membership) async {
    var reason = MembershipCancelReason.memberRequest;
    final noteController = TextEditingController();

    try {
      final confirmed = await _presentForm(
        title: 'Cancel membership',
        formBuilder: (host) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Cancel ${membership.planName} for ${membership.memberName}? '
                    'This ends the entitlement. No refund is processed in the app.',
                  ),
                  const SizedBox(height: FitCoreSpace.x4),
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
                  const SizedBox(height: FitCoreSpace.x4),
                  TextField(
                    controller: noteController,
                    maxLength: 500,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Note (optional)',
                    ),
                  ),
                ],
              );
            },
          );
        },
        actions: (host) => [
          TextButton(
            onPressed: () => Navigator.of(host).pop(false),
            child: const Text('Keep'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(host).pop(true),
            child: const Text('Cancel membership'),
          ),
        ],
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

  String _entitlementShort(MembershipResponse membership) {
    if (membership.sessionsAvailable >= 0) {
      return '${membership.sessionsAvailable} left';
    }
    return 'No sessions';
  }

  @override
  Widget build(BuildContext context) {
    final phone = _phone;

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final memberships = _controller.memberships;

        return FitPageBody(
          header: FitPageHeader(
            dense: phone,
            title: 'Memberships',
            description: phone
                ? null
                : 'Plans assigned to members and what is left on them.',
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
          child: FitDataPanel(child: _buildBody(phone: phone)),
        );
      },
    );
  }

  Widget _buildBody({required bool phone}) {
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

    if (phone) {
      return _MembershipCardList(
        memberships: _controller.memberships,
        entitlementShort: _entitlementShort,
        statusTone: _statusTone,
        onOpen: _openDetail,
        onCancel: _cancelMembership,
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
              FitRowAction(
                icon: Icons.info_outline,
                tooltip: 'Details',
                onPressed: () => _openDetail(membership),
              ),
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

class _MembershipCardList extends StatelessWidget {
  const _MembershipCardList({
    required this.memberships,
    required this.entitlementShort,
    required this.statusTone,
    required this.onOpen,
    required this.onCancel,
  });

  final List<MembershipResponse> memberships;
  final String Function(MembershipResponse) entitlementShort;
  final FitTone Function(String status) statusTone;
  final ValueChanged<MembershipResponse> onOpen;
  final ValueChanged<MembershipResponse> onCancel;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: memberships.length,
      separatorBuilder: (_, __) => const SizedBox(height: FitCoreSpace.x3),
      itemBuilder: (context, index) {
        final membership = memberships[index];
        return _MembershipCard(
          membership: membership,
          entitlementShort: entitlementShort(membership),
          statusTone: statusTone(membership.status),
          onTap: () => onOpen(membership),
          onCancel: membership.isCancellable
              ? () => onCancel(membership)
              : null,
        );
      },
    );
  }
}

class _MembershipCard extends StatefulWidget {
  const _MembershipCard({
    required this.membership,
    required this.entitlementShort,
    required this.statusTone,
    required this.onTap,
    this.onCancel,
  });

  final MembershipResponse membership;
  final String entitlementShort;
  final FitTone statusTone;
  final VoidCallback onTap;
  final VoidCallback? onCancel;

  @override
  State<_MembershipCard> createState() => _MembershipCardState();
}

class _MembershipCardState extends State<_MembershipCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.fc;
    final membership = widget.membership;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Material(
        color: _hovered ? t.elevated : t.panel,
        borderRadius: BorderRadius.circular(FitCoreRadius.lg),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(FitCoreRadius.lg),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(FitCoreRadius.lg),
              border: Border.all(
                color: _hovered ? t.borderDefault : t.borderSubtle,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(FitCoreSpace.x4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      FitAvatar(name: membership.memberName),
                      const SizedBox(width: FitCoreSpace.x3),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              membership.memberName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              membership.planName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: t.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      FitStatusChip(
                        label: membership.status,
                        tone: widget.statusTone,
                        dense: true,
                      ),
                      if (widget.onCancel != null)
                        FitRowAction(
                          icon: Icons.cancel_outlined,
                          tooltip: 'Cancel membership',
                          danger: true,
                          onPressed: widget.onCancel,
                        ),
                    ],
                  ),
                  const SizedBox(height: FitCoreSpace.x3),
                  Row(
                    children: [
                      Text(
                        widget.entitlementShort,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: t.textSecondary,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.chevron_right, size: 18, color: t.textMuted),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MembershipDetailBody extends StatelessWidget {
  const _MembershipDetailBody({
    required this.membership,
    required this.entitlement,
    required this.startLabel,
    required this.statusTone,
    required this.onClose,
    this.onCancel,
  });

  final MembershipResponse membership;
  final String entitlement;
  final String startLabel;
  final FitTone statusTone;
  final VoidCallback onClose;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.fc;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          membership.memberName,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: FitCoreSpace.x1),
        Text(
          membership.planName,
          style: theme.textTheme.bodySmall?.copyWith(color: t.textSecondary),
        ),
        const SizedBox(height: FitCoreSpace.x4),
        Container(
          padding: const EdgeInsets.all(FitCoreSpace.x4),
          decoration: BoxDecoration(
            color: t.elevated,
            borderRadius: BorderRadius.circular(FitCoreRadius.md),
            border: Border.all(color: t.borderSubtle),
          ),
          child: Column(
            children: [
              _DetailRow(label: 'Start', value: startLabel),
              const SizedBox(height: FitCoreSpace.x3),
              _DetailRow(label: 'Entitlement', value: entitlement),
              const SizedBox(height: FitCoreSpace.x3),
              Row(
                children: [
                  Text(
                    'Status',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: t.textMuted,
                    ),
                  ),
                  const Spacer(),
                  FitStatusChip(
                    label: membership.status,
                    tone: statusTone,
                    dense: true,
                  ),
                ],
              ),
            ],
          ),
        ),
        if (onCancel != null) ...[
          const SizedBox(height: FitCoreSpace.x4),
          OutlinedButton.icon(
            onPressed: onCancel,
            icon: const Icon(Icons.cancel_outlined, size: 16),
            label: const Text('Cancel membership'),
          ),
        ],
        const SizedBox(height: FitCoreSpace.x2),
        TextButton(
          onPressed: onClose,
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.fc;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(color: t.textMuted),
        ),
        const SizedBox(width: FitCoreSpace.x3),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ],
    );
  }
}
