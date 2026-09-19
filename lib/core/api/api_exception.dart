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
    this.sessionsAvailable,
  });

  final String id;
  final String planId;
  final String planName;
  final String status;
  final int? sessionsAvailable;

  factory UnresolvedMembershipInfo.fromJson(dynamic json) {
    final map = json as Map<String, dynamic>? ?? {};
    return UnresolvedMembershipInfo(
      id: map['id'] as String? ?? '',
      planId: map['planId'] as String? ?? '',
      planName: map['planName'] as String? ?? '',
      status: map['status'] as String? ?? '',
      sessionsAvailable: map['sessionsAvailable'] as int?,
    );
  }

  String get summary {
    final parts = <String>[planName, status];
    if (sessionsAvailable != null) {
      parts.add('$sessionsAvailable available');
    }
    return parts.join(' · ');
  }
}
