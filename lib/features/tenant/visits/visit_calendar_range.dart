import 'package:fitcore_client/core/time/tenant_clock.dart';
import 'package:timezone/timezone.dart' as tz;

/// Tenant-zone calendar windows for visit list queries.
///
/// [from]/[to] are [tz.TZDateTime] midnights; [VisitsApi.list] still calls
/// `.toUtc()` for the wire (correct for TZDateTime).
class VisitCalendarRange {
  const VisitCalendarRange({required this.from, required this.to});

  /// Inclusive tenant-zone start (typically midnight).
  final DateTime from;

  /// Exclusive tenant-zone end.
  final DateTime to;

  static tz.TZDateTime dayStart(DateTime d) => TenantClock.dayStart(d);

  /// `[d 00:00, d+1 00:00)` in tenant TZ
  static VisitCalendarRange day(DateTime d) {
    final start = dayStart(d);
    return VisitCalendarRange(
      from: start,
      to: start.add(const Duration(days: 1)),
    );
  }

  /// Monday-start week: `[weekStart 00:00, weekStart+7)` in tenant TZ
  static VisitCalendarRange week(DateTime d) {
    final start = dayStart(d);
    final weekStart =
        start.subtract(Duration(days: start.weekday - DateTime.monday));
    return VisitCalendarRange(
      from: weekStart,
      to: weekStart.add(const Duration(days: 7)),
    );
  }

  /// Calendar month: `[1st 00:00, next month 1st)` in tenant TZ
  static VisitCalendarRange month(DateTime d) {
    final start = tz.TZDateTime(TenantClock.location, d.year, d.month, 1);
    final end = tz.TZDateTime(TenantClock.location, d.year, d.month + 1, 1);
    return VisitCalendarRange(from: start, to: end);
  }
}
