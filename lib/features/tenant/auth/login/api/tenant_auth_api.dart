import 'package:fitcore_client/core/api/api_client.dart';
import 'package:fitcore_client/features/tenant/auth/login/models/tenant_login_models.dart';

class TenantAuthApi {
  TenantAuthApi({ApiClient? client}) : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  Future<LoginOrganizationResponse> login(LoginOrganizationRequest request) {
    return _client.request<LoginOrganizationResponse>(
      '/api/organizations/login',
      method: 'POST',
      data: request.toJson(),
      useAuth: false,
      parse: LoginOrganizationResponse.fromJson,
    );
  }
}
