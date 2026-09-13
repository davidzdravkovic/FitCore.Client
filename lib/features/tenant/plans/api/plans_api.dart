import 'package:fitcore_client/core/api/api_client.dart';
import 'package:fitcore_client/features/tenant/plans/models/plans_models.dart';

class PlansApi {
  PlansApi({ApiClient? client}) : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  Future<List<PlanResponse>> list() {
    return _client.request<List<PlanResponse>>(
      '/api/plans',
      parse: (json) {
        final items = json as List<dynamic>? ?? const [];
        return items.map(PlanResponse.fromJson).toList();
      },
    );
  }

  Future<PlanResponse> create(CreatePlanRequest request) {
    return _client.request<PlanResponse>(
      '/api/plans',
      method: 'POST',
      data: request.toJson(),
      parse: PlanResponse.fromJson,
    );
  }

  Future<void> deactivate(String id) {
    return _client.request<void>(
      '/api/plans/$id',
      method: 'DELETE',
      parse: (_) {},
    );
  }
}
