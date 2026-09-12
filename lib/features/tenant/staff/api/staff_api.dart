import 'package:fitcore_client/core/api/api_client.dart';
import 'package:fitcore_client/features/tenant/staff/models/staff_models.dart';

class StaffApi {
  StaffApi({ApiClient? client}) : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  Future<List<StaffResponse>> list() {
    return _client.request<List<StaffResponse>>(
      '/api/staff',
      parse: (json) {
        final items = json as List<dynamic>? ?? const [];
        return items.map(StaffResponse.fromJson).toList();
      },
    );
  }

  Future<StaffResponse> create(CreateStaffRequest request) {
    return _client.request<StaffResponse>(
      '/api/staff',
      method: 'POST',
      data: request.toJson(),
      parse: StaffResponse.fromJson,
    );
  }

  Future<InviteStaffResponse> invite(String id) {
    return _client.request<InviteStaffResponse>(
      '/api/staff/$id/invite',
      method: 'POST',
      parse: InviteStaffResponse.fromJson,
    );
  }

  Future<void> delete(String id) {
    return _client.request<void>(
      '/api/staff/$id',
      method: 'DELETE',
      parse: (_) {},
    );
  }
}
