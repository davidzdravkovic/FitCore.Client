class MembershipResponse {
  const MembershipResponse({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.planId,
    required this.planName,
    required this.status,
    required this.startAt,
    required this.createdAt,
    this.endAt,
    this.sessionsRemaining,
  });

  final String id;
  final String memberId;
  final String memberName;
  final String planId;
  final String planName;
  final String status;
  final DateTime startAt;
  final DateTime? endAt;
  final int? sessionsRemaining;
  final DateTime createdAt;

  factory MembershipResponse.fromJson(dynamic json) {
    final map = json as Map<String, dynamic>? ?? {};
    return MembershipResponse(
      id: map['id'] as String? ?? '',
      memberId: map['memberId'] as String? ?? '',
      memberName: map['memberName'] as String? ?? '',
      planId: map['planId'] as String? ?? '',
      planName: map['planName'] as String? ?? '',
      status: map['status'] as String? ?? '',
      startAt: DateTime.tryParse(map['startAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      endAt: map['endAt'] == null
          ? null
          : DateTime.tryParse(map['endAt'] as String? ?? ''),
      sessionsRemaining: map['sessionsRemaining'] as int?,
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }
}

class AssignMembershipRequest {
  const AssignMembershipRequest({
    required this.memberId,
    required this.planId,
    this.startAt,
  });

  final String memberId;
  final String planId;
  final DateTime? startAt;

  Map<String, dynamic> toJson() => {
        'memberId': memberId,
        'planId': planId,
        if (startAt != null) 'startAt': startAt!.toUtc().toIso8601String(),
      };
}
