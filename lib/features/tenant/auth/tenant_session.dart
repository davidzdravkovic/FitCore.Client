class TenantSession {
  TenantSession._();

  static String? organizationName;
  static String? ownerFirstName;

  static void set({
    required String organizationName,
    required String ownerFirstName,
  }) {
    TenantSession.organizationName = organizationName;
    TenantSession.ownerFirstName = ownerFirstName;
  }

  static void clear() {
    organizationName = null;
    ownerFirstName = null;
  }
}
