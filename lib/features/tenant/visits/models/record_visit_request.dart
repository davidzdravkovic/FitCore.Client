import 'package:fitcore_client/features/tenant/visits/models/visit_resolve_outcome.dart';

/// Backfills a visit that was never scheduled; start must already be in the past.
class RecordVisitRequest {
  const RecordVisitRequest({
    required this.membershipId,
    required this.coachStaffId,
    required this.startAt,
    required this.endAt,
    required this.outcome,
  });

  final String membershipId;
  final String coachStaffId;
  final DateTime startAt;
  final DateTime endAt;
  final VisitResolveOutcome outcome;

  Map<String, dynamic> toJson() => {
        'membershipId': membershipId,
        'coachStaffId': coachStaffId,
        'startAt': startAt.toUtc().toIso8601String(),
        'endAt': endAt.toUtc().toIso8601String(),
        'outcome': outcome.wireName,
      };
}
