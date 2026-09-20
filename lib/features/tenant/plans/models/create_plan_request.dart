import 'package:fitcore_client/features/tenant/plans/models/plan_entitlement_type.dart';

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
