class MemberSessionResponse {
  const MemberSessionResponse({
    required this.message,
    required this.accessToken,
    required this.organizationName,
    required this.firstName,
    required this.timeZone,
  });

  final String message;
  final String accessToken;
  final String organizationName;
  final String firstName;
  final String timeZone;

  factory MemberSessionResponse.fromJson(dynamic json) {
    final map = json as Map<String, dynamic>? ?? {};
    return MemberSessionResponse(
      message: map['message'] as String? ?? '',
      accessToken: map['accessToken'] as String? ?? '',
      organizationName: map['organizationName'] as String? ?? '',
      firstName: map['firstName'] as String? ?? '',
      timeZone: map['timeZone'] as String? ?? '',
    );
  }
}
