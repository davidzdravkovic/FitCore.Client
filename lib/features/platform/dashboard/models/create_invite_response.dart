class CreateInviteResponse {
  const CreateInviteResponse({required this.message});

  final String message;

  factory CreateInviteResponse.fromJson(dynamic json) {
    final map = json as Map<String, dynamic>? ?? {};
    return CreateInviteResponse(
      message: map['message'] as String? ?? '',
    );
  }
}
