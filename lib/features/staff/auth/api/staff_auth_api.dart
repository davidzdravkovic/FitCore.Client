import 'package:fitcore_client/core/api/api_client.dart';
import 'package:fitcore_client/features/staff/auth/models/activate_staff_request.dart';
import 'package:fitcore_client/features/staff/auth/models/login_staff_request.dart';
import 'package:fitcore_client/features/staff/auth/models/staff_session_response.dart';

class StaffAuthApi {
  StaffAuthApi({ApiClient? client}) : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  Future<StaffSessionResponse> login(LoginStaffRequest request) {
    return _client.request<StaffSessionResponse>(
      '/api/staff/login',
      method: 'POST',
      data: request.toJson(),
      useAuth: false,
      parse: StaffSessionResponse.fromJson,
    );
  }

  Future<StaffSessionResponse> activate(ActivateStaffRequest request) {
    return _client.request<StaffSessionResponse>(
      '/api/staff/activate',
      method: 'POST',
      data: request.toJson(),
      useAuth: false,
      parse: StaffSessionResponse.fromJson,
    );
  }
}
