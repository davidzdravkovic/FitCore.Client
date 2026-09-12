import 'package:fitcore_client/core/api/api_exception.dart';
import 'package:fitcore_client/features/tenant/staff/api/staff_api.dart';
import 'package:fitcore_client/features/tenant/staff/api/staff_models.dart';
import 'package:flutter/foundation.dart';

/// Feature orchestration: widgets stay thin; HTTP stays in [StaffApi].
class StaffController extends ChangeNotifier {
  StaffController({StaffApi? staffApi}) : _staffApi = staffApi ?? StaffApi();

  final StaffApi _staffApi;

  StaffApi get staffApi => _staffApi;

  List<Staff> staff = const [];
  bool isLoading = false;
  String? error;

  Future<void> load() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      staff = await _staffApi.list();
      error = null;
    } on ApiException catch (e) {
      error = e.message;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> invite(Staff person) async {
    try {
      await _staffApi.invite(person.id);
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }

  Future<String?> delete(Staff person) async {
    try {
      await _staffApi.delete(person.id);
      await load();
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }
}
