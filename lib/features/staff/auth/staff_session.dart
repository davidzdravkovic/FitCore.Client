class StaffSession {
  StaffSession._();

  static String? organizationName;
  static String? firstName;

  static void set({
    required String organizationName,
    required String firstName,
  }) {
    StaffSession.organizationName = organizationName;
    StaffSession.firstName = firstName;
  }

  static void clear() {
    organizationName = null;
    firstName = null;
  }
}
