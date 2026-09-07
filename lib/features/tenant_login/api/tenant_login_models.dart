class TenantLoginRequest {
  const TenantLoginRequest({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
      };
}

class TenantLoginResponse {
  const TenantLoginResponse({
    required this.message,
    required this.accessToken,
    required this.organizationName,
    required this.ownerFirstName,
  });

  final String message;
  final String accessToken;
  final String organizationName;
  final String ownerFirstName;

  factory TenantLoginResponse.fromJson(dynamic json) {
    final map = json as Map<String, dynamic>? ?? {};
    return TenantLoginResponse(
      message: map['message'] as String? ?? '',
      accessToken: map['accessToken'] as String? ?? '',
      organizationName: map['organizationName'] as String? ?? '',
      ownerFirstName: map['ownerFirstName'] as String? ?? '',
    );
  }
}
