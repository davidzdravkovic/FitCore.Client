class PlatformVerifyRequest {
  const PlatformVerifyRequest({required this.token});

  final String token;

  Map<String, dynamic> toJson() => {
        'token': token,
      };
}
