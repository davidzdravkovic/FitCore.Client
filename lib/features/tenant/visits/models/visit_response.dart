import 'package:fitcore_client/core/time/tenant_clock.dart';

class VisitResponse {
  const VisitResponse({
    required this.id,
    required this.membershipId,
    required this.memberId,
    required this.memberName,
    required this.coachStaffId,
    required this.coachName,
    required this.serviceId,
    required this.serviceName,
    required this.startAt,
    required this.endAt,
    required this.status,
    required this.consumedSessionCredit,
    required this.createdAt,
    this.voidNote,
    this.voidedAt,
  });

  final String id;
  final String membershipId;
  final String memberId;
  final String memberName;
  final String coachStaffId;
  final String coachName;
  final String serviceId;
  final String serviceName;
  final DateTime startAt;
  final DateTime endAt;
  final String status;
  final bool consumedSessionCredit;
  final DateTime createdAt;
  final String? voidNote;
  final DateTime? voidedAt;

  bool get _isScheduled => status.trim().toLowerCase() == 'scheduled';

  bool get isVoidable => _isScheduled;

  bool get isReschedulable => _isScheduled;

  /// The API refuses a resolve before the visit has started.
  bool get canResolveNow =>
      _isScheduled &&
      !TenantClock.now().toUtc().isBefore(startAt.toUtc());

  factory VisitResponse.fromJson(dynamic json) {
    final map = json as Map<String, dynamic>? ?? {};
    return VisitResponse(
      id: map['id'] as String? ?? '',
      membershipId: map['membershipId'] as String? ?? '',
      memberId: map['memberId'] as String? ?? '',
      memberName: map['memberName'] as String? ?? '',
      coachStaffId: map['coachStaffId'] as String? ?? '',
      coachName: map['coachName'] as String? ?? '',
      serviceId: map['serviceId'] as String? ?? '',
      serviceName: map['serviceName'] as String? ?? '',
      startAt: DateTime.tryParse(map['startAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      endAt: DateTime.tryParse(map['endAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      status: map['status'] as String? ?? '',
      consumedSessionCredit: map['consumedSessionCredit'] as bool? ?? false,
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      voidNote: map['voidNote'] as String?,
      voidedAt: map['voidedAt'] == null
          ? null
          : DateTime.tryParse(map['voidedAt'] as String? ?? ''),
    );
  }
}
