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

  /// API refuses resolve before start. Compare in the same zone the calendar
  /// paints so a 16:00–17:00 visit unlocks Complete/No-show after 16:00.
  bool get canResolveNow {
    if (!_isScheduled) return false;
    final start = TenantClock.toTenant(startAt);
    final now = TenantClock.now();
    return !now.isBefore(start);
  }

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
      startAt: _parseInstant(map['startAt']),
      endAt: _parseInstant(map['endAt']),
      status: map['status'] as String? ?? '',
      consumedSessionCredit: map['consumedSessionCredit'] as bool? ?? false,
      createdAt: _parseInstant(map['createdAt']),
      voidNote: map['voidNote'] as String?,
      voidedAt: map['voidedAt'] == null
          ? null
          : _parseInstant(map['voidedAt']),
    );
  }

  /// API stores UTC. Bare ISO without `Z`/offset must not be read as device-local
  /// (that shifts the instant and keeps Complete/No-show grey after the session).
  static DateTime _parseInstant(dynamic raw) {
    final s = (raw as String? ?? '').trim();
    if (s.isEmpty) {
      return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    }
    final parsed = DateTime.tryParse(s);
    if (parsed == null) {
      return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    }
    if (parsed.isUtc) return parsed;
    final hasOffset = s.endsWith('Z') ||
        s.contains('+') ||
        RegExp(r'-\d{2}:\d{2}$').hasMatch(s);
    if (hasOffset) return parsed.toUtc();
    return DateTime.utc(
      parsed.year,
      parsed.month,
      parsed.day,
      parsed.hour,
      parsed.minute,
      parsed.second,
      parsed.millisecond,
      parsed.microsecond,
    );
  }
}
