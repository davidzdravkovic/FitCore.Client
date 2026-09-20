class InviteMemberResponse {
  const InviteMemberResponse({required this.message});

  final String message;

  factory InviteMemberResponse.fromJson(dynamic json) {
    final map = json as Map<String, dynamic>? ?? {};
    return InviteMemberResponse(
      message: map['message'] as String? ?? '',
    );
  }
}
