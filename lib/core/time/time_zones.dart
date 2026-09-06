import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'browser_time_zone_stub.dart'
    if (dart.library.html) 'browser_time_zone_web.dart' as browser_tz;

/// IANA time zones from the official Dart `timezone` database.
class TimeZones {
  TimeZones._();

  static late final List<String> all;
  static late final Set<String> _ids;

  static void initialize() {
    tz_data.initializeTimeZones();
    all = tz.timeZoneDatabase.locations.keys.toList()..sort();
    _ids = all.toSet();
  }

  static bool contains(String id) => _ids.contains(id);

  static Future<String?> detectLocal() async {
    final candidates = <String>[];

    // Web: read Intl directly first. The plugin method channel can hang if the
    // web plugin is not registered, which would block prefill forever.
    final browserId = browser_tz.browserTimeZone();
    if (browserId != null && browserId.isNotEmpty) {
      candidates.add(browserId);
    }

    try {
      final info = await FlutterTimezone.getLocalTimezone().timeout(
        const Duration(milliseconds: 800),
      );
      if (info.identifier.isNotEmpty) {
        candidates.add(info.identifier);
      }
    } catch (_) {
      // Plugin may be unavailable (common on web); browser candidate is enough.
    }

    for (final raw in candidates) {
      final resolved = _resolve(raw);
      if (resolved != null) return resolved;
    }

    return null;
  }

  static String? _resolve(String raw) {
    final id = raw.trim();
    if (id.isEmpty) return null;
    if (contains(id)) return id;

    final lower = id.toLowerCase();
    for (final known in all) {
      if (known.toLowerCase() == lower) return known;
    }
    return null;
  }
}
