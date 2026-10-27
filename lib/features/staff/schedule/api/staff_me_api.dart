import 'package:fitcore_client/core/api/api_client.dart';
import 'package:fitcore_client/features/tenant/staff/models/staff_response.dart';

class StaffMeApi {
  StaffMeApi({ApiClient? client}) : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  Future<StaffResponse> get() {
    return _client.request<StaffResponse>(
      '/api/staff/me',
      parse: StaffResponse.fromJson,
    );
  }
}
