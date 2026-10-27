import 'package:fitcore_client/core/theme/fitcore_tokens.dart';
import 'package:fitcore_client/core/widgets/fit_panel_states.dart';
import 'package:fitcore_client/core/widgets/fit_record_table.dart';
import 'package:fitcore_client/core/widgets/fit_status_chip.dart';
import 'package:fitcore_client/features/staff/members/staff_members_controller.dart';
import 'package:fitcore_client/features/tenant/dashboard/helpers/dashboard_layout.dart';
import 'package:fitcore_client/features/tenant/members/models/member_status.dart';
import 'package:flutter/material.dart';

class StaffMembersPanel extends StatefulWidget {
  const StaffMembersPanel({super.key, this.controller});

  final StaffMembersController? controller;

  @override
  State<StaffMembersPanel> createState() => _StaffMembersPanelState();
}

class _StaffMembersPanelState extends State<StaffMembersPanel> {
  late final StaffMembersController _controller =
      widget.controller ?? StaffMembersController();
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

  @override
  Widget build(BuildContext context) {
    final phone =
        MediaQuery.sizeOf(context).width < FitCoreBreakpoints.compact;
    final pad = phone ? FitCoreSpace.x3 : DashboardLayout.pagePadding;
    final t = context.fc;

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return Padding(
          padding: EdgeInsets.fromLTRB(pad, FitCoreSpace.x2, pad, pad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _controller.isLoading ? null : _controller.load,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Refresh'),
                ),
              ),
              const SizedBox(height: FitCoreSpace.x2),
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: t.panel,
                    borderRadius: BorderRadius.circular(FitCoreRadius.lg),
                    border: Border.all(color: t.borderSubtle),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(FitCoreRadius.lg),
                    child: _buildBody(),
                  ),
                ),
              ),
            ],
          ),
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
      return const FitEmptyState(
        icon: Icons.people_outline,
        title: 'No members yet',
        message: 'Members will show up here once they join this gym.',
      );
    }

    // shrinkWrap: false — ListView fills the Expanded panel (FitDataPanel's
    // min Column would give this zero height on phone).
    return FitRecordTable(
      shrinkWrap: false,
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
                tone: member.status._tone,
              ),
            ],
          ),
      ],
    );
  }
}

extension on MemberStatus {
  FitTone get _tone => switch (this) {
        MemberStatus.lead => FitTone.neutral,
        MemberStatus.trial => FitTone.caution,
        MemberStatus.active => FitTone.positive,
        MemberStatus.paused => FitTone.warning,
        MemberStatus.cancelled => FitTone.negative,
      };
}
