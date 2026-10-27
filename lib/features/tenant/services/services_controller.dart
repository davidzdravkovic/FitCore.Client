import 'package:fitcore_client/core/api/api_exception.dart';
import 'package:fitcore_client/features/tenant/plans/api/plans_api.dart';
import 'package:fitcore_client/features/tenant/plans/models/plan_response.dart';
import 'package:fitcore_client/features/tenant/services/api/services_api.dart';
import 'package:fitcore_client/features/tenant/services/models/service_response.dart';
import 'package:flutter/foundation.dart';

class ServicesController extends ChangeNotifier {
  ServicesController({
    ServicesApi? servicesApi,
    PlansApi? plansApi,
  })  : _servicesApi = servicesApi ?? ServicesApi(),
        _plansApi = plansApi ?? PlansApi();

  final ServicesApi _servicesApi;
  final PlansApi _plansApi;
  int _epoch = 0;

  ServicesApi get servicesApi => _servicesApi;
  PlansApi get plansApi => _plansApi;

  List<ServiceResponse> services = const [];
  List<PlanResponse> plans = const [];
  bool isLoading = false;
  String? error;

  List<ServiceResponse> get activeServices =>
      services.where((s) => s.isActive).toList();

  List<PlanResponse> plansFor(String serviceId) =>
      plans.where((p) => p.serviceId == serviceId).toList();

  Future<void> load() async {
    final gen = ++_epoch;
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _servicesApi.list(),
        _plansApi.list(),
      ]);
      if (gen != _epoch) return;
      services = results[0] as List<ServiceResponse>;
      plans = results[1] as List<PlanResponse>;
    } on ApiException catch (e) {
      if (gen != _epoch) return;
      error = e.message;
    } finally {
      if (gen == _epoch) {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<String?> deactivate(ServiceResponse service) async {
    try {
      await _servicesApi.deactivate(service.id);
      await load();
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }

  Future<String?> deactivatePlan(PlanResponse plan) async {
    try {
      await _plansApi.deactivate(plan.id);
      await load();
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }
}
