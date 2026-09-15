enum MemberStatus {
  lead,
  trial,
  active,
  paused,
  cancelled;

  String get label => switch (this) {
        MemberStatus.lead => 'Lead',
        MemberStatus.trial => 'Trial',
        MemberStatus.active => 'Active',
        MemberStatus.paused => 'Paused',
        MemberStatus.cancelled => 'Cancelled',
      };

  bool get canAssignMembership =>
      this == MemberStatus.lead ||
      this == MemberStatus.active ||
      this == MemberStatus.paused;

  static MemberStatus? tryParse(String? value) {
    final normalized = value?.trim().toLowerCase();
    return switch (normalized) {
      'lead' => MemberStatus.lead,
      'trial' => MemberStatus.trial,
      'active' => MemberStatus.active,
      'paused' => MemberStatus.paused,
      'cancelled' => MemberStatus.cancelled,
      _ => null,
    };
  }
}

class MemberResponse {
  const MemberResponse({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.status,
    required this.createdAt,
    this.email,
    this.phone,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String? email;
  final String? phone;
  final MemberStatus status;
  final DateTime createdAt;

  factory MemberResponse.fromJson(dynamic json) {
    final map = json as Map<String, dynamic>? ?? {};
    return MemberResponse(
      id: map['id'] as String? ?? '',
      firstName: map['firstName'] as String? ?? '',
      lastName: map['lastName'] as String? ?? '',
      email: map['email'] as String?,
      phone: map['phone'] as String?,
      status: MemberStatus.tryParse(map['status'] as String?) ?? MemberStatus.lead,
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }
}

class CreateMemberRequest {
  const CreateMemberRequest({
    required this.firstName,
    required this.lastName,
    this.email = '',
    this.phone = '',
  });

  final String firstName;
  final String lastName;
  final String email;
  final String phone;

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phone': phone,
      };
}

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
