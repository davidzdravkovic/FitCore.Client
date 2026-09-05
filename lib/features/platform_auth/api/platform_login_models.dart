class PlatformLoginRequest {
  const PlatformLoginRequest({
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

class PlatformLoginResponse {
  const PlatformLoginResponse({required this.message});

  final String message;

  factory PlatformLoginResponse.fromJson(dynamic json) {
    final map = json as Map<String, dynamic>? ?? {};
    return PlatformLoginResponse(
      message: map['message'] as String? ?? '',
    );
  }
}
