import 'package:fitcore_client/core/api/api_exception.dart';
import 'package:fitcore_client/features/tenant/services/api/services_api.dart';
import 'package:fitcore_client/features/tenant/services/models/service_response.dart';
import 'package:flutter/foundation.dart';

class ServicesController extends ChangeNotifier {
  ServicesController({ServicesApi? servicesApi})
      : _servicesApi = servicesApi ?? ServicesApi();

  final ServicesApi _servicesApi;
  int _epoch = 0;

  ServicesApi get servicesApi => _servicesApi;

  List<ServiceResponse> services = const [];
  bool isLoading = false;
  String? error;

  Future<void> load() async {
    final gen = ++_epoch;
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final list = await _servicesApi.list();
      if (gen != _epoch) return;
      services = list;
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
}
