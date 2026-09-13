import 'package:fitcore_client/core/api/api_client.dart';
import 'package:fitcore_client/features/tenant/services/models/services_models.dart';

class ServicesApi {
  ServicesApi({ApiClient? client}) : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  Future<List<ServiceResponse>> list() {
    return _client.request<List<ServiceResponse>>(
      '/api/services',
      parse: (json) {
        final items = json as List<dynamic>? ?? const [];
        return items.map(ServiceResponse.fromJson).toList();
      },
    );
  }

  Future<ServiceResponse> create(CreateServiceRequest request) {
    return _client.request<ServiceResponse>(
      '/api/services',
      method: 'POST',
      data: request.toJson(),
      parse: ServiceResponse.fromJson,
    );
  }

  Future<void> deactivate(String id) {
    return _client.request<void>(
      '/api/services/$id',
      method: 'DELETE',
      parse: (_) {},
    );
  }
}
