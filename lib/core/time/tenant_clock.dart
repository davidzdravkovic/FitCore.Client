import 'package:fitcore_client/core/time/time_zones.dart';
import 'package:fitcore_client/features/member/auth/member_session.dart';
import 'package:fitcore_client/features/staff/auth/staff_session.dart';
import 'package:fitcore_client/features/tenant/auth/tenant_session.dart';
import 'package:timezone/timezone.dart' as tz;

/// Wall-clock math in the tenant IANA zone; wire/storage stay UTC.
///
/// Zone source: tenant admin session, else staff, else member, else device local.
class TenantClock {
  TenantClock._();

  static tz.Location get location {
    final id = _sessionTimeZone;
    if (id != null && id.isNotEmpty && TimeZones.contains(id)) {
      return tz.getLocation(id);
    }
    // Prefer configured device local when session TZ is missing; else UTC.
    try {
      return tz.local;
    } catch (_) {
      return tz.UTC;
    }
  }

  static String? get _sessionTimeZone {
    final tenant = TenantSession.timeZone?.trim();
    if (tenant != null && tenant.isNotEmpty) return tenant;
    final staff = StaffSession.timeZone?.trim();
    if (staff != null && staff.isNotEmpty) return staff;
    final member = MemberSession.timeZone?.trim();
    if (member != null && member.isNotEmpty) return member;
    return null;
  }

  /// Current instant as a tenant-zone [DateTime] (actually [tz.TZDateTime]).
  static tz.TZDateTime now() => tz.TZDateTime.now(location);

  /// Calendar date (y/m/d) at 00:00 in the tenant zone.
  static tz.TZDateTime dayStart(DateTime d) =>
      tz.TZDateTime(location, d.year, d.month, d.day);

  /// Interpret picker/board wall components as tenant-local, return UTC instant.
  static DateTime toUtc(DateTime wall) {
    final zoned = tz.TZDateTime(
      location,
      wall.year,
      wall.month,
      wall.day,
      wall.hour,
      wall.minute,
      wall.second,
      wall.millisecond,
      wall.microsecond,
    );
    return zoned.toUtc();
  }

  /// Instant (UTC or otherwise) → wall clock in the tenant zone.
  static tz.TZDateTime toTenant(DateTime instant) =>
      tz.TZDateTime.from(instant.toUtc(), location);
}
