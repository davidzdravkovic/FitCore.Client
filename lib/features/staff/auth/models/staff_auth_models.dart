class LoginStaffRequest {
  const LoginStaffRequest({
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

class ActivateStaffRequest {
  const ActivateStaffRequest({
    required this.token,
    required this.password,
  });

  final String token;
  final String password;

  Map<String, dynamic> toJson() => {
        'token': token,
        'password': password,
      };
}

class StaffSessionResponse {
  const StaffSessionResponse({
    required this.message,
    required this.accessToken,
    required this.organizationName,
    required this.firstName,
  });

  final String message;
  final String accessToken;
  final String organizationName;
  final String firstName;

  factory StaffSessionResponse.fromJson(dynamic json) {
    final map = json as Map<String, dynamic>? ?? {};
    return StaffSessionResponse(
      message: map['message'] as String? ?? '',
      accessToken: map['accessToken'] as String? ?? '',
      organizationName: map['organizationName'] as String? ?? '',
      firstName: map['firstName'] as String? ?? '',
    );
  }
}
