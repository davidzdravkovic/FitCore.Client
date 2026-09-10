import 'package:fitcore_client/core/api/api_client.dart';
import 'package:fitcore_client/features/tenant/staff/api/staff_models.dart';

class StaffApi {
  StaffApi({ApiClient? client}) : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  Future<List<Staff>> list() {
    return _client.request<List<Staff>>(
      '/api/staff',
      parse: (json) {
        final items = json as List<dynamic>? ?? const [];
        return items.map(Staff.fromJson).toList();
      },
    );
  }

  Future<Staff> create(CreateStaffRequest request) {
    return _client.request<Staff>(
      '/api/staff',
      method: 'POST',
      data: request.toJson(),
      parse: Staff.fromJson,
    );
  }

  Future<void> invite(String id) {
    return _client.request<void>(
      '/api/staff/$id/invite',
      method: 'POST',
      parse: (_) {},
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
