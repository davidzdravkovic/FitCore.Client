import 'package:fitcore_client/core/auth/local_session_store.dart';
import 'package:fitcore_client/features/tenant/auth/tenant_session.dart';

class StaffSession {
  StaffSession._();

  static String? organizationName;
  static String? firstName;
  static String? timeZone;

  static void set({
    required String organizationName,
    required String firstName,
    required String timeZone,
  }) {
    StaffSession.organizationName = organizationName;
    StaffSession.firstName = firstName;
    StaffSession.timeZone = timeZone;
    // Same source TenantClock already reads (and hydrate restores).
    TenantSession.timeZone = timeZone;
    LocalSessionStore.saveTimeZone(timeZone);
  }

  static void clear() {
    organizationName = null;
    firstName = null;
    timeZone = null;
    TenantSession.timeZone = null;
    LocalSessionStore.saveTimeZone(null);
  }
}
