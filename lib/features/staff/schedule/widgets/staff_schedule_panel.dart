import 'package:fitcore_client/core/theme/fitcore_tokens.dart';
import 'package:fitcore_client/core/time/tenant_clock.dart';
import 'package:fitcore_client/features/staff/schedule/staff_schedule_controller.dart';
import 'package:fitcore_client/features/tenant/dashboard/helpers/dashboard_layout.dart';
import 'package:fitcore_client/features/tenant/members/api/members_api.dart';
import 'package:fitcore_client/features/tenant/memberships/models/membership_response.dart';
import 'package:fitcore_client/features/tenant/staff/models/staff_response.dart';
import 'package:fitcore_client/features/tenant/visits/models/visit_resolve_outcome.dart';
import 'package:fitcore_client/features/tenant/visits/models/visit_response.dart';
import 'package:fitcore_client/features/tenant/visits/models/void_visit_request.dart';
import 'package:fitcore_client/features/tenant/visits/visit_calendar_range.dart';
import 'package:fitcore_client/features/tenant/visits/widgets/coach_calendar.dart';
import 'package:fitcore_client/features/tenant/visits/widgets/create_visit_form.dart';
import 'package:fitcore_client/features/tenant/visits/widgets/record_visit_form.dart';
import 'package:fitcore_client/features/tenant/visits/widgets/reschedule_visit_form.dart';
import 'package:fitcore_client/features/tenant/visits/widgets/visit_display.dart';
import 'package:fitcore_client/features/tenant/visits/widgets/visit_member_sheet.dart';
import 'package:flutter/material.dart';

class StaffSchedulePanel extends StatefulWidget {
  const StaffSchedulePanel({super.key, this.controller});

  final StaffScheduleController? controller;

  @override
  State<StaffSchedulePanel> createState() => _StaffSchedulePanelState();
}

class _StaffSchedulePanelState extends State<StaffSchedulePanel> {
  late final StaffScheduleController _controller =
      widget.controller ?? StaffScheduleController();
  late final bool _ownsController = widget.controller == null;

  DateTime _day = _today();

  static DateTime _today() {
    final now = TenantClock.now();
    return DateTime(now.year, now.month, now.day);
  }

  @override
  void initState() {
    super.initState();
    _controller.load(day: _day);
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  Future<void> _onCoachCalendarRange(
    VisitCalendarRange range,
    DateTime focusDay,
  ) async {
    setState(() => _day = focusDay);
    await _controller.loadVisitsForRange(range.from, range.to);
  }

  Future<void> _openCreateForm({StaffResponse? coach, DateTime? start}) async {
    final me = _controller.me;
    if (me == null) return;

    final created = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Schedule visit'),
          content: SizedBox(
            width: 440,
            child: SingleChildScrollView(
              child: CreateVisitForm(
                memberships: _controller.schedulableMemberships,
                staff: _controller.staff,
                visitsApi: _controller.visitsApi,
                initialCoachStaffId: me.id,
                initialStart: start,
                onCreated: (visit) {
                  Navigator.of(dialogContext).pop(true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Scheduled ${visit.serviceName} for ${visit.memberName}',
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
      await _controller.reloadCurrentVisits();
    }
  }

  Future<void> _openRecordForm({StaffResponse? coach, DateTime? start}) async {
    final me = _controller.me;
    if (me == null) return;

    final recorded = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Record past visit'),
          content: SizedBox(
            width: 440,
            child: SingleChildScrollView(
              child: RecordVisitForm(
                memberships: _controller.schedulableMemberships,
                staff: _controller.staff,
                visitsApi: _controller.visitsApi,
                initialCoachStaffId: me.id,
                initialStart: start,
                onRecorded: (visit) {
                  Navigator.of(dialogContext).pop(true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Recorded ${visit.status.toLowerCase()} visit '
                        'for ${visit.memberName}',
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

    if (recorded == true) {
      await _controller.reloadCurrentVisits();
    }
  }

  Future<void> _onSlotTap(StaffResponse coach, DateTime start) {
    if (TenantClock.toUtc(start).isBefore(DateTime.now().toUtc())) {
      return _openRecordForm(coach: coach, start: start);
    }
    return _openCreateForm(coach: coach, start: start);
  }

  Future<void> _openRescheduleForm(VisitResponse visit) async {
    final moved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Reschedule visit'),
          content: SizedBox(
            width: 440,
            child: SingleChildScrollView(
              child: RescheduleVisitForm(
                visit: visit,
                staff: _controller.staff,
                visitsApi: _controller.visitsApi,
                onRescheduled: (updated) {
                  Navigator.of(dialogContext).pop(true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Moved ${updated.memberName} to '
                        '${formatLocalDateTime(updated.startAt)}',
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

    if (moved == true) {
      await _controller.reloadCurrentVisits();
    }
  }

  Future<void> _onVisitTap(VisitResponse visit) async {
    MembershipResponse? membership;
    for (final m in _controller.memberships) {
      if (m.id == visit.membershipId) {
        membership = m;
        break;
      }
    }

    final action = await showVisitMemberSheet(
      context: context,
      visit: visit,
      membership: membership,
      membersApi: MembersApi(basePath: '/api/staff/me/members'),
      showVisitActions: visit.isVoidable,
    );

    if (action == null || !mounted) return;

    switch (action) {
      case 'complete':
        await _resolveVisit(visit, VisitResolveOutcome.completed);
      case 'noShow':
        await _resolveVisit(visit, VisitResolveOutcome.noShow);
      case 'reschedule':
        await _openRescheduleForm(visit);
      case 'void':
        await _voidVisit(visit);
    }
  }

  Future<void> _resolveVisit(
    VisitResponse visit,
    VisitResolveOutcome outcome,
  ) async {
    final error = await _controller.resolveVisit(visit, outcome);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          error ?? '${visit.memberName} marked ${outcome.label.toLowerCase()}',
        ),
      ),
    );
  }

  Future<void> _voidVisit(VisitResponse visit) async {
    final noteController = TextEditingController();

    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Void visit'),
            content: SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Void ${visit.serviceName} for ${visit.memberName} '
                    '(${formatLocalDateTime(visit.startAt)})? '
                    'This undoes a scheduling mistake and restores pack credit if held.',
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
                child: const Text('Void visit'),
              ),
            ],
          );
        },
      );

      final note = noteController.text;
      if (confirmed != true) return;

      final error = await _controller.voidVisit(
        visit,
        VoidVisitRequest(note: note),
      );
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Voided visit for ${visit.memberName}'),
        ),
      );
    } finally {
      noteController.dispose();
    }
  }

  Future<void> _openAddSheet() async {
    final choice = await showModalBottomSheet<_AddVisitChoice>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              FitCoreSpace.x4,
              0,
              FitCoreSpace.x4,
              FitCoreSpace.x4,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Add to schedule',
                  style: Theme.of(sheetContext).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: FitCoreSpace.x3),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.event_available_outlined),
                  title: const Text('Schedule visit'),
                  subtitle: const Text('Book a future session'),
                  onTap: () =>
                      Navigator.of(sheetContext).pop(_AddVisitChoice.schedule),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.history),
                  title: const Text('Record past visit'),
                  subtitle: const Text('Log a session that already happened'),
                  onTap: () =>
                      Navigator.of(sheetContext).pop(_AddVisitChoice.record),
                ),
                const SizedBox(height: FitCoreSpace.x2),
                TextButton(
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted || choice == null) return;
    switch (choice) {
      case _AddVisitChoice.schedule:
        await _openCreateForm();
      case _AddVisitChoice.record:
        await _openRecordForm();
    }
  }

  @override
  Widget build(BuildContext context) {
    final phone =
        MediaQuery.sizeOf(context).width < FitCoreBreakpoints.compact;
    final pad = phone ? FitCoreSpace.x3 : DashboardLayout.pagePadding;

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final theme = Theme.of(context);

        return Padding(
          padding: EdgeInsets.fromLTRB(pad, FitCoreSpace.x2, pad, pad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!phone)
                Padding(
                  padding: const EdgeInsets.only(bottom: FitCoreSpace.x2),
                  child: Row(
                    children: [
                      Expanded(child: _buildStatusLegend(theme)),
                      const SizedBox(width: FitCoreSpace.x3),
                      OutlinedButton.icon(
                        onPressed:
                            _controller.me == null ? null : _openRecordForm,
                        icon: const Icon(Icons.history, size: 16),
                        label: const Text('Record past visit'),
                      ),
                      const SizedBox(width: FitCoreSpace.x2),
                      FilledButton.icon(
                        onPressed: _controller.me == null
                            ? null
                            : () => _openCreateForm(),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Schedule visit'),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: phone
                    ? Stack(
                        children: [
                          Positioned.fill(child: _buildBody(theme)),
                          Positioned(
                            right: 0,
                            bottom: FitCoreSpace.x1,
                            child: FloatingActionButton(
                              onPressed: _controller.me == null
                                  ? null
                                  : _openAddSheet,
                              tooltip: 'Add to schedule',
                              child: const Icon(Icons.add),
                            ),
                          ),
                        ],
                      )
                    : _buildBody(theme),
              ),
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
              onPressed: () => _controller.load(day: _day),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final me = _controller.me;
    if (me == null) {
      return Center(
        child: Text(
          'Could not load your staff profile.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return CoachCalendar(
      coach: me,
      visits: _controller.visits,
      initialDay: _day,
      onVisitTap: _onVisitTap,
      onRangeChanged: _onCoachCalendarRange,
      onSlotTap: _onSlotTap,
    );
  }

  Widget _buildStatusLegend(ThemeData theme) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final tone in visitStatusOrder)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 11,
                height: 11,
                decoration: BoxDecoration(
                  color: tone.color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                tone.label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

enum _AddVisitChoice { schedule, record }
