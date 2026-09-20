class InviteStaffResponse {
  const InviteStaffResponse({required this.message});

  final String message;

  factory InviteStaffResponse.fromJson(dynamic json) {
    final map = json as Map<String, dynamic>? ?? {};
    return InviteStaffResponse(
      message: map['message'] as String? ?? '',
    );
  }
}
