enum PlanEntitlementType {
  sessionPack;

  String get apiValue => 'SessionPack';

  String get label => 'Session pack';

  static PlanEntitlementType? tryParse(String? value) {
    final normalized = value?.trim().toLowerCase();
    return switch (normalized) {
      'sessionpack' => PlanEntitlementType.sessionPack,
      _ => null,
    };
  }
}

class PlanResponse {
  const PlanResponse({
    required this.id,
    required this.serviceId,
    required this.name,
    required this.price,
    required this.entitlementType,
    required this.isActive,
    required this.createdAt,
    this.sessionCount,
  });

  final String id;
  final String serviceId;
  final String name;
  final double price;
  final PlanEntitlementType entitlementType;
  final int? sessionCount;
  final bool isActive;
  final DateTime createdAt;

  String get entitlementSummary =>
      '${sessionCount ?? 0} session${(sessionCount ?? 0) == 1 ? '' : 's'}';

  factory PlanResponse.fromJson(dynamic json) {
    final map = json as Map<String, dynamic>? ?? {};
    final priceRaw = map['price'];
    return PlanResponse(
      id: map['id'] as String? ?? '',
      serviceId: map['serviceId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      price: priceRaw is num
          ? priceRaw.toDouble()
          : double.tryParse('$priceRaw') ?? 0,
      entitlementType:
          PlanEntitlementType.tryParse(map['entitlementType'] as String?) ??
              PlanEntitlementType.sessionPack,
      sessionCount: map['sessionCount'] as int?,
      isActive: map['isActive'] as bool? ?? false,
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }
}

class CreatePlanRequest {
  const CreatePlanRequest({
    required this.serviceId,
    required this.name,
    required this.price,
    required this.sessionCount,
    this.entitlementType = PlanEntitlementType.sessionPack,
  });

  final String serviceId;
  final String name;
  final double price;
  final PlanEntitlementType entitlementType;
  final int sessionCount;

  Map<String, dynamic> toJson() => {
        'serviceId': serviceId,
        'name': name,
        'price': price,
        'entitlementType': entitlementType.apiValue,
        'sessionCount': sessionCount,
      };
}
