import 'package:fitcore_client/core/api/api_client.dart';
import 'package:fitcore_client/features/tenant/members/api/members_models.dart';

class MembersApi {
  MembersApi({ApiClient? client}) : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  Future<List<Member>> list() {
    return _client.request<List<Member>>(
      '/api/members',
      parse: (json) {
        final items = json as List<dynamic>? ?? const [];
        return items.map(Member.fromJson).toList();
      },
    );
  }

  Future<Member> create(CreateMemberRequest request) {
    return _client.request<Member>(
      '/api/members',
      method: 'POST',
      data: request.toJson(),
      parse: Member.fromJson,
    );
  }

  Future<void> invite(String id) {
    return _client.request<void>(
      '/api/members/$id/invite',
      method: 'POST',
      parse: (_) {},
    );
  }

  Future<void> delete(String id) {
    return _client.request<void>(
      '/api/members/$id',
      method: 'DELETE',
      parse: (_) {},
    );
  }
}
