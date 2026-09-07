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

    // Web uses Intl non-web stub returns null.
    
    final fromBrowser = _resolve(browser_tz.browserTimeZone());
    if (fromBrowser != null) return fromBrowser;

    // Fallback when browser path is missing/unusable (typical on mobile/desktop).
    try {
      final info = await FlutterTimezone.getLocalTimezone().timeout(
        const Duration(seconds: 2),
      );
      return _resolve(info.identifier);
    } catch (_) {
      return null;
    }
  }

  static String? _resolve(String? raw) {
    if (raw == null) return null;
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
