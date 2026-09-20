class CreateVisitRequest {
  const CreateVisitRequest({
    required this.membershipId,
    required this.coachStaffId,
    required this.startAt,
    required this.endAt,
  });

  final String membershipId;
  final String coachStaffId;
  final DateTime startAt;
  final DateTime endAt;

  Map<String, dynamic> toJson() => {
        'membershipId': membershipId,
        'coachStaffId': coachStaffId,
        'startAt': startAt.toUtc().toIso8601String(),
        'endAt': endAt.toUtc().toIso8601String(),
      };
}
