class StaffResponse {
  const StaffResponse({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String email;

  factory StaffResponse.fromJson(dynamic json) {
    final map = json as Map<String, dynamic>? ?? {};
    return StaffResponse(
      id: map['id'] as String? ?? '',
      firstName: map['firstName'] as String? ?? '',
      lastName: map['lastName'] as String? ?? '',
      email: map['email'] as String? ?? '',
    );
  }
}
