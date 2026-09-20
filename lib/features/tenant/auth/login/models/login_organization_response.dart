class LoginOrganizationResponse {
  const LoginOrganizationResponse({
    required this.message,
    required this.accessToken,
    required this.organizationName,
    required this.ownerFirstName,
    required this.timeZone,
  });

  final String message;
  final String accessToken;
  final String organizationName;
  final String ownerFirstName;
  final String timeZone;

  factory LoginOrganizationResponse.fromJson(dynamic json) {
    final map = json as Map<String, dynamic>? ?? {};
    return LoginOrganizationResponse(
      message: map['message'] as String? ?? '',
      accessToken: map['accessToken'] as String? ?? '',
      organizationName: map['organizationName'] as String? ?? '',
      ownerFirstName: map['ownerFirstName'] as String? ?? '',
      timeZone: map['timeZone'] as String? ?? '',
    );
  }
}
