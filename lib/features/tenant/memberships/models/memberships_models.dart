enum MembershipCancelReason {
  memberRequest,
  adminDecision;

  String get apiValue => switch (this) {
        MembershipCancelReason.memberRequest => 'MemberRequest',
        MembershipCancelReason.adminDecision => 'AdminDecision',
      };

  String get label => switch (this) {
        MembershipCancelReason.memberRequest => 'Member requested',
        MembershipCancelReason.adminDecision => 'Admin decision',
      };
}

class MembershipResponse {
  const MembershipResponse({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.planId,
    required this.planName,
    required this.status,
    required this.startAt,
    required this.sessionTotal,
    required this.sessionsReserved,
    required this.sessionsBurned,
    required this.sessionsAvailable,
    required this.createdAt,
    this.cancelReason,
    this.cancelNote,
    this.cancelledAt,
  });

  final String id;
  final String memberId;
  final String memberName;
  final String planId;
  final String planName;
  final String status;
  final DateTime startAt;
  final int sessionTotal;
  final int sessionsReserved;
  final int sessionsBurned;
  final int sessionsAvailable;
  final DateTime createdAt;
  final String? cancelReason;
  final String? cancelNote;
  final DateTime? cancelledAt;

  bool get isCancellable {
    final normalized = status.trim().toLowerCase();
    return normalized == 'active' || normalized == 'frozen';
  }

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
      sessionTotal: map['sessionTotal'] as int? ?? 0,
      sessionsReserved: map['sessionsReserved'] as int? ?? 0,
      sessionsBurned: map['sessionsBurned'] as int? ?? 0,
      sessionsAvailable: map['sessionsAvailable'] as int? ?? 0,
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      cancelReason: map['cancelReason'] as String?,
      cancelNote: map['cancelNote'] as String?,
      cancelledAt: map['cancelledAt'] == null
          ? null
          : DateTime.tryParse(map['cancelledAt'] as String? ?? ''),
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

class CancelMembershipRequest {
  const CancelMembershipRequest({
    required this.reason,
    this.note = '',
  });

  final MembershipCancelReason reason;
  final String note;

  Map<String, dynamic> toJson() => {
        'reason': reason.apiValue,
        if (note.trim().isNotEmpty) 'note': note.trim(),
      };
}
