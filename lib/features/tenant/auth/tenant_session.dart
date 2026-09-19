import 'package:fitcore_client/core/auth/local_session_store.dart';

class TenantSession {
  TenantSession._();

  static String? organizationName;
  static String? ownerFirstName;
  static String? timeZone;

  static void set({
    required String organizationName,
    required String ownerFirstName,
    required String timeZone,
  }) {
    TenantSession.organizationName = organizationName;
    TenantSession.ownerFirstName = ownerFirstName;
    TenantSession.timeZone = timeZone;
    LocalSessionStore.saveTenantProfile(
      organizationName: organizationName,
      ownerFirstName: ownerFirstName,
      timeZone: timeZone,
    );
  }

  /// Memory-only restore from storage (no re-write).
  static void restore({
    String? organizationName,
    String? ownerFirstName,
    String? timeZone,
  }) {
    TenantSession.organizationName = organizationName;
    TenantSession.ownerFirstName = ownerFirstName;
    TenantSession.timeZone = timeZone;
  }

  static void clear() {
    organizationName = null;
    ownerFirstName = null;
    timeZone = null;
    LocalSessionStore.clearTenantProfile();
  }
}
