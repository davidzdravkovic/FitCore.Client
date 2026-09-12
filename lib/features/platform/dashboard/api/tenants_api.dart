import 'package:fitcore_client/core/api/api_client.dart';
import 'package:fitcore_client/features/platform/dashboard/models/tenants_models.dart';

class TenantsApi {
  TenantsApi({ApiClient? client}) : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  Future<List<TenantResponse>> list() {
    return _client.request<List<TenantResponse>>(
      '/api/tenants',
      parse: (json) {
        final items = json as List<dynamic>? ?? const [];
        return items.map(TenantResponse.fromJson).toList();
      },
    );
  }

  Future<void> cancel(String id) {
    return _client.request<void>(
      '/api/tenants/$id',
      method: 'DELETE',
      parse: (_) {},
    );
  }
}
