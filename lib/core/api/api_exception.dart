class ApiException implements Exception {
  ApiException(
    this.message, {
    this.statusCode,
    this.memberships = const [],
  });

  final String message;
  final int? statusCode;
  final List<UnresolvedMembershipInfo> memberships;

  bool get hasUnresolvedMemberships => memberships.isNotEmpty;

  @override
  String toString() => message;
}

class UnresolvedMembershipInfo {
  const UnresolvedMembershipInfo({
    required this.id,
    required this.planId,
    required this.planName,
    required this.status,
    this.endAt,
    this.sessionsRemaining,
  });

  final String id;
  final String planId;
  final String planName;
  final String status;
  final DateTime? endAt;
  final int? sessionsRemaining;

  factory UnresolvedMembershipInfo.fromJson(dynamic json) {
    final map = json as Map<String, dynamic>? ?? {};
    return UnresolvedMembershipInfo(
      id: map['id'] as String? ?? '',
      planId: map['planId'] as String? ?? '',
      planName: map['planName'] as String? ?? '',
      status: map['status'] as String? ?? '',
      endAt: DateTime.tryParse(map['endAt'] as String? ?? ''),
      sessionsRemaining: map['sessionsRemaining'] as int?,
    );
  }

  String get summary {
    final parts = <String>[planName, status];
    if (sessionsRemaining != null) {
      parts.add('$sessionsRemaining sessions left');
    } else if (endAt != null) {
      final local = endAt!.toLocal();
      final y = local.year.toString().padLeft(4, '0');
      final m = local.month.toString().padLeft(2, '0');
      final d = local.day.toString().padLeft(2, '0');
      parts.add('ends $y-$m-$d');
    }
    return parts.join(' · ');
  }
}
