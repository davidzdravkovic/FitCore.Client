import 'package:fitcore_client/core/api/api_exception.dart';
import 'package:fitcore_client/features/tenant/plans/api/plans_api.dart';
import 'package:fitcore_client/features/tenant/plans/models/plan_response.dart';
import 'package:fitcore_client/features/tenant/services/api/services_api.dart';
import 'package:fitcore_client/features/tenant/services/models/service_response.dart';
import 'package:flutter/foundation.dart';

class PlansController extends ChangeNotifier {
  PlansController({
    PlansApi? plansApi,
    ServicesApi? servicesApi,
  })  : _plansApi = plansApi ?? PlansApi(),
        _servicesApi = servicesApi ?? ServicesApi();

  final PlansApi _plansApi;
  final ServicesApi _servicesApi;
  int _epoch = 0;

  PlansApi get plansApi => _plansApi;
  ServicesApi get servicesApi => _servicesApi;

  List<PlanResponse> plans = const [];
  List<ServiceResponse> services = const [];
  bool isLoading = false;
  String? error;

  String serviceName(String serviceId) {
    for (final service in services) {
      if (service.id == serviceId) return service.name;
    }
    return '—';
  }

  Future<void> load() async {
    final gen = ++_epoch;
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _plansApi.list(),
        _servicesApi.list(),
      ]);
      if (gen != _epoch) return;
      plans = results[0] as List<PlanResponse>;
      services = results[1] as List<ServiceResponse>;
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

  Future<String?> deactivate(PlanResponse plan) async {
    try {
      await _plansApi.deactivate(plan.id);
      await load();
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }
}
