class PlatformVerifyRequest {
  const PlatformVerifyRequest({required this.token});

  final String token;

  Map<String, dynamic> toJson() => {
        'token': token,
      };
}

class PlatformVerifyResponse {
  const PlatformVerifyResponse({required this.accessToken});

  final String accessToken;

  factory PlatformVerifyResponse.fromJson(dynamic json) {
    final map = json as Map<String, dynamic>? ?? {};
    return PlatformVerifyResponse(
      accessToken: map['accessToken'] as String? ?? '',
    );
  }
}
