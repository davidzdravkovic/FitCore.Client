import 'package:fitcore_client/core/time/time_zones.dart';
import 'package:fitcore_client/features/tenant/auth/tenant_session.dart';
import 'package:timezone/timezone.dart' as tz;

/// Wall-clock math in the tenant IANA zone; wire/storage stay UTC.
///
/// Falls back to the device's local [tz.local] when session TZ is missing/unknown.
class TenantClock {
  TenantClock._();

  static tz.Location get location {
    final id = TenantSession.timeZone?.trim();
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
