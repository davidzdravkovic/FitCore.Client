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
