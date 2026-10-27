import 'package:fitcore_client/core/theme/fitcore_tokens.dart';
import 'package:fitcore_client/core/time/tenant_clock.dart';
import 'package:fitcore_client/core/widgets/fit_page_header.dart';
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
    required this.visits,
    required this.initialDay,
    required this.onVisitTap,
    required this.onRangeChanged,
    this.coach,
    this.onBack,
    this.onSlotTap,
  });

  /// When null, every visit in [visits] is shown (member self-view).
  final StaffResponse? coach;
  final List<VisitResponse> visits;
  final DateTime initialDay;
  final ValueChanged<VisitResponse> onVisitTap;

  /// Tenant day-board drill-in. Omitted on staff/member portals.
  final VoidCallback? onBack;

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
  bool _appliedCompactDefault = false;

  static const _views = [
    CalendarView.day,
    CalendarView.week,
    CalendarView.month,
  ];

  @override
  void initState() {
    super.initState();
    _controller.view = CalendarView.week;
    _controller.displayDate = widget.initialDay;
    WidgetsBinding.instance.addPostFrameCallback((_) => _emitRange());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_appliedCompactDefault) return;
    final phone =
        MediaQuery.sizeOf(context).width < FitCoreBreakpoints.compact;
    if (phone) {
      _controller.view = CalendarView.day;
    }
    _appliedCompactDefault = true;
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

  /// Syncfusion keeps blue slot rings after tap; we only use [onTap] for actions.
  void _clearCalendarCellSelection() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_controller.selectedDate != null) {
        _controller.selectedDate = null;
      }
    });
  }

  void _setView(CalendarView view) {
    if (_controller.view == view) return;
    setState(() => _controller.view = view);
    _lastNotified = null;
    _emitRange();
  }

  void _shift(int step) {
    final forward = _controller.forward;
    final backward = _controller.backward;
    if (step > 0) {
      forward?.call();
    } else {
      backward?.call();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
      _emitRange();
    });
  }

  Future<void> _pickDate() async {
    final now = TenantClock.now();
    final current = _controller.displayDate ?? widget.initialDay;
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(() {
      _controller.displayDate = DateTime(picked.year, picked.month, picked.day);
    });
    _lastNotified = null;
    _emitRange();
  }

  String _headerLabel() {
    final day = _controller.displayDate ?? widget.initialDay;
    final view = _controller.view ?? CalendarView.week;
    if (view == CalendarView.day) {
      return formatDayHeadline(day, compact: true);
    }
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[day.month - 1]} ${day.year}';
  }

  String _viewLabel(CalendarView view) => switch (view) {
        CalendarView.day => 'Day',
        CalendarView.month => 'Month',
        _ => 'Week',
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.fc;
    final coach = widget.coach;
    final coachName = coach == null
        ? null
        : '${coach.firstName} ${coach.lastName}'.trim();
    final coachVisits = coach == null
        ? widget.visits
        : widget.visits
            .where((visit) => visit.coachStaffId == coach.id)
            .toList();
    final byId = {for (final visit in coachVisits) visit.id: visit};
    final activeView = _controller.view ?? CalendarView.week;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _CoachChrome(
          coachName: coachName,
          visitCount: coachVisits.length,
          headerLabel: _headerLabel(),
          activeView: activeView,
          views: _views,
          viewLabel: _viewLabel,
          onBack: widget.onBack,
          onPrev: () => _shift(-1),
          onNext: () => _shift(1),
          onPickDate: _pickDate,
          onSetView: _setView,
        ),
        const SizedBox(height: FitCoreSpace.x1),
        Expanded(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: t.panel,
              border: Border.all(color: t.borderDefault),
              borderRadius: BorderRadius.circular(FitCoreRadius.lg),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(FitCoreRadius.lg),
              child: SfCalendar(
                backgroundColor: t.panel,
                cellBorderColor: t.borderSubtle.withValues(alpha: 0.85),
                todayHighlightColor: t.accent,
                todayTextStyle: theme.textTheme.labelMedium?.copyWith(
                  color: t.onAccent,
                  fontWeight: FontWeight.w700,
                ),
                selectionDecoration: const BoxDecoration(),
                headerHeight: 0,
                showNavigationArrow: false,
                showDatePickerButton: false,
                // Day view: chrome already shows the date; Syncfusion's day
                // header sits over the time ruler and overlaps when scrolling.
                viewHeaderHeight:
                    activeView == CalendarView.day ? 0.0 : 52.0,
                viewHeaderStyle: ViewHeaderStyle(
                  backgroundColor: t.canvas,
                  dayTextStyle: theme.textTheme.labelSmall?.copyWith(
                    color: t.textSecondary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                  ),
                  dateTextStyle: theme.textTheme.titleSmall?.copyWith(
                    color: t.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                appointmentTextStyle: theme.textTheme.labelSmall!.copyWith(
                  color: t.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                controller: _controller,
                firstDayOfWeek: DateTime.monday,
                dataSource: _CoachDataSource(coachVisits),
                // Day/week only — month draws visits inside monthCellBuilder.
                appointmentBuilder: (context, details) {
                  if (activeView == CalendarView.month) {
                    return const SizedBox.shrink();
                  }

                  final raw = details.appointments.isEmpty
                      ? null
                      : details.appointments.first;
                  if (raw is! Appointment) {
                    return const SizedBox.shrink();
                  }
                  final visit = byId[raw.id?.toString()];
                  if (visit == null) {
                    return const SizedBox.shrink();
                  }

                  return _AppointmentCard(
                    visit: visit,
                    bounds: details.bounds,
                  );
                },
                monthCellBuilder: (context, details) {
                  final dayStart = VisitCalendarRange.dayStart(details.date);
                  final dayEnd = dayStart.add(const Duration(days: 1));
                  final dayVisits = coachVisits.where((visit) {
                    final start = TenantClock.toTenant(visit.startAt);
                    return !start.isBefore(dayStart) && start.isBefore(dayEnd);
                  }).toList()
                    ..sort((a, b) => a.startAt.compareTo(b.startAt));

                  final visibleMonth =
                      (_controller.displayDate ?? widget.initialDay).month;
                  final inMonth = details.date.month == visibleMonth;

                  return _MonthDayCell(
                    date: details.date,
                    visits: dayVisits,
                    inMonth: inMonth,
                    onVisitTap: widget.onVisitTap,
                  );
                },
                timeSlotViewSettings: TimeSlotViewSettings(
                  startHour: 6,
                  endHour: 22,
                  timeIntervalHeight:
                      MediaQuery.sizeOf(context).width <
                              FitCoreBreakpoints.compact
                          ? 52
                          : 58,
                  timeRulerSize:
                      MediaQuery.sizeOf(context).width <
                              FitCoreBreakpoints.compact
                          ? 48
                          : 56,
                  timeTextStyle: theme.textTheme.labelSmall?.copyWith(
                    color: t.textSecondary,
                    fontWeight: FontWeight.w500,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                monthViewSettings: MonthViewSettings(
                  // Visits are drawn in monthCellBuilder so text stays readable.
                  appointmentDisplayMode: MonthAppointmentDisplayMode.none,
                  monthCellStyle: MonthCellStyle(
                    backgroundColor: t.panel,
                    trailingDatesBackgroundColor: t.canvas,
                    leadingDatesBackgroundColor: t.canvas,
                    textStyle: theme.textTheme.bodySmall?.copyWith(
                      color: t.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    trailingDatesTextStyle: theme.textTheme.bodySmall?.copyWith(
                      color: t.textMuted,
                    ),
                    leadingDatesTextStyle: theme.textTheme.bodySmall?.copyWith(
                      color: t.textMuted,
                    ),
                  ),
                ),
                onViewChanged: (_) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) setState(() {});
                    _emitRange();
                  });
                },
                onSelectionChanged: (_) => _clearCalendarCellSelection(),
                onTap: (details) {
                  try {
                    if (_controller.view == CalendarView.month &&
                        details.targetElement == CalendarElement.calendarCell &&
                        details.date != null) {
                      final day = VisitCalendarRange.dayStart(details.date!);
                      _controller.view = CalendarView.day;
                      _controller.displayDate = day;
                      _lastNotified = null;
                      WidgetsBinding.instance.addPostFrameCallback(
                        (_) => _emitRange(),
                      );
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

                    final slot = details.date;
                    final view = _controller.view;
                    final slottable =
                        view == CalendarView.day ||
                        view == CalendarView.week ||
                        view == CalendarView.workWeek;
                    if (slot == null ||
                        !slottable ||
                        widget.onSlotTap == null ||
                        coach == null) {
                      return;
                    }
                    widget.onSlotTap!(
                      coach,
                      DateTime(
                        slot.year,
                        slot.month,
                        slot.day,
                        slot.hour,
                        slot.minute,
                      ),
                    );
                  } finally {
                    _clearCalendarCellSelection();
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CoachChrome extends StatelessWidget {
  const _CoachChrome({
    required this.coachName,
    required this.visitCount,
    required this.headerLabel,
    required this.activeView,
    required this.views,
    required this.viewLabel,
    required this.onBack,
    required this.onPrev,
    required this.onNext,
    required this.onPickDate,
    required this.onSetView,
  });

  final String? coachName;
  final int visitCount;
  final String headerLabel;
  final CalendarView activeView;
  final List<CalendarView> views;
  final String Function(CalendarView) viewLabel;
  final VoidCallback? onBack;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onPickDate;
  final ValueChanged<CalendarView> onSetView;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.fc;

    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < FitCoreBreakpoints.compact;

        final showIdentity = onBack != null;
        final badge = FitCountBadge(
          count: visitCount,
          noun: visitCount == 1 ? 'visit' : 'visits',
        );

        final identity = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 32,
              height: 32,
              child: IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back, size: 18),
                padding: EdgeInsets.zero,
                tooltip: 'Back to all coaches',
              ),
            ),
            const SizedBox(width: FitCoreSpace.x1),
            if (coachName != null && coachName!.isNotEmpty) ...[
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 140),
                child: Text(
                  coachName!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: FitCoreSpace.x2),
            ],
            badge,
          ],
        );

        final datePicker = InkWell(
          onTap: onPickDate,
          borderRadius: BorderRadius.circular(FitCoreRadius.sm),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: FitCoreSpace.x2,
              vertical: narrow ? 4 : FitCoreSpace.x1,
            ),
            child: Row(
              mainAxisSize: narrow ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment:
                  narrow ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                if (narrow)
                  Flexible(
                    child: Text(
                      headerLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else
                  Text(
                    headerLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                const SizedBox(width: 2),
                Icon(
                  Icons.expand_more,
                  size: 16,
                  color: t.textSecondary,
                ),
              ],
            ),
          ),
        );

        final viewSwitcher = _ViewSwitcher(
          views: views,
          activeView: activeView,
          viewLabel: viewLabel,
          onSetView: onSetView,
          compact: true,
          stretch: narrow,
        );

        if (narrow) {
          // Date gets the full width between arrows; views sit on the next
          // thin row so "Mon 5 Oct" is never crushed by Day/Week/Month.
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (showIdentity) ...[
                identity,
                const SizedBox(height: FitCoreSpace.x1),
              ],
              Row(
                children: [
                  _NavButton(
                    icon: Icons.chevron_left,
                    tooltip: 'Previous',
                    onPressed: onPrev,
                    compact: true,
                  ),
                  Expanded(child: datePicker),
                  _NavButton(
                    icon: Icons.chevron_right,
                    tooltip: 'Next',
                    onPressed: onNext,
                    compact: true,
                  ),
                ],
              ),
              const SizedBox(height: FitCoreSpace.x1),
              Row(
                children: [
                  Expanded(child: viewSwitcher),
                  if (!showIdentity) ...[
                    const SizedBox(width: FitCoreSpace.x2),
                    badge,
                  ],
                ],
              ),
            ],
          );
        }

        // One left-aligned chrome strip: back/coach → date → Day/Week/Month.
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              if (showIdentity) ...[
                identity,
                const SizedBox(width: FitCoreSpace.x3),
              ] else ...[
                badge,
                const SizedBox(width: FitCoreSpace.x3),
              ],
              _NavButton(
                icon: Icons.chevron_left,
                tooltip: 'Previous',
                onPressed: onPrev,
                compact: true,
              ),
              const SizedBox(width: FitCoreSpace.x1),
              datePicker,
              const SizedBox(width: FitCoreSpace.x1),
              _NavButton(
                icon: Icons.chevron_right,
                tooltip: 'Next',
                onPressed: onNext,
                compact: true,
              ),
              const SizedBox(width: FitCoreSpace.x3),
              viewSwitcher,
            ],
          ),
        );
      },
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.compact = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final t = context.fc;
    final size = compact ? 32.0 : 40.0;
    return Material(
      color: t.elevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FitCoreRadius.sm),
        side: BorderSide(color: t.borderSubtle),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(FitCoreRadius.sm),
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, size: compact ? 16 : 18, color: t.textSecondary),
        ),
      ),
    );
  }
}

class _ViewSwitcher extends StatelessWidget {
  const _ViewSwitcher({
    required this.views,
    required this.activeView,
    required this.viewLabel,
    required this.onSetView,
    this.compact = false,
    this.stretch = false,
  });

  final List<CalendarView> views;
  final CalendarView activeView;
  final String Function(CalendarView) viewLabel;
  final ValueChanged<CalendarView> onSetView;
  final bool compact;
  final bool stretch;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.fc;

    Widget chip(CalendarView view) {
      return Material(
        color: activeView == view ? t.accent : Colors.transparent,
        borderRadius: BorderRadius.circular(FitCoreRadius.sm),
        child: InkWell(
          onTap: () => onSetView(view),
          borderRadius: BorderRadius.circular(FitCoreRadius.sm),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? FitCoreSpace.x2 : FitCoreSpace.x3,
              vertical: compact ? 5 : FitCoreSpace.x2,
            ),
            child: Center(
              child: Text(
                viewLabel(view),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: activeView == view ? t.onAccent : t.textSecondary,
                  fontWeight:
                      activeView == view ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      width: stretch ? double.infinity : null,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: t.canvas,
        borderRadius: BorderRadius.circular(FitCoreRadius.sm),
        border: Border.all(color: t.borderDefault),
      ),
      child: Row(
        mainAxisSize: stretch ? MainAxisSize.max : MainAxisSize.min,
        children: [
          for (final view in views)
            if (stretch)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  child: chip(view),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: chip(view),
              ),
        ],
      ),
    );
  }
}

/// Month cell: day number top-left, readable visit chips stacked underneath.
class _MonthDayCell extends StatelessWidget {
  const _MonthDayCell({
    required this.date,
    required this.visits,
    required this.inMonth,
    required this.onVisitTap,
  });

  final DateTime date;
  final List<VisitResponse> visits;
  final bool inMonth;
  final ValueChanged<VisitResponse> onVisitTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.fc;
    final now = TenantClock.now();
    final isToday =
        date.year == now.year && date.month == now.month && date.day == now.day;

    return ColoredBox(
      color: inMonth ? t.panel : t.canvas,
      child: ClipRect(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6, 4, 4, 4),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // ~20px per chip; leave room for the day number.
              final chipBudget = (constraints.maxHeight - 28).clamp(0.0, 400.0);
              final maxVisible = chipBudget < 18
                  ? 0
                  : (chipBudget / 20).floor().clamp(0, 6);
              final shown = visits.take(maxVisible).toList();
              final overflow = visits.length - shown.length;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _MonthDayNumber(
                    day: date.day,
                    isToday: isToday,
                    inMonth: inMonth,
                  ),
                  const SizedBox(height: 4),
                  for (final visit in shown)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: _MonthAppointmentChip(
                        visit: visit,
                        onTap: () => onVisitTap(visit),
                      ),
                    ),
                  if (overflow > 0)
                    Padding(
                      padding: const EdgeInsets.only(left: 2, top: 1),
                      child: Text(
                        '+$overflow more',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: t.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _MonthDayNumber extends StatelessWidget {
  const _MonthDayNumber({
    required this.day,
    required this.isToday,
    required this.inMonth,
  });

  final int day;
  final bool isToday;
  final bool inMonth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.fc;
    final style = theme.textTheme.labelLarge?.copyWith(
      color: isToday
          ? t.onAccent
          : inMonth
              ? t.textPrimary
              : t.textMuted,
      fontWeight: FontWeight.w700,
      height: 1,
    );

    if (isToday) {
      return Container(
        width: 26,
        height: 26,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: t.accent,
          shape: BoxShape.circle,
        ),
        child: Text('$day', style: style),
      );
    }

    return SizedBox(
      height: 26,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text('$day', style: style),
      ),
    );
  }
}

/// Month-cell chip: solid status bar + one readable line (time · member).
class _MonthAppointmentChip extends StatelessWidget {
  const _MonthAppointmentChip({
    required this.visit,
    this.onTap,
  });

  final VisitResponse visit;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.fc;
    final tone = visitToneOf(visit.status);
    final color = tone.color;
    final label = '${formatClock(visit.startAt)} ${visit.memberName}';

    return Material(
      color: color.withValues(alpha: tone.isRetired ? 0.45 : 1),
      borderRadius: BorderRadius.circular(FitCoreRadius.xs),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(FitCoreRadius.xs),
        child: SizedBox(
          height: 18,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                label,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: t.onAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 1.1,
                  decoration:
                      tone.isRetired ? TextDecoration.lineThrough : null,
                  decorationColor: t.onAccent.withValues(alpha: 0.7),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({
    required this.visit,
    required this.bounds,
  });

  final VisitResponse visit;
  final Rect bounds;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.fc;
    final tone = visitToneOf(visit.status);
    final color = tone.color;
    final compact = bounds.height < 40;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          color.withValues(alpha: tone.isRetired ? 0.08 : 0.16),
          t.panel,
        ),
        borderRadius: BorderRadius.circular(FitCoreRadius.sm),
        border: Border.all(
          color: color.withValues(alpha: tone.isRetired ? 0.35 : 0.55),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(width: 3, color: color),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: FitCoreSpace.x1 + 2,
                vertical: FitCoreSpace.x1,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    visit.memberName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: t.textPrimary,
                      fontWeight: FontWeight.w700,
                      decoration: tone.isRetired
                          ? TextDecoration.lineThrough
                          : null,
                      decorationColor: t.textMuted,
                    ),
                  ),
                  if (!compact) ...[
                    const SizedBox(height: 1),
                    Text(
                      visit.serviceName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: t.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
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
