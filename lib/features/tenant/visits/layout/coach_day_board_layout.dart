import 'dart:math' as math;

import 'package:fitcore_client/core/time/tenant_clock.dart';
import 'package:fitcore_client/features/tenant/staff/models/staff_response.dart';
import 'package:fitcore_client/features/tenant/visits/models/visit_response.dart';
import 'package:fitcore_client/features/tenant/visits/widgets/visit_display.dart';

/// Pixel metrics for the multi-coach day board (widget + layout share these).
abstract final class CoachDayBoardMetrics {
  static const double rulerWidth = 68;
  static const double headerHeight = 64;
  static const double hourHeight = 76;
  static const double minLaneWidth = 190;
}

/// One coach column (or the spare "Unassigned" column).
class CoachDayLane {
  const CoachDayLane({
    required this.id,
    required this.name,
    this.staff,
  });

  final String id;
  final String name;
  final StaffResponse? staff;
}

/// Side-by-side slot for a visit inside an overlapping cluster.
class CoachDayPlacement {
  CoachDayPlacement({required this.visit, required this.column});

  final VisitResponse visit;
  final int column;
  int columnCount = 1;
}

/// Absolute position of a visit block inside a lane.
class CoachDayVisitGeometry {
  const CoachDayVisitGeometry({
    required this.top,
    required this.left,
    required this.width,
    required this.height,
  });

  final double top;
  final double left;
  final double width;
  final double height;
}

/// Pure layout math for [CoachDayBoard] — no Flutter widgets.
abstract final class CoachDayBoardLayout {
  static List<VisitResponse> visitsForDay({
    required List<VisitResponse> visits,
    required DateTime day,
  }) {
    final dayVisits = visits
        .where((visit) => isSameDay(TenantClock.toTenant(visit.startAt), day))
        .toList();
    dayVisits.sort((a, b) => a.startAt.compareTo(b.startAt));
    return dayVisits;
  }

  static List<CoachDayLane> lanes({
    required List<StaffResponse> staff,
    required List<VisitResponse> dayVisits,
  }) {
    final result = [
      for (final person in staff)
        CoachDayLane(
          id: person.id,
          name: '${person.firstName} ${person.lastName}'.trim(),
          staff: person,
        ),
    ];

    final known = {for (final lane in result) lane.id};
    final orphaned =
        dayVisits.where((visit) => !known.contains(visit.coachStaffId));
    if (orphaned.isNotEmpty) {
      result.add(const CoachDayLane(id: '', name: 'Unassigned'));
    }

    return result;
  }

  /// Inclusive start hour, exclusive end hour on the vertical ruler.
  static (int, int) hourWindow(List<VisitResponse> dayVisits) {
    var first = 7;
    var last = 21;

    for (final visit in dayVisits) {
      final start = TenantClock.toTenant(visit.startAt);
      final end = TenantClock.toTenant(visit.endAt);
      first = math.min(first, start.hour);
      last = math.max(last, end.minute > 0 ? end.hour + 1 : end.hour);
    }

    first = first.clamp(0, 22);
    last = last.clamp(first + 1, 24);
    return (first, last);
  }

  /// Visits whose coach is gone from the staff list fall into the spare lane.
  static bool belongsTo({
    required VisitResponse visit,
    required CoachDayLane lane,
    required List<StaffResponse> staff,
  }) {
    if (lane.staff != null) return visit.coachStaffId == lane.id;
    return !staff.any((person) => person.id == visit.coachStaffId);
  }

  static List<VisitResponse> visitsInLane({
    required List<VisitResponse> dayVisits,
    required CoachDayLane lane,
    required List<StaffResponse> staff,
  }) {
    return dayVisits
        .where(
          (visit) => belongsTo(visit: visit, lane: lane, staff: staff),
        )
        .toList();
  }

  /// Side-by-side placement for visits that share a time range.
  static List<CoachDayPlacement> placeOverlaps(List<VisitResponse> visits) {
    final sorted = [...visits]..sort((a, b) => a.startAt.compareTo(b.startAt));
    final placements = <CoachDayPlacement>[];

    var cluster = <CoachDayPlacement>[];
    var laneEnds = <DateTime>[];
    DateTime? clusterEnd;

    void closeCluster() {
      for (final placement in cluster) {
        placement.columnCount = laneEnds.length;
      }
      cluster = [];
      laneEnds = [];
      clusterEnd = null;
    }

    for (final visit in sorted) {
      final start = TenantClock.toTenant(visit.startAt);
      final end = TenantClock.toTenant(visit.endAt);

      if (clusterEnd != null && !start.isBefore(clusterEnd!)) closeCluster();

      var column = laneEnds.indexWhere((laneEnd) => !start.isBefore(laneEnd));
      if (column == -1) {
        laneEnds.add(end);
        column = laneEnds.length - 1;
      } else {
        laneEnds[column] = end;
      }

      final placement = CoachDayPlacement(visit: visit, column: column);
      cluster.add(placement);
      placements.add(placement);
      clusterEnd =
          clusterEnd == null || end.isAfter(clusterEnd!) ? end : clusterEnd;
    }

    closeCluster();
    return placements;
  }

  static CoachDayVisitGeometry visitGeometry({
    required CoachDayPlacement placement,
    required double laneWidth,
    required int firstHour,
    double hourHeight = CoachDayBoardMetrics.hourHeight,
  }) {
    final visit = placement.visit;
    final start = TenantClock.toTenant(visit.startAt);
    final end = TenantClock.toTenant(visit.endAt);

    final startMinutes = (start.hour - firstHour) * 60 + start.minute;
    final minutes = math.max(20, end.difference(start).inMinutes);
    final top = startMinutes * hourHeight / 60;
    final height = minutes * hourHeight / 60;

    final usable = laneWidth - 8;
    final slotWidth = usable / placement.columnCount;
    final left = 4 + slotWidth * placement.column;

    return CoachDayVisitGeometry(
      top: top + 2,
      left: left,
      width: slotWidth - 3,
      height: math.max(24, height - 4),
    );
  }

  /// Y offset of the "now" line, or null if it should not be drawn.
  static double? nowLineOffset({
    required DateTime day,
    required int firstHour,
    required int lastHour,
    double hourHeight = CoachDayBoardMetrics.hourHeight,
  }) {
    final now = TenantClock.now();
    if (!isSameDay(now, day)) return null;
    if (now.hour < firstHour || now.hour >= lastHour) return null;
    return ((now.hour - firstHour) * 60 + now.minute) * hourHeight / 60;
  }

  static double laneWidth({
    required double viewportWidth,
    required int laneCount,
    double rulerWidth = CoachDayBoardMetrics.rulerWidth,
    double minLaneWidth = CoachDayBoardMetrics.minLaneWidth,
  }) {
    final viewport = math.max(0.0, viewportWidth - rulerWidth);
    if (laneCount <= 0) return minLaneWidth;
    // On a narrow phone with one coach, fill the viewport instead of
    // leaving a dead strip beside a 190px minimum lane.
    if (laneCount == 1) return math.max(120.0, viewport);
    return math.max(minLaneWidth, viewport / laneCount);
  }

  static String initialsOf(String name) {
    final parts =
        name.split(' ').where((part) => part.trim().isNotEmpty).toList();
    if (parts.isEmpty) return '—';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
