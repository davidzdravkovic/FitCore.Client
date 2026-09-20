import 'package:fitcore_client/core/time/tenant_clock.dart';
import 'package:fitcore_client/features/tenant/staff/models/staff_response.dart';
import 'package:fitcore_client/features/tenant/visits/models/visit_response.dart';
import 'package:fitcore_client/features/tenant/visits/visit_calendar_range.dart';
import 'package:fitcore_client/features/tenant/visits/widgets/visit_display.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

/// One coach, day/week/month. Opened by tapping a column on the day board.
class CoachCalendar extends StatefulWidget {
  const CoachCalendar({
    super.key,
    required this.coach,
    required this.visits,
    required this.initialDay,
    required this.onVisitTap,
    required this.onBack,
    required this.onRangeChanged,
    this.onSlotTap,
  });

  final StaffResponse coach;
  final List<VisitResponse> visits;
  final DateTime initialDay;
  final ValueChanged<VisitResponse> onVisitTap;
  final VoidCallback onBack;

  /// Local `[from, to)` for the visible day/week/month; parent refetches visits.
  final void Function(VisitCalendarRange range, DateTime focusDay)
      onRangeChanged;

  /// Empty day/week cell — same schedule-vs-record rules as the multi-coach board.
  final void Function(StaffResponse coach, DateTime start)? onSlotTap;

  @override
  State<CoachCalendar> createState() => _CoachCalendarState();
}

class _CoachCalendarState extends State<CoachCalendar> {
  final CalendarController _controller = CalendarController();
  VisitCalendarRange? _lastNotified;

  @override
  void initState() {
    super.initState();
    _controller.view = CalendarView.week;
    _controller.displayDate = widget.initialDay;
    // Initial week window (default view) so parent can load before first paint.
    WidgetsBinding.instance.addPostFrameCallback((_) => _emitRange());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  VisitCalendarRange _rangeFor(CalendarView view, DateTime focus) {
    return switch (view) {
      CalendarView.day => VisitCalendarRange.day(focus),
      CalendarView.month => VisitCalendarRange.month(focus),
      _ => VisitCalendarRange.week(focus),
    };
  }

  void _emitRange() {
    if (!mounted) return;
    final view = _controller.view ?? CalendarView.week;
    final focus = VisitCalendarRange.dayStart(
      _controller.displayDate ?? widget.initialDay,
    );
    final range = _rangeFor(view, focus);
    if (_lastNotified != null &&
        _lastNotified!.from == range.from &&
        _lastNotified!.to == range.to) {
      return;
    }
    _lastNotified = range;
    widget.onRangeChanged(range, focus);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final coachName =
        '${widget.coach.firstName} ${widget.coach.lastName}'.trim();
    final coachVisits = widget.visits
        .where((visit) => visit.coachStaffId == widget.coach.id)
        .toList();
    final byId = {for (final visit in coachVisits) visit.id: visit};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: widget.onBack,
              icon: const Icon(Icons.arrow_back),
              tooltip: 'Back to all coaches',
            ),
            const SizedBox(width: 4),
            Text(
              coachName,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 8),
            Text(
              coachVisits.length == 1
                  ? '1 visit'
                  : '${coachVisits.length} visits',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: SfCalendar(
              controller: _controller,
              firstDayOfWeek: DateTime.monday,
              allowedViews: const [
                CalendarView.day,
                CalendarView.week,
                CalendarView.month,
              ],
              showNavigationArrow: true,
              showDatePickerButton: true,
              dataSource: _CoachDataSource(coachVisits),
              timeSlotViewSettings: const TimeSlotViewSettings(
                startHour: 6,
                endHour: 22,
                timeIntervalHeight: 64,
              ),
              monthViewSettings: const MonthViewSettings(
                appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
              ),
              onViewChanged: (_) {
                // Syncfusion fires during layout; defer so parent can setState.
                WidgetsBinding.instance.addPostFrameCallback((_) => _emitRange());
              },
              onTap: (details) {
                // Month cell → open that day for this coach.
                if (_controller.view == CalendarView.month &&
                    details.targetElement == CalendarElement.calendarCell &&
                    details.date != null) {
                  final day = VisitCalendarRange.dayStart(details.date!);
                  _controller.view = CalendarView.day;
                  _controller.displayDate = day;
                  _lastNotified = null;
                  WidgetsBinding.instance
                      .addPostFrameCallback((_) => _emitRange());
                  return;
                }

                final tapped = details.appointments;
                if (tapped != null && tapped.isNotEmpty) {
                  final appointment = tapped.first;
                  if (appointment is! Appointment) return;
                  final visit = byId[appointment.id?.toString()];
                  if (visit == null) return;
                  widget.onVisitTap(visit);
                  return;
                }

                // Empty day/week slot → schedule or record (same rules as board).
                final slot = details.date;
                final view = _controller.view;
                final slottable = view == CalendarView.day ||
                    view == CalendarView.week ||
                    view == CalendarView.workWeek;
                if (slot == null || !slottable || widget.onSlotTap == null) {
                  return;
                }
                widget.onSlotTap!(
                  widget.coach,
                  DateTime(
                    slot.year,
                    slot.month,
                    slot.day,
                    slot.hour,
                    slot.minute,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _CoachDataSource extends CalendarDataSource {
  _CoachDataSource(List<VisitResponse> visits) {
    appointments = [
      for (final visit in visits)
        Appointment(
          id: visit.id,
          startTime: TenantClock.toTenant(visit.startAt),
          endTime: TenantClock.toTenant(visit.endAt),
          subject: '${visit.memberName} · ${visit.serviceName}',
          color: visitStatusColor(visit.status),
        ),
    ];
  }
}
