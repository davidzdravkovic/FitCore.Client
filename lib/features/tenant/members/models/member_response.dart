import 'package:fitcore_client/features/tenant/members/models/member_status.dart';

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
