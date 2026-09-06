import 'package:fitcore_client/core/api/api_client.dart';
import 'package:fitcore_client/features/tenant_registry/api/organizations_models.dart';

class OrganizationsApi {
  OrganizationsApi({ApiClient? client}) : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  Future<RegisterOrganizationResponse> register(
    RegisterOrganizationRequest request,
  ) {
    return _client.request<RegisterOrganizationResponse>(
      '/api/organizations/register',
      method: 'POST',
      data: request.toJson(),
      useAuth: false,
      parse: RegisterOrganizationResponse.fromJson,
    );
  }
}
