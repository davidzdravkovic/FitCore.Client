enum MemberStatus {
  lead,
  active;

  String get apiValue => switch (this) {
        MemberStatus.lead => 'Lead',
        MemberStatus.active => 'Active',
      };

  String get label => switch (this) {
        MemberStatus.lead => 'Lead',
        MemberStatus.active => 'Active',
      };

  static MemberStatus? tryParse(String? value) {
    final normalized = value?.trim().toLowerCase();
    return switch (normalized) {
      'lead' => MemberStatus.lead,
      'active' => MemberStatus.active,
      _ => null,
    };
  }
}

class Member {
  const Member({
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

  factory Member.fromJson(dynamic json) {
    final map = json as Map<String, dynamic>? ?? {};
    return Member(
      id: map['id'] as String? ?? '',
      firstName: map['firstName'] as String? ?? '',
      lastName: map['lastName'] as String? ?? '',
      email: map['email'] as String?,
      phone: map['phone'] as String?,
      status: MemberStatus.tryParse(map['status'] as String?) ?? MemberStatus.active,
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }
}

class CreateMemberRequest {
  const CreateMemberRequest({
    required this.firstName,
    required this.lastName,
    required this.status,
    this.email = '',
    this.phone = '',
  });

  final String firstName;
  final String lastName;
  final MemberStatus status;
  final String email;
  final String phone;

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phone': phone,
        'status': status.apiValue,
      };
}
