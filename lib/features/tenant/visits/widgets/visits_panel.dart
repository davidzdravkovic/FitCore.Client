import 'package:fitcore_client/core/theme/fitcore_tokens.dart';
import 'package:fitcore_client/core/time/tenant_clock.dart';
import 'package:fitcore_client/core/widgets/fit_page_header.dart';
import 'package:fitcore_client/core/widgets/fit_panel_states.dart';
import 'package:fitcore_client/features/tenant/staff/models/staff_response.dart';
import 'package:fitcore_client/features/tenant/visits/layout/coach_day_board_layout.dart';
import 'package:fitcore_client/features/tenant/visits/models/visit_resolve_outcome.dart';
import 'package:fitcore_client/features/tenant/visits/models/visit_response.dart';
import 'package:fitcore_client/features/tenant/visits/models/void_visit_request.dart';
import 'package:fitcore_client/features/tenant/visits/visit_calendar_range.dart';
import 'package:fitcore_client/features/tenant/visits/visits_controller.dart';
import 'package:fitcore_client/features/tenant/visits/widgets/coach_calendar.dart';
import 'package:fitcore_client/features/tenant/visits/widgets/coach_day_board.dart';
import 'package:fitcore_client/features/tenant/visits/widgets/create_visit_form.dart';
import 'package:fitcore_client/features/tenant/visits/widgets/record_visit_form.dart';
import 'package:fitcore_client/features/tenant/visits/widgets/reschedule_visit_form.dart';
import 'package:fitcore_client/features/tenant/visits/widgets/visit_display.dart';
import 'package:flutter/material.dart';

enum _VisitAction { complete, noShow, reschedule, voidVisit }

class VisitsPanel extends StatefulWidget {
  const VisitsPanel({super.key, this.controller});

  final VisitsController? controller;

  @override
  State<VisitsPanel> createState() => _VisitsPanelState();
}

class _VisitsPanelState extends State<VisitsPanel> {
  late final VisitsController _controller =
      widget.controller ?? VisitsController();
  late final bool _ownsController = widget.controller == null;

  DateTime _day = _today();
  StaffResponse? _focusedCoach;

  static DateTime _today() {
    final now = TenantClock.now();
    return DateTime(now.year, now.month, now.day);
  }

  @override
  void initState() {
    super.initState();
    _controller.load(day: _day);
  }

  Future<void> _onBoardDayChanged(DateTime day) async {
    setState(() => _day = day);
    await _controller.loadVisitsForDay(day);
  }

  Future<void> _onCoachCalendarRange(
    VisitCalendarRange range,
    DateTime focusDay,
  ) async {
    setState(() => _day = focusDay);
    await _controller.loadVisitsForRange(range.from, range.to);
  }

  Future<void> _backToDayBoard() async {
    setState(() => _focusedCoach = null);
    await _controller.loadVisitsForDay(_day);
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  Future<void> _openCreateForm({StaffResponse? coach, DateTime? start}) async {
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
                initialCoachStaffId: coach?.id,
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
                initialCoachStaffId: coach?.id,
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

  /// Empty board slots: past → record (backfill), future → schedule.
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
    if (!visit.isVoidable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${visit.memberName} · ${visit.status} '
            '(${formatLocalDateTime(visit.startAt)})',
          ),
        ),
      );
      return;
    }

    final action = await showDialog<_VisitAction>(
      context: context,
      builder: (dialogContext) => _buildActionsDialog(dialogContext, visit),
    );

    if (action == null || !mounted) return;

    switch (action) {
      case _VisitAction.complete:
        await _resolveVisit(visit, VisitResolveOutcome.completed);
      case _VisitAction.noShow:
        await _resolveVisit(visit, VisitResolveOutcome.noShow);
      case _VisitAction.reschedule:
        await _openRescheduleForm(visit);
      case _VisitAction.voidVisit:
        await _voidVisit(visit);
    }
  }

  Widget _buildActionsDialog(BuildContext dialogContext, VisitResponse visit) {
    final canResolve = visit.canResolveNow;
    const notStartedYet = 'Available once the visit has started';

    return AlertDialog(
      title: Text('${visit.memberName} · ${visit.serviceName}'),
      contentPadding: const EdgeInsets.symmetric(vertical: 12),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Text(
                '${formatLocalDateTime(visit.startAt)} – '
                '${formatClock(visit.endAt)} · ${visit.coachName}',
                style: Theme.of(dialogContext).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(dialogContext).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            ListTile(
              enabled: canResolve,
              leading: const Icon(Icons.check_circle_outline),
              title: const Text('Complete'),
              subtitle: Text(
                canResolve ? 'Burns the reserved credit' : notStartedYet,
              ),
              onTap: () =>
                  Navigator.of(dialogContext).pop(_VisitAction.complete),
            ),
            ListTile(
              enabled: canResolve,
              leading: const Icon(Icons.person_off_outlined),
              title: const Text('No-show'),
              subtitle: Text(
                canResolve ? 'Burns the reserved credit' : notStartedYet,
              ),
              onTap: () => Navigator.of(dialogContext).pop(_VisitAction.noShow),
            ),
            ListTile(
              leading: const Icon(Icons.event_repeat_outlined),
              title: const Text('Reschedule'),
              subtitle: const Text('Move to another slot or coach'),
              onTap: () =>
                  Navigator.of(dialogContext).pop(_VisitAction.reschedule),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Void'),
              subtitle: const Text('Undo a scheduling mistake'),
              onTap: () =>
                  Navigator.of(dialogContext).pop(_VisitAction.voidVisit),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Close'),
        ),
      ],
    );
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

  Future<void> _pickDay() async {
    final now = TenantClock.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _day,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    await _onBoardDayChanged(DateTime(picked.year, picked.month, picked.day));
  }

  void _shiftDay(int days) {
    final next = _day.add(Duration(days: days));
    _onBoardDayChanged(DateTime(next.year, next.month, next.day));
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final phone = width < FitCoreBreakpoints.compact;
    final pad = phone ? FitCoreSpace.x3 : FitCoreSpace.x4;
    final showDayNav = _focusedCoach == null;

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        // One calendar toolbar: day nav + primary actions (Google Calendar style).
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                pad,
                FitCoreSpace.x2,
                pad,
                FitCoreSpace.x2,
              ),
              child: _buildCommandBar(
                context,
                phone: phone,
                showDayNav: showDayNav,
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(pad, 0, pad, pad),
                child: _buildBody(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCommandBar(
    BuildContext context, {
    required bool phone,
    required bool showDayNav,
  }) {
    final theme = Theme.of(context);
    final t = context.fc;
    final isToday = isSameDay(_day, TenantClock.now());
    final dayVisitCount = CoachDayBoardLayout.visitsForDay(
      visits: _controller.visits,
      day: _day,
    ).length;

    final schedule = FilledButton.icon(
      onPressed: () => _openCreateForm(),
      icon: const Icon(Icons.add, size: 16),
      label: Text(phone ? 'Schedule' : 'Schedule visit'),
    );

    final record = phone
        ? IconButton(
            onPressed: _openRecordForm,
            icon: const Icon(Icons.history, size: 18),
            tooltip: 'Record past visit',
          )
        : TextButton.icon(
            onPressed: _openRecordForm,
            icon: const Icon(Icons.history, size: 16),
            label: const Text('Record past visit'),
          );

    if (!showDayNav) {
      return Row(
        children: [
          const Spacer(),
          record,
          const SizedBox(width: FitCoreSpace.x2),
          schedule,
        ],
      );
    }

    final stepper = Container(
      decoration: BoxDecoration(
        color: t.panel,
        borderRadius: BorderRadius.circular(FitCoreRadius.md),
        border: Border.all(color: t.borderDefault),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: IconButton(
              onPressed: () => _shiftDay(-1),
              tooltip: 'Previous day',
              padding: EdgeInsets.zero,
              iconSize: 18,
              icon: const Icon(Icons.chevron_left),
            ),
          ),
          Container(width: 1, height: 22, color: t.borderSubtle),
          SizedBox(
            width: 36,
            height: 36,
            child: IconButton(
              onPressed: () => _shiftDay(1),
              tooltip: 'Next day',
              padding: EdgeInsets.zero,
              iconSize: 18,
              icon: const Icon(Icons.chevron_right),
            ),
          ),
        ],
      ),
    );

    final today = phone
        ? IconButton(
            onPressed: isToday
                ? null
                : () {
                    final now = TenantClock.now();
                    _onBoardDayChanged(DateTime(now.year, now.month, now.day));
                  },
            icon: const Icon(Icons.today_outlined, size: 18),
            tooltip: 'Today',
            visualDensity: VisualDensity.compact,
          )
        : OutlinedButton(
            onPressed: isToday
                ? null
                : () {
                    final now = TenantClock.now();
                    _onBoardDayChanged(DateTime(now.year, now.month, now.day));
                  },
            child: const Text('Today'),
          );

    final dayPicker = InkWell(
      onTap: _pickDay,
      borderRadius: BorderRadius.circular(FitCoreRadius.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: FitCoreSpace.x2,
          vertical: FitCoreSpace.x2,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              formatDayHeadline(_day, compact: phone),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(width: FitCoreSpace.x1),
            Icon(Icons.expand_more, size: 18, color: t.textSecondary),
          ],
        ),
      ),
    );

    final count = FitCountBadge(
      count: dayVisitCount,
      noun: phone ? null : (dayVisitCount == 1 ? 'visit' : 'visits'),
    );

    if (phone) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              stepper,
              const SizedBox(width: FitCoreSpace.x2),
              Expanded(child: dayPicker),
              today,
              count,
            ],
          ),
          const SizedBox(height: FitCoreSpace.x2),
          Row(
            children: [
              record,
              const Spacer(),
              schedule,
            ],
          ),
        ],
      );
    }

    return Row(
      children: [
        stepper,
        const SizedBox(width: FitCoreSpace.x2),
        today,
        const SizedBox(width: FitCoreSpace.x2),
        dayPicker,
        const SizedBox(width: FitCoreSpace.x2),
        count,
        const Spacer(),
        record,
        const SizedBox(width: FitCoreSpace.x2),
        schedule,
      ],
    );
  }

  Widget _buildBody() {
    if (_controller.isLoading) {
      return const Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (_controller.error != null) {
      return FitErrorState(
        message: _controller.error!,
        onRetry: () => _controller.load(day: _day),
      );
    }

    final coach = _focusedCoach;
    if (coach != null) {
      return CoachCalendar(
        coach: coach,
        visits: _controller.visits,
        initialDay: _day,
        onVisitTap: _onVisitTap,
        onBack: _backToDayBoard,
        onRangeChanged: _onCoachCalendarRange,
        onSlotTap: _onSlotTap,
      );
    }

    return CoachDayBoard(
      visits: _controller.visits,
      staff: _controller.staff,
      day: _day,
      onDayChanged: _onBoardDayChanged,
      onVisitTap: _onVisitTap,
      onCoachTap: (selected) => setState(() => _focusedCoach = selected),
      onSlotTap: _onSlotTap,
      showToolbar: false,
    );
  }
}
