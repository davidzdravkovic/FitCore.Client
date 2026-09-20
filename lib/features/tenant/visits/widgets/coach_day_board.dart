import 'dart:math' as math;

import 'package:fitcore_client/core/theme/fitcore_tokens.dart';
import 'package:fitcore_client/core/time/tenant_clock.dart';
import 'package:fitcore_client/core/widgets/fit_page_header.dart';
import 'package:fitcore_client/core/widgets/fit_panel_states.dart';
import 'package:fitcore_client/features/tenant/staff/models/staff_response.dart';
import 'package:fitcore_client/features/tenant/visits/layout/coach_day_board_layout.dart';
import 'package:fitcore_client/features/tenant/visits/models/visit_response.dart';
import 'package:fitcore_client/features/tenant/visits/widgets/visit_display.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Day board: one column per coach, time running down the rows.
///
/// Syncfusion only renders resources as timeline rows, so the column layout
/// every booking tool uses (Google resource time-grid, Mindbody day view) is
/// built here directly. Layout math lives in [CoachDayBoardLayout].
class CoachDayBoard extends StatefulWidget {
  const CoachDayBoard({
    super.key,
    required this.visits,
    required this.staff,
    required this.day,
    required this.onDayChanged,
    required this.onVisitTap,
    required this.onCoachTap,
    this.onSlotTap,
    this.showToolbar = true,
  });

  final List<VisitResponse> visits;
  final List<StaffResponse> staff;
  final DateTime day;
  final ValueChanged<DateTime> onDayChanged;
  final ValueChanged<VisitResponse> onVisitTap;
  final ValueChanged<StaffResponse> onCoachTap;
  final void Function(StaffResponse coach, DateTime start)? onSlotTap;

  /// When false, the parent owns day navigation (single command row).
  final bool showToolbar;

  @override
  State<CoachDayBoard> createState() => _CoachDayBoardState();
}

class _CoachDayBoardState extends State<CoachDayBoard> {
  final ScrollController _headerScroll = ScrollController();
  final ScrollController _laneScroll = ScrollController();
  final ScrollController _verticalScroll = ScrollController();
  final ScrollController _rulerScroll = ScrollController();

  bool _syncing = false;
  bool _restoredScroll = false;

  @override
  void initState() {
    super.initState();
    _headerScroll.addListener(() => _mirror(_headerScroll, _laneScroll));
    _laneScroll.addListener(() => _mirror(_laneScroll, _headerScroll));
    _verticalScroll.addListener(() => _mirror(_verticalScroll, _rulerScroll));
    _rulerScroll.addListener(() => _mirror(_rulerScroll, _verticalScroll));
  }

  @override
  void dispose() {
    _headerScroll.dispose();
    _laneScroll.dispose();
    _verticalScroll.dispose();
    _rulerScroll.dispose();
    super.dispose();
  }

  /// Header↔lanes (horizontal) and ruler↔body (vertical) are separate viewports
  /// so the time ruler and coach headers stay pinned.
  void _mirror(ScrollController source, ScrollController target) {
    if (_syncing || !target.hasClients || !source.hasClients) return;
    if (target.offset == source.offset) return;
    _syncing = true;
    target.jumpTo(source.offset);
    _syncing = false;
  }

  void _restoreScrollOnce(int firstHour, List<VisitResponse> dayVisits) {
    if (_restoredScroll) return;
    _restoredScroll = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_verticalScroll.hasClients) return;
      final anchor = dayVisits.isEmpty
          ? 8.0
          : TenantClock.toTenant(dayVisits.first.startAt).hour.toDouble();
      final target =
          (anchor - firstHour - 0.5) * CoachDayBoardMetrics.hourHeight;
      _verticalScroll.jumpTo(
        target.clamp(0.0, _verticalScroll.position.maxScrollExtent),
      );
    });
  }

  Future<void> _pickDay() async {
    final now = TenantClock.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.day,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    widget.onDayChanged(DateTime(picked.year, picked.month, picked.day));
  }

  void _shiftDay(int days) {
    final next = widget.day.add(Duration(days: days));
    widget.onDayChanged(DateTime(next.year, next.month, next.day));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dayVisits = CoachDayBoardLayout.visitsForDay(
      visits: widget.visits,
      day: widget.day,
    );
    final lanes = CoachDayBoardLayout.lanes(
      staff: widget.staff,
      dayVisits: dayVisits,
    );
    final (firstHour, lastHour) = CoachDayBoardLayout.hourWindow(dayVisits);
    final gridHeight = (lastHour - firstHour) * CoachDayBoardMetrics.hourHeight;

    _restoreScrollOnce(firstHour, dayVisits);

    final compact =
        MediaQuery.sizeOf(context).width < FitCoreBreakpoints.compact;

    final grid = lanes.isEmpty
        ? _buildEmptyState()
        : _buildGrid(
            theme,
            lanes,
            dayVisits,
            firstHour,
            lastHour,
            gridHeight,
          );

    if (!widget.showToolbar) return grid;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildToolbar(context, dayVisits.length),
        SizedBox(height: compact ? FitCoreSpace.x2 : FitCoreSpace.x3),
        Expanded(child: grid),
      ],
    );
  }

  Widget _buildToolbar(BuildContext context, int visitCount) {
    final theme = Theme.of(context);
    final t = context.fc;
    final isToday = isSameDay(widget.day, TenantClock.now());
    final compact =
        MediaQuery.sizeOf(context).width < FitCoreBreakpoints.compact;

    final stepper = Container(
      decoration: BoxDecoration(
        color: t.panel,
        borderRadius: BorderRadius.circular(FitCoreRadius.md),
        border: Border.all(color: t.borderDefault),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(
            icon: Icons.chevron_left,
            tooltip: 'Previous day',
            onPressed: () => _shiftDay(-1),
          ),
          Container(width: 1, height: 22, color: t.borderSubtle),
          _StepButton(
            icon: Icons.chevron_right,
            tooltip: 'Next day',
            onPressed: () => _shiftDay(1),
          ),
        ],
      ),
    );

    final today = compact
        ? IconButton(
            onPressed: isToday
                ? null
                : () {
                    final now = TenantClock.now();
                    widget.onDayChanged(DateTime(now.year, now.month, now.day));
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
                    widget.onDayChanged(DateTime(now.year, now.month, now.day));
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
            Flexible(
              child: Text(
                formatDayHeadline(widget.day, compact: compact),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall,
              ),
            ),
            const SizedBox(width: FitCoreSpace.x1),
            Icon(Icons.expand_more, size: 18, color: t.textSecondary),
          ],
        ),
      ),
    );

    final count = FitCountBadge(
      count: visitCount,
      noun: compact
          ? null
          : (visitCount == 1 ? 'visit' : 'visits'),
    );

    if (compact) {
      return Row(
        children: [
          stepper,
          const SizedBox(width: FitCoreSpace.x2),
          Expanded(child: dayPicker),
          const SizedBox(width: FitCoreSpace.x1),
          today,
          const SizedBox(width: FitCoreSpace.x2),
          count,
        ],
      );
    }

    return Row(
      children: [
        stepper,
        const SizedBox(width: FitCoreSpace.x2),
        today,
        const SizedBox(width: FitCoreSpace.x2),
        Flexible(child: dayPicker),
        const SizedBox(width: FitCoreSpace.x3),
        count,
      ],
    );
  }

  Widget _buildEmptyState() {
    return const FitEmptyState(
      icon: Icons.badge_outlined,
      title: 'No coaches to show',
      message: 'Add staff before scheduling — coaches form the columns of this board.',
    );
  }

  Widget _buildGrid(
    ThemeData theme,
    List<CoachDayLane> lanes,
    List<VisitResponse> dayVisits,
    int firstHour,
    int lastHour,
    double gridHeight,
  ) {
    final t = context.fc;

    return LayoutBuilder(
      builder: (context, constraints) {
        final laneWidth = CoachDayBoardLayout.laneWidth(
          viewportWidth: constraints.maxWidth,
          laneCount: lanes.length,
        );
        final gridWidth = laneWidth * lanes.length;
        final viewport = math.max(
          0.0,
          constraints.maxWidth - CoachDayBoardMetrics.rulerWidth,
        );
        final overflowsHorizontally = gridWidth > viewport + 0.5;

        // Web/desktop: wheel is vertical-only by default; allow click-drag and
        // show a thumb so clipped coach columns are discoverable.
        final horizontalPhysics = overflowsHorizontally
            ? const AlwaysScrollableScrollPhysics()
            : const ClampingScrollPhysics();

        return ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            scrollbars: false,
            dragDevices: {
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
              PointerDeviceKind.trackpad,
              PointerDeviceKind.stylus,
            },
          ),
          child: Container(
            decoration: BoxDecoration(
              color: t.panel,
              border: Border.all(color: t.borderSubtle),
              borderRadius: BorderRadius.circular(FitCoreRadius.lg),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                SizedBox(
                  height: CoachDayBoardMetrics.headerHeight,
                  child: Row(
                    children: [
                      SizedBox(
                        width: CoachDayBoardMetrics.rulerWidth,
                        child: _headerCorner(context),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          controller: _headerScroll,
                          scrollDirection: Axis.horizontal,
                          physics: horizontalPhysics,
                          child: SizedBox(
                            width: gridWidth,
                            child: Row(
                              children: [
                                for (final lane in lanes)
                                  _buildLaneHeader(
                                    context,
                                    lane,
                                    laneWidth,
                                    dayVisits,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  // Horizontal scroll is the outer viewport so its scrollbar
                  // stays pinned to the visible bottom (not under the last hour).
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        width: CoachDayBoardMetrics.rulerWidth,
                        // No scrollbar here — one vertical thumb on the right only.
                        child: SingleChildScrollView(
                          controller: _rulerScroll,
                          child: SizedBox(
                            height: gridHeight,
                            child: _buildRuler(context, firstHour, lastHour),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Scrollbar(
                          controller: _laneScroll,
                          thumbVisibility: overflowsHorizontally,
                          scrollbarOrientation: ScrollbarOrientation.bottom,
                          child: SingleChildScrollView(
                            controller: _laneScroll,
                            scrollDirection: Axis.horizontal,
                            physics: horizontalPhysics,
                            child: SizedBox(
                              width: gridWidth,
                              child: Scrollbar(
                                controller: _verticalScroll,
                                thumbVisibility: true,
                                child: SingleChildScrollView(
                                  controller: _verticalScroll,
                                  child: SizedBox(
                                    height: gridHeight,
                                    child: Stack(
                                      children: [
                                        Row(
                                          children: [
                                            for (final lane in lanes)
                                              _buildLane(
                                                context,
                                                lane,
                                                dayVisits,
                                                laneWidth,
                                                firstHour,
                                                lastHour,
                                              ),
                                          ],
                                        ),
                                        ..._buildNowIndicator(
                                          context,
                                          firstHour,
                                          lastHour,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _headerCorner(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.fc;

    return Container(
      alignment: Alignment.bottomRight,
      padding: const EdgeInsets.only(right: 10, bottom: FitCoreSpace.x2),
      decoration: BoxDecoration(
        color: t.canvas,
        border: Border(bottom: BorderSide(color: t.borderDefault)),
      ),
      child: Text(
        'TIME',
        style: theme.textTheme.labelSmall?.copyWith(
          color: t.textMuted,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.6,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildLaneHeader(
    BuildContext context,
    CoachDayLane lane,
    double width,
    List<VisitResponse> dayVisits,
  ) {
    final theme = Theme.of(context);
    final t = context.fc;
    final count = CoachDayBoardLayout.visitsInLane(
      dayVisits: dayVisits,
      lane: lane,
      staff: widget.staff,
    ).length;
    final initials = CoachDayBoardLayout.initialsOf(lane.name);
    final tappable = lane.staff != null;

    return SizedBox(
      width: width,
      child: Material(
        color: t.canvas,
        child: InkWell(
          onTap: tappable ? () => widget.onCoachTap(lane.staff!) : null,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: t.borderDefault),
                right: BorderSide(color: t.borderSubtle),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: FitCoreSpace.x3),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: t.elevated,
                    borderRadius: BorderRadius.circular(FitCoreRadius.sm),
                    border: Border.all(color: t.borderDefault),
                  ),
                  child: Text(
                    initials,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: t.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: FitCoreSpace.x2),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lane.name.isEmpty ? 'Unassigned' : lane.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall,
                      ),
                      Text(
                        count == 1 ? '1 visit' : '$count visits',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: t.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                if (tappable)
                  Icon(Icons.north_east, size: 14, color: t.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRuler(BuildContext context, int firstHour, int lastHour) {
    final theme = Theme.of(context);
    final t = context.fc;

    return Container(
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: t.borderSubtle)),
      ),
      child: Column(
        children: [
          for (var hour = firstHour; hour < lastHour; hour++)
            SizedBox(
              height: CoachDayBoardMetrics.hourHeight,
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 10, top: 2),
                  child: Text(
                    formatHourLabel(hour),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: t.textMuted,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLane(
    BuildContext context,
    CoachDayLane lane,
    List<VisitResponse> dayVisits,
    double width,
    int firstHour,
    int lastHour,
  ) {
    final laneVisits = CoachDayBoardLayout.visitsInLane(
      dayVisits: dayVisits,
      lane: lane,
      staff: widget.staff,
    );
    final placements = CoachDayBoardLayout.placeOverlaps(laneVisits);
    final gridHeight = (lastHour - firstHour) * CoachDayBoardMetrics.hourHeight;
    final coach = lane.staff;
    final t = context.fc;

    return SizedBox(
      width: width,
      height: gridHeight,
      child: Stack(
        children: [
          Column(
            children: [
              for (var hour = firstHour; hour < lastHour; hour++)
                SizedBox(
                  height: CoachDayBoardMetrics.hourHeight,
                  child: InkWell(
                    onTap: (coach == null || widget.onSlotTap == null)
                        ? null
                        : () => widget.onSlotTap!(
                            coach,
                            DateTime(
                              widget.day.year,
                              widget.day.month,
                              widget.day.day,
                              hour,
                            ),
                          ),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: t.borderSubtle),
                          right: BorderSide(color: t.borderSubtle),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          for (final placement in placements)
            _buildVisitBlock(Theme.of(context), placement, width, firstHour),
        ],
      ),
    );
  }

  Widget _buildVisitBlock(
    ThemeData theme,
    CoachDayPlacement placement,
    double laneWidth,
    int firstHour,
  ) {
    final visit = placement.visit;
    final geometry = CoachDayBoardLayout.visitGeometry(
      placement: placement,
      laneWidth: laneWidth,
      firstHour: firstHour,
    );

    return Positioned(
      top: geometry.top,
      left: geometry.left,
      width: geometry.width,
      height: geometry.height,
      child: _VisitBlock(
        visit: visit,
        onTap: () => widget.onVisitTap(visit),
        theme: theme,
      ),
    );
  }

  List<Widget> _buildNowIndicator(
    BuildContext context,
    int firstHour,
    int lastHour,
  ) {
    final offset = CoachDayBoardLayout.nowLineOffset(
      day: widget.day,
      firstHour: firstHour,
      lastHour: lastHour,
    );
    if (offset == null) return const [];

    final now = context.fc.stateNegative;

    return [
      Positioned(
        top: offset - 3,
        left: 0,
        right: 0,
        child: Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: now, shape: BoxShape.circle),
            ),
            Expanded(child: Divider(color: now, thickness: 1)),
          ],
        ),
      ),
    ];
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 38,
      height: 38,
      child: IconButton(
        onPressed: onPressed,
        tooltip: tooltip,
        padding: EdgeInsets.zero,
        iconSize: 18,
        icon: Icon(icon),
      ),
    );
  }
}

class _VisitBlock extends StatelessWidget {
  const _VisitBlock({
    required this.visit,
    required this.onTap,
    required this.theme,
  });

  final VisitResponse visit;
  final VoidCallback onTap;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final t = context.fc;
    final tone = visitToneOf(visit.status);
    final color = tone.color;
    final range = '${formatClock(visit.startAt)} – ${formatClock(visit.endAt)}';

    return Tooltip(
      waitDuration: const Duration(milliseconds: 400),
      message:
          '${visit.memberName}\n'
          '${visit.serviceName}\n'
          '$range · ${tone.label}\n'
          'Coach ${visit.coachName}',
      child: Material(
        color: Color.alphaBlend(
          color.withValues(alpha: tone.isRetired ? 0.07 : 0.14),
          t.panel,
        ),
        borderRadius: BorderRadius.circular(FitCoreRadius.sm),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(FitCoreRadius.sm),
              border: Border.all(
                color: color.withValues(alpha: tone.isRetired ? 0.35 : 0.6),
              ),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxHeight < 54;

                return Row(
                  children: [
                    Container(width: 3, color: color),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: FitCoreSpace.x2,
                          vertical: compact ? 3 : FitCoreSpace.x1 + 2,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              compact ? '$range · ${visit.memberName}' : range,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: t.textSecondary,
                                fontWeight: FontWeight.w500,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                            if (!compact) ...[
                              const SizedBox(height: 1),
                              Text(
                                visit.memberName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.labelLarge?.copyWith(
                                  decoration: tone.isRetired
                                      ? TextDecoration.lineThrough
                                      : null,
                                  decorationColor: t.textMuted,
                                ),
                              ),
                              Flexible(
                                child: Text(
                                  visit.serviceName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: t.textMuted,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
