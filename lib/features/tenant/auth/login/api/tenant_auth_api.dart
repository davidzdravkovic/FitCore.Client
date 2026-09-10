import 'package:fitcore_client/core/api/api_client.dart';
import 'package:fitcore_client/features/tenant/auth/login/api/tenant_login_models.dart';

class TenantAuthApi {
  TenantAuthApi({ApiClient? client}) : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  Future<TenantLoginResponse> login(TenantLoginRequest request) {
    return _client.request<TenantLoginResponse>(
      '/api/organizations/login',
      method: 'POST',
      data: request.toJson(),
      useAuth: false,
      parse: TenantLoginResponse.fromJson,
    );
  }
}
