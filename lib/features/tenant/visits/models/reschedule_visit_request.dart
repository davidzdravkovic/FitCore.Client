class RescheduleVisitRequest {
  const RescheduleVisitRequest({
    required this.coachStaffId,
    required this.startAt,
    required this.endAt,
  });

  final String coachStaffId;
  final DateTime startAt;
  final DateTime endAt;

  Map<String, dynamic> toJson() => {
        'coachStaffId': coachStaffId,
        'startAt': startAt.toUtc().toIso8601String(),
        'endAt': endAt.toUtc().toIso8601String(),
      };
}
