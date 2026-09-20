import 'package:fitcore_client/features/tenant/visits/models/visit_resolve_outcome.dart';

class ResolveVisitRequest {
  const ResolveVisitRequest({required this.outcome, required this.occurredAt});

  final VisitResolveOutcome outcome;
  final DateTime occurredAt;

  Map<String, dynamic> toJson() => {
        'outcome': outcome.wireName,
        'occurredAt': occurredAt.toUtc().toIso8601String(),
      };
}
