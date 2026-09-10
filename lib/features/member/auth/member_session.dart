class MemberSession {
  MemberSession._();

  static String? organizationName;
  static String? firstName;

  static void set({
    required String organizationName,
    required String firstName,
  }) {
    MemberSession.organizationName = organizationName;
    MemberSession.firstName = firstName;
  }

  static void clear() {
    organizationName = null;
    firstName = null;
  }
}
