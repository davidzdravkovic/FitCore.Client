import 'dart:math' as math;

import 'package:fitcore_client/core/time/tenant_clock.dart';
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
  });

  final List<VisitResponse> visits;
  final List<StaffResponse> staff;
  final DateTime day;
  final ValueChanged<DateTime> onDayChanged;
  final ValueChanged<VisitResponse> onVisitTap;
  final ValueChanged<StaffResponse> onCoachTap;
  final void Function(StaffResponse coach, DateTime start)? onSlotTap;

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
    final gridHeight =
        (lastHour - firstHour) * CoachDayBoardMetrics.hourHeight;

    _restoreScrollOnce(firstHour, dayVisits);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildToolbar(theme, dayVisits.length),
        const SizedBox(height: 12),
        Expanded(
          child: lanes.isEmpty
              ? _buildEmptyState(theme)
              : _buildGrid(theme, lanes, dayVisits, firstHour, lastHour,
                  gridHeight),
        ),
      ],
    );
  }

  Widget _buildToolbar(ThemeData theme, int visitCount) {
    final isToday = isSameDay(widget.day, TenantClock.now());

    return Row(
      children: [
        IconButton(
          onPressed: () => _shiftDay(-1),
          icon: const Icon(Icons.chevron_left),
          tooltip: 'Previous day',
        ),
        IconButton(
          onPressed: () => _shiftDay(1),
          icon: const Icon(Icons.chevron_right),
          tooltip: 'Next day',
        ),
        const SizedBox(width: 4),
        OutlinedButton(
          onPressed: isToday
              ? null
              : () {
                  final now = TenantClock.now();
                  widget.onDayChanged(DateTime(now.year, now.month, now.day));
                },
          child: const Text('Today'),
        ),
        const SizedBox(width: 12),
        InkWell(
          onTap: _pickDay,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  formatDayHeadline(widget.day),
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.arrow_drop_down, size: 20),
              ],
            ),
          ),
        ),
        const Spacer(),
        Text(
          visitCount == 1 ? '1 visit' : '$visitCount visits',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Text(
        'Add staff before scheduling — coaches form the columns of this board.',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
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
    final outline = theme.colorScheme.outlineVariant.withValues(alpha: 0.4);

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
              color: theme.colorScheme.surface,
              border: Border.all(color: outline),
              borderRadius: BorderRadius.circular(12),
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
                        child: _headerCorner(theme),
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
                                      theme, lane, laneWidth, dayVisits),
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
                            child: _buildRuler(theme, firstHour, lastHour),
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
                                                theme,
                                                lane,
                                                dayVisits,
                                                laneWidth,
                                                firstHour,
                                                lastHour,
                                              ),
                                          ],
                                        ),
                                        ..._buildNowIndicator(
                                            theme, firstHour, lastHour),
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

  Widget _headerCorner(ThemeData theme) {
    return Container(
      alignment: Alignment.bottomRight,
      padding: const EdgeInsets.only(right: 10, bottom: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
      ),
      child: Text(
        'Time',
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildLaneHeader(
    ThemeData theme,
    CoachDayLane lane,
    double width,
    List<VisitResponse> dayVisits,
  ) {
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
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        child: InkWell(
          onTap: tappable ? () => widget.onCoachTap(lane.staff!) : null,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                ),
                right: BorderSide(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.25),
                ),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 15,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(
                    initials,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lane.name.isEmpty ? 'Unassigned' : lane.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        count == 1 ? '1 visit' : '$count visits',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (tappable)
                  Icon(
                    Icons.open_in_new,
                    size: 15,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRuler(ThemeData theme, int firstHour, int lastHour) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
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
                      color: theme.colorScheme.onSurfaceVariant,
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
    ThemeData theme,
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
    final gridHeight =
        (lastHour - firstHour) * CoachDayBoardMetrics.hourHeight;
    final coach = lane.staff;

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
                              DateTime(widget.day.year, widget.day.month,
                                  widget.day.day, hour),
                            ),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: theme.colorScheme.outlineVariant
                                .withValues(alpha: 0.22),
                          ),
                          right: BorderSide(
                            color: theme.colorScheme.outlineVariant
                                .withValues(alpha: 0.25),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          for (final placement in placements)
            _buildVisitBlock(theme, placement, width, firstHour),
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

  List<Widget> _buildNowIndicator(ThemeData theme, int firstHour, int lastHour) {
    final offset = CoachDayBoardLayout.nowLineOffset(
      day: widget.day,
      firstHour: firstHour,
      lastHour: lastHour,
    );
    if (offset == null) return const [];

    return [
      Positioned(
        top: offset - 4,
        left: 0,
        right: 0,
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFFE2624F),
                shape: BoxShape.circle,
              ),
            ),
            const Expanded(
              child: Divider(color: Color(0xFFE2624F), thickness: 1.4),
            ),
          ],
        ),
      ),
    ];
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
    final tone = visitToneOf(visit.status);
    final color = tone.color;
    final range =
        '${formatClock(visit.startAt)} – ${formatClock(visit.endAt)}';

    return Tooltip(
      waitDuration: const Duration(milliseconds: 400),
      message: '${visit.memberName}\n'
          '${visit.serviceName}\n'
          '$range · ${tone.label}\n'
          'Coach ${visit.coachName}',
      child: Material(
        color: Color.alphaBlend(
          color.withValues(alpha: tone.isRetired ? 0.1 : 0.2),
          theme.colorScheme.surface,
        ),
        borderRadius: BorderRadius.circular(10),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: color.withValues(alpha: tone.isRetired ? 0.4 : 0.85),
              ),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxHeight < 54;

                return Row(
                  children: [
                    Container(width: 4, color: color),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: compact ? 3 : 6,
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
                                color: theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (!compact) ...[
                              const SizedBox(height: 2),
                              Text(
                                visit.memberName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  decoration: tone.isRetired
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                              Flexible(
                                child: Text(
                                  visit.serviceName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
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
