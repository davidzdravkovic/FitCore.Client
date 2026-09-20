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
