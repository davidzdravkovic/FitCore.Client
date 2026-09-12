class TenantResponse {
  const TenantResponse({
    required this.id,
    required this.name,
    required this.businessEmail,
    required this.country,
    required this.city,
    required this.timeZone,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String businessEmail;
  final String country;
  final String city;
  final String timeZone;
  final String status;
  final DateTime createdAt;

  bool get isCancelled => status.toLowerCase() == 'cancelled';

  factory TenantResponse.fromJson(dynamic json) {
    final map = json as Map<String, dynamic>? ?? {};
    return TenantResponse(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      businessEmail: map['businessEmail'] as String? ?? '',
      country: map['country'] as String? ?? '',
      city: map['city'] as String? ?? '',
      timeZone: map['timeZone'] as String? ?? '',
      status: map['status'] as String? ?? '',
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }
}
