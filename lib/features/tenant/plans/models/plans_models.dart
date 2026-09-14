enum PlanEntitlementType {
  sessionPack,
  timePeriod;

  String get apiValue => switch (this) {
        PlanEntitlementType.sessionPack => 'SessionPack',
        PlanEntitlementType.timePeriod => 'TimePeriod',
      };

  String get label => switch (this) {
        PlanEntitlementType.sessionPack => 'Session pack',
        PlanEntitlementType.timePeriod => 'Time period',
      };

  static PlanEntitlementType? tryParse(String? value) {
    final normalized = value?.trim().toLowerCase();
    return switch (normalized) {
      'sessionpack' => PlanEntitlementType.sessionPack,
      'timeperiod' => PlanEntitlementType.timePeriod,
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
    this.durationDays,
  });

  final String id;
  final String serviceId;
  final String name;
  final double price;
  final PlanEntitlementType entitlementType;
  final int? sessionCount;
  final int? durationDays;
  final bool isActive;
  final DateTime createdAt;

  String get entitlementSummary {
    return switch (entitlementType) {
      PlanEntitlementType.sessionPack =>
        '${sessionCount ?? 0} session${(sessionCount ?? 0) == 1 ? '' : 's'}',
      PlanEntitlementType.timePeriod =>
        '${durationDays ?? 0} day${(durationDays ?? 0) == 1 ? '' : 's'}',
    };
  }

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
      durationDays: map['durationDays'] as int?,
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
    required this.entitlementType,
    this.sessionCount,
    this.durationDays,
  });

  final String serviceId;
  final String name;
  final double price;
  final PlanEntitlementType entitlementType;
  final int? sessionCount;
  final int? durationDays;

  Map<String, dynamic> toJson() => {
        'serviceId': serviceId,
        'name': name,
        'price': price,
        'entitlementType': entitlementType.apiValue,
        if (entitlementType == PlanEntitlementType.sessionPack)
          'sessionCount': sessionCount,
        if (entitlementType == PlanEntitlementType.timePeriod)
          'durationDays': durationDays,
      };
}
