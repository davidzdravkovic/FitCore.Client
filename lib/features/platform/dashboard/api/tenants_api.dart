import 'package:fitcore_client/core/api/api_client.dart';
import 'package:fitcore_client/features/platform/dashboard/api/tenants_models.dart';

class TenantsApi {
  TenantsApi({ApiClient? client}) : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  Future<List<Tenant>> list() {
    return _client.request<List<Tenant>>(
      '/api/tenants',
      parse: (json) {
        final items = json as List<dynamic>? ?? const [];
        return items.map(Tenant.fromJson).toList();
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
